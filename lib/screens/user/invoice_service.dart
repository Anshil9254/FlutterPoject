import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or update invoice payment - FIXED VERSION
  static Future<void> createPayment({
    required String userId,
    required String userName,
    required double amount,
    required String paymentMethod,
    required double totalAmount,
  }) async {
    try {
      final invoiceRef = _firestore.collection('invoices').doc(userId);
      final Timestamp paymentTimestamp = Timestamp.now();
      
      // Create payment data
      final paymentData = {
        'amount': amount,
        'paymentMethod': paymentMethod,
        'timestamp': paymentTimestamp,
        'status': 'pending',
      };

      // Get current invoice data
      final invoiceDoc = await invoiceRef.get();
      
      if (invoiceDoc.exists) {
        // Update existing invoice
        final currentData = invoiceDoc.data()!;
        final List<dynamic> currentPayments = currentData['payments'] ?? [];
        
        // Add new payment to the list
        currentPayments.add(paymentData);
        
        // Calculate current paid amount (only approved payments)
        double currentPaidAmount = 0.0;
        for (var payment in currentPayments) {
          if (payment['status'] == 'approved') {
            currentPaidAmount += (payment['amount'] as num).toDouble();
          }
        }
        
        double remainingAmount = totalAmount - currentPaidAmount;
        
        // Update with the modified array
        await invoiceRef.update({
          'payments': currentPayments,
          'totalAmount': totalAmount,
          'remainingAmount': remainingAmount,
          'lastUpdated': FieldValue.serverTimestamp(),
          'userName': userName,
        });
      } else {
        // Create new invoice
        await invoiceRef.set({
          'userId': userId,
          'userName': userName,
          'totalAmount': totalAmount,
          'remainingAmount': totalAmount, // For new invoice, no payments approved yet
          'paidAmount': 0.0,
          'payments': [paymentData],
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      // Create notification for admin with the same timestamp
      await _createAdminNotification(userId, userName, amount, paymentMethod, paymentTimestamp);
      
    } catch (e) {
      print("Error creating payment: $e");
      throw e;
    }
  }

  // Create admin notification with explicit timestamp
  static Future<void> _createAdminNotification(
    String userId, 
    String userName, 
    double amount, 
    String paymentMethod,
    Timestamp timestamp
  ) async {
    try {
      await _firestore.collection('admin_notifications').add({
        'userId': userId,
        'userName': userName,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'timestamp': timestamp, // Use the same timestamp as payment
        'status': 'pending',
        'type': 'payment_received',
        'read': false,
      });
    } catch (e) {
      print("Error creating notification: $e");
    }
  }

  // Get user invoice summary with proper status handling
  static Future<Map<String, dynamic>> getUserInvoiceSummary(String userId) async {
    try {
      // Get milk sales total
      final milkSalesDoc = await _firestore.collection('milk_sales').doc(userId).get();
      double totalAmount = 0.0;
      double totalLiters = 0.0;
      
      if (milkSalesDoc.exists && milkSalesDoc.data()?['salesEntries'] != null) {
        final Map<String, dynamic> salesEntries = milkSalesDoc.data()!['salesEntries'];
        salesEntries.forEach((key, entry) {
          totalLiters += (entry['quantity'] as double? ?? 0.0);
          totalAmount += (entry['totalPrice'] as double? ?? 0.0);
        });
      }

      // Get paid amount from invoices - only count approved payments
      final invoiceDoc = await _firestore.collection('invoices').doc(userId).get();
      double paidAmount = 0.0;
      double pendingAmount = 0.0;
      List<dynamic> payments = [];
      List<dynamic> approvedPayments = [];

      if (invoiceDoc.exists) {
        payments = invoiceDoc.data()?['payments'] ?? [];
        for (var payment in payments) {
          String status = payment['status'] ?? 'pending';
          double amount = (payment['amount'] as double? ?? 0.0);
          
          if (status == 'approved') {
            paidAmount += amount;
            approvedPayments.add(payment);
          } else if (status == 'pending') {
            pendingAmount += amount;
          }
        }
      }

      double remainingAmount = totalAmount - paidAmount;

      return {
        'totalLiters': totalLiters,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'pendingAmount': pendingAmount,
        'remainingAmount': remainingAmount,
        'payments': approvedPayments, // Only show approved payments
        'allPayments': payments, // Keep all payments for admin view
        'userName': milkSalesDoc.data()?['name'] ?? '',
        'hasPendingPayments': pendingAmount > 0,
      };
    } catch (e) {
      print("Error getting invoice summary: $e");
      return {
        'totalLiters': 0.0, 
        'totalAmount': 0.0, 
        'paidAmount': 0.0, 
        'pendingAmount': 0.0,
        'remainingAmount': 0.0, 
        'payments': [],
        'allPayments': [],
        'userName': '',
        'hasPendingPayments': false,
      };
    }
  }

  // Update notification status (for admin) - FIXED VERSION
  static Future<void> updateNotificationStatus(
    String notificationId, 
    String status, 
    String? adminNotes
  ) async {
    try {
      // First get the notification to get user info
      final notificationDoc = await _firestore.collection('admin_notifications').doc(notificationId).get();
      if (notificationDoc.exists) {
        final data = notificationDoc.data()!;
        final String userId = data['userId'];
        final double amount = (data['amount'] as num).toDouble();
        final Timestamp notificationTimestamp = data['timestamp'];
        
        // Update the notification
        await _firestore.collection('admin_notifications').doc(notificationId).update({
          'status': status,
          'adminNotes': adminNotes,
          'processedAt': FieldValue.serverTimestamp(),
          'processedBy': 'admin',
        });

        // Also update the payment status in the invoice
        if (status == 'approved' || status == 'rejected') {
          await _updatePaymentStatusInInvoice(userId, notificationTimestamp, amount, status, adminNotes);
        }
      }
    } catch (e) {
      print("Error updating notification: $e");
      throw e;
    }
  }

  // NEW METHOD: Update payment status in invoice by finding the matching pending payment
  static Future<void> _updatePaymentStatusInInvoice(
    String userId, 
    Timestamp notificationTimestamp, 
    double amount, 
    String status,
    String? adminNotes
  ) async {
    try {
      final invoiceRef = _firestore.collection('invoices').doc(userId);
      final invoiceDoc = await invoiceRef.get();
      
      if (invoiceDoc.exists) {
        final List<dynamic> payments = invoiceDoc.data()?['payments'] ?? [];
        final List<dynamic> updatedPayments = [];
        bool paymentFound = false;
        
        // Find and update the matching pending payment
        for (var payment in payments) {
          Map<String, dynamic> paymentMap = Map<String, dynamic>.from(payment);
          
          // Check if this is the matching pending payment (similar amount and pending status)
          bool isMatchingPayment = (paymentMap['status'] == 'pending') &&
                                  ((paymentMap['amount'] as num).toDouble() == amount) &&
                                  (_isSimilarTimestamp(paymentMap['timestamp'], notificationTimestamp));
          
          if (isMatchingPayment && !paymentFound) {
            // Update the found payment
            updatedPayments.add({
              ...paymentMap,
              'status': status,
              'adminNotes': adminNotes,
            });
            paymentFound = true;
            print("✅ Found and updated payment with amount: $amount, status: $status");
          } else {
            updatedPayments.add(paymentMap);
          }
        }
        
        if (!paymentFound) {
          print("⚠️ No matching pending payment found for amount: $amount");
        }
        
        // Recalculate remaining amount based on approved payments only
        double totalAmount = (invoiceDoc.data()?['totalAmount'] as double? ?? 0.0);
        double paidAmount = 0.0;
        
        for (var payment in updatedPayments) {
          Map<String, dynamic> paymentMap = Map<String, dynamic>.from(payment);
          if (paymentMap['status'] == 'approved') {
            paidAmount += (paymentMap['amount'] as num).toDouble();
          }
        }
        
        double remainingAmount = totalAmount - paidAmount;
        
        // Update the invoice with modified payments and new amounts
        await invoiceRef.update({
          'payments': updatedPayments,
          'paidAmount': paidAmount,
          'remainingAmount': remainingAmount,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        
        print("✅ Payment status updated to: $status for user: $userId");
        print("✅ New paidAmount: $paidAmount, remainingAmount: $remainingAmount");
      }
    } catch (e) {
      print("Error updating payment status in invoice: $e");
      throw e;
    }
  }

  // Helper method to compare timestamps with tolerance
  static bool _isSimilarTimestamp(dynamic paymentTimestamp, Timestamp notificationTimestamp) {
    try {
      if (paymentTimestamp is Timestamp) {
        // If both are Timestamps, compare with 2-minute tolerance
        final paymentTime = paymentTimestamp.toDate();
        final notificationTime = notificationTimestamp.toDate();
        final difference = paymentTime.difference(notificationTime).abs();
        return difference.inMinutes <= 2;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get all pending notifications for admin - WITH BETTER ERROR HANDLING
  static Stream<QuerySnapshot> getPendingNotifications() {
    try {
      return _firestore
          .collection('admin_notifications')
          .where('status', isEqualTo: 'pending')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .handleError((error) {
            print("Stream error in getPendingNotifications: $error");
            // Return an empty stream or handle as needed
            return Stream<QuerySnapshot>.empty();
          });
    } catch (e) {
      print("Error in getPendingNotifications: $e");
      // Return empty stream as fallback
      return Stream<QuerySnapshot>.empty();
    }
  }

  // Get all notifications for admin - WITH BETTER ERROR HANDLING
  static Stream<QuerySnapshot> getAllNotifications() {
    try {
      return _firestore
          .collection('admin_notifications')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .handleError((error) {
            print("Stream error in getAllNotifications: $error");
            return Stream<QuerySnapshot>.empty();
          });
    } catch (e) {
      print("Error in getAllNotifications: $e");
      return Stream<QuerySnapshot>.empty();
    }
  }

  // Alternative method for pending notifications (client-side filtering)
  static Stream<QuerySnapshot> getPendingNotificationsAlt() {
    return _firestore
        .collection('admin_notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .handleError((error) {
          print("Stream error in getPendingNotificationsAlt: $error");
          return Stream<QuerySnapshot>.empty();
        });
  }

  // Get user's payment history
  static Stream<DocumentSnapshot> getUserInvoiceStream(String userId) {
    return _firestore.collection('invoices').doc(userId).snapshots();
  }

  // Check if user has any pending payments
  static Future<bool> hasPendingPayments(String userId) async {
    try {
      final summary = await getUserInvoiceSummary(userId);
      return (summary['pendingAmount'] ?? 0) > 0;
    } catch (e) {
      print("Error checking pending payments: $e");
      return false;
    }
  }

  // Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('admin_notifications').doc(notificationId).update({
        'read': true,
      });
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  // Get unread notifications count
  static Stream<int> getUnreadNotificationsCount() {
    return _firestore
        .collection('admin_notifications')
        .where('read', isEqualTo: false)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .handleError((error) {
          print("Error in getUnreadNotificationsCount: $error");
          return 0;
        });
  }

  // Get user's pending payments count
  static Future<int> getUserPendingPaymentsCount(String userId) async {
    try {
      final invoiceDoc = await _firestore.collection('invoices').doc(userId).get();
      if (invoiceDoc.exists) {
        final List<dynamic> payments = invoiceDoc.data()?['payments'] ?? [];
        int pendingCount = 0;
        for (var payment in payments) {
          if (payment['status'] == 'pending') {
            pendingCount++;
          }
        }
        return pendingCount;
      }
      return 0;
    } catch (e) {
      print("Error getting user pending payments count: $e");
      return 0;
    }
  }

  // NEW METHOD: Get payment history with proper status filtering
  static Future<List<Map<String, dynamic>>> getUserPaymentHistory(String userId) async {
    try {
      final invoiceDoc = await _firestore.collection('invoices').doc(userId).get();
      if (invoiceDoc.exists) {
        final List<dynamic> payments = invoiceDoc.data()?['payments'] ?? [];
        List<Map<String, dynamic>> paymentHistory = [];
        
        for (var payment in payments) {
          paymentHistory.add(Map<String, dynamic>.from(payment));
        }
        
        // Sort by timestamp (newest first)
        paymentHistory.sort((a, b) {
          final Timestamp timestampA = a['timestamp'];
          final Timestamp timestampB = b['timestamp'];
          return timestampB.compareTo(timestampA);
        });
        
        return paymentHistory;
      }
      return [];
    } catch (e) {
      print("Error getting payment history: $e");
      return [];
    }
  }
}