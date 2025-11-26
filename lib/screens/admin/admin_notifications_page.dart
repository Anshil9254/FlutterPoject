import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../color.dart';
import '../user/invoice_service.dart';

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkIndexes();
  }

  Future<void> _checkIndexes() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

  // Fixed method to complete billing cycle and reset
  Future<void> _completeAndResetBilling(String userId, String userName, double totalAmount) async {
    try {
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      
      // Show confirmation dialog
      bool confirmReset = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Complete Billing Cycle",
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to complete the billing cycle for $userName?\n\n"
            "This will:\n"
            "• Reset all payments to zero\n"
            "• Archive current invoice\n"
            "• Start fresh billing cycle\n\n"
            "Total Amount: ₹${totalAmount.toStringAsFixed(2)}",
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                "Cancel",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Complete & Reset", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmReset != true) return;

      setState(() {
        _isLoading = true;
      });

      // 1. Get current invoice data for archiving
      final invoiceDoc = await _firestore.collection('invoices').doc(userId).get();
      if (invoiceDoc.exists) {
        final invoiceData = invoiceDoc.data()!;
        
        // Archive current invoice data (without payments field)
        final archiveData = {
          'userId': userId,
          'userName': userName,
          'totalAmount': totalAmount,
          'paidAmount': invoiceData['paidAmount'] ?? 0.0,
          'completedAt': FieldValue.serverTimestamp(),
          'originalInvoiceData': {
            'totalAmount': invoiceData['totalAmount'],
            'paidAmount': invoiceData['paidAmount'],
            'remainingAmount': invoiceData['remainingAmount'],
            'userName': invoiceData['userName'],
          }
        };

        await _firestore.collection('invoice_archive').doc().set(archiveData);

        // 2. Reset the main invoice document - FIXED: Use update instead of set with FieldValue.delete
        await _firestore.collection('invoices').doc(userId).update({
          'totalAmount': 0.0,
          'remainingAmount': 0.0,
          'paidAmount': 0.0,
          'payments': [], // Clear payments by setting empty array
          'lastUpdated': FieldValue.serverTimestamp(),
          'billingCycleReset': FieldValue.serverTimestamp(),
        });

        // 3. Reset milk_sales data for fresh start
        await _firestore.collection('milk_sales').doc(userId).update({
          'TotalAmount': 0.0,
          'totalEntries': 0,
          'salesEntries': {}, // Clear sales entries with empty map
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ Billing cycle completed for $userName. Fresh cycle started!"),
            backgroundColor: AppColors.buttonColor,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error completing billing cycle: $e"),
          backgroundColor: AppColors.buttonColorSecondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      print("Detailed error: $e");
    }
  }

  // Check if user has fully paid their invoice and can be reset
  Future<bool> _canResetBilling(String userId) async {
    try {
      final invoiceDoc = await FirebaseFirestore.instance
          .collection('invoices')
          .doc(userId)
          .get();

      if (invoiceDoc.exists) {
        final data = invoiceDoc.data()!;
        final double remainingAmount = (data['remainingAmount'] ?? 0.0).toDouble();
        final double totalAmount = (data['totalAmount'] ?? 0.0).toDouble();
        
        // Can reset if remaining amount is 0 and there was some total amount
        return remainingAmount <= 0 && totalAmount > 0;
      }
      return false;
    } catch (e) {
      print("Error checking reset eligibility: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text(
          "Payment Notifications",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = '';
              });
              _checkIndexes();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Error Message
          if (_errorMessage.isNotEmpty) _buildErrorSection(),

          // Header Info
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppColors.boxShadow,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications_active, color: AppColors.buttonColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Manage payment approvals and reset billing cycles",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Notifications List
          Expanded(
            child: _isLoading 
                ? _buildLoadingState()
                : _buildAllNotifications(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
        boxShadow: AppColors.boxShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning, color: Colors.orange[600], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Configuration Required",
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.orange[700], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.buttonColor),
          const SizedBox(height: 16),
          Text(
            "Loading notifications...",
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllNotifications() {
    return StreamBuilder<QuerySnapshot>(
      stream: InvoiceService.getAllNotifications(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState("No Notifications Found");
        }

        final notifications = snapshot.data!.docs;

        // Separate notifications by status
        final pendingNotifications = notifications.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['status'] == 'pending';
        }).toList();

        final processedNotifications = notifications.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['status'] != 'pending';
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Pending Section
            if (pendingNotifications.isNotEmpty) ...[
              _buildSectionHeader("Pending Approvals (${pendingNotifications.length})"),
              const SizedBox(height: 12),
              ...pendingNotifications.map((notification) {
                final data = notification.data() as Map<String, dynamic>;
                return _buildNotificationCard(notification.id, data, true);
              }).toList(),
              const SizedBox(height: 20),
            ],

            // Processed Section
            if (processedNotifications.isNotEmpty) ...[
              _buildSectionHeader("Processed Payments (${processedNotifications.length})"),
              const SizedBox(height: 12),
              ...processedNotifications.map((notification) {
                final data = notification.data() as Map<String, dynamic>;
                return _buildNotificationCard(notification.id, data, false);
              }).toList(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 60, color: AppColors.gold),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.goldLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, size: 60, color: AppColors.buttonColorSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            "Error loading notifications",
            style: TextStyle(fontSize: 18, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error.length > 100 ? "${error.substring(0, 100)}..." : error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: AppColors.elevatedButtonStyle,
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = '';
              });
              _checkIndexes();
            },
            child: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(String notificationId, Map<String, dynamic> data, bool isPending) {
    final timestamp = (data['timestamp'] as Timestamp).toDate();
    final status = data['status'] ?? 'pending';
    Color statusColor = AppColors.gold;
    IconData statusIcon = Icons.pending;
    Color statusBgColor = AppColors.goldLight;
    
    if (status == 'approved') {
      statusColor = AppColors.buttonColor;
      statusIcon = Icons.check_circle;
      statusBgColor = Colors.green[50]!;
    } else if (status == 'rejected') {
      statusColor = AppColors.buttonColorSecondary;
      statusIcon = Icons.cancel;
      statusBgColor = Colors.red[50]!;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, size: 20, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['userName'] ?? 'Unknown User',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        "User ID: ${data['userId'] ?? 'N/A'}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Payment Details
            _buildDetailRow("Amount", "₹${data['amount']?.toStringAsFixed(2)}"),
            _buildDetailRow("Payment Method", data['paymentMethod'] ?? 'Unknown'),
            _buildDetailRow("Date", DateFormat('dd MMM yyyy, HH:mm').format(timestamp)),
            
            if (data['adminNotes'] != null) 
              _buildDetailRow("Admin Notes", data['adminNotes']!, isNote: true),
            
            if (data['processedAt'] != null) 
              _buildDetailRow("Processed", DateFormat('dd MMM yyyy, HH:mm').format((data['processedAt'] as Timestamp).toDate())),
            
            const SizedBox(height: 12),
            
            // Action Buttons
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 18),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _handleNotification(notificationId, 'approved', null),
                      label: const Text("Approve"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.close, size: 18),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColorSecondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _showRejectionDialog(notificationId),
                      label: const Text("Reject"),
                    ),
                  ),
                ],
              ),
            
            // Complete & Reset Button (only for approved payments with zero balance)
            if (status == 'approved') ...[
              const SizedBox(height: 8),
              FutureBuilder<bool>(
                future: _canResetBilling(data['userId']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasData && snapshot.data == true) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.refresh, size: 18),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.textOnGold,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          final invoiceDoc = await FirebaseFirestore.instance
                              .collection('invoices')
                              .doc(data['userId'])
                              .get();
                          
                          if (invoiceDoc.exists) {
                            final invoiceData = invoiceDoc.data()!;
                            final double totalAmount = (invoiceData['totalAmount'] ?? 0.0).toDouble();
                            
                            await _completeAndResetBilling(
                              data['userId'], 
                              data['userName'], 
                              totalAmount
                            );
                          }
                        },
                        label: const Text("Complete & Reset Billing"),
                      ),
                    );
                  }
                  
                  return const SizedBox();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isNote = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isNote ? Colors.orange[800] : AppColors.textSecondary,
                fontStyle: isNote ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(String notificationId) {
    TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Reject Payment",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Please provide a reason for rejection:",
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: "Reason",
                  border: OutlineInputBorder(),
                  hintText: "Enter rejection reason...",
                  filled: true,
                  fillColor: AppColors.inputFieldColor,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColorSecondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      if (reasonController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please provide a reason"),
                            behavior: SnackBarBehavior.floating,
                           // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                        return;
                      }
                      
                      try {
                        await InvoiceService.updateNotificationStatus(
                          notificationId, 
                          'rejected', 
                          reasonController.text.trim()
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Payment rejected successfully"),
                            backgroundColor: AppColors.buttonColor,
                            behavior: SnackBarBehavior.floating,
                            //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      } catch (e) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: $e"),
                            backgroundColor: AppColors.buttonColorSecondary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    },
                    child: const Text("Reject"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotification(String notificationId, String status, String? adminNotes) async {
    try {
      await InvoiceService.updateNotificationStatus(notificationId, status, adminNotes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment $status successfully"),
          backgroundColor: status == 'approved' ? AppColors.buttonColor : AppColors.buttonColorSecondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: AppColors.buttonColorSecondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}