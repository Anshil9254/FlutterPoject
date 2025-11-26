import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'userdashboard.dart';
import 'payment_wallet.dart';
import '../color.dart';
import '../reusable_header.dart';
import 'invoice_service.dart';

class InvoicePage extends StatefulWidget {
  final String userId;
  final String userName;
  
  const InvoicePage({super.key, required this.userId, required this.userName});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  Map<String, dynamic> _invoiceData = {};
  bool _isLoading = true;
  int _pendingPaymentsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadInvoiceData();
    _loadPendingPaymentsCount();
  }

  Future<void> _loadInvoiceData() async {
    try {
      final data = await InvoiceService.getUserInvoiceSummary(widget.userId);
      setState(() {
        _invoiceData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading invoice data: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadPendingPaymentsCount() async {
    try {
      final count = await InvoiceService.getUserPendingPaymentsCount(widget.userId);
      setState(() {
        _pendingPaymentsCount = count;
      });
    } catch (e) {
      print("Error loading pending payments count: $e");
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return "January";
      case 2: return "February";
      case 3: return "March";
      case 4: return "April";
      case 5: return "May";
      case 6: return "June";
      case 7: return "July";
      case 8: return "August";
      case 9: return "September";
      case 10: return "October";
      case 11: return "November";
      case 12: return "December";
      default: return "";
    }
  }

  Widget _buildInvoiceCard() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.buttonColor),
        ),
      );
    }

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColors.boxShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Invoice Summary",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "User: ${_invoiceData['userName'] ?? widget.userName}",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              "Date: ${DateTime.now().day} ${_getMonthName(DateTime.now().month)}, ${DateTime.now().year}",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            
            // Pending Payments Badge
            if (_pendingPaymentsCount > 0) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pending_actions, size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 6),
                    Text(
                      "$_pendingPaymentsCount payment(s) pending approval",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),

            // Summary Table
            Table(
              border: const TableBorder(
                horizontalInside: BorderSide(
                  width: 1,
                  color: Colors.black12,
                ),
              ),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Description",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Amount",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Total Milk Buy",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${_invoiceData['totalLiters']?.toStringAsFixed(2) ?? '0.00'} L",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Total Amount",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "₹ ${_invoiceData['totalAmount']?.toStringAsFixed(2) ?? '0.00'}",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Paid Amount",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "₹ ${_invoiceData['paidAmount']?.toStringAsFixed(2) ?? '0.00'}",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Remaining Amount",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "₹ ${_invoiceData['remainingAmount']?.toStringAsFixed(2) ?? '0.00'}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: (_invoiceData['remainingAmount'] ?? 0) > 0 ? Colors.orange : Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Payment History
            if ((_invoiceData['payments'] as List?)?.isNotEmpty ?? false) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              Text(
                "Payment History",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ...(_invoiceData['payments'] as List).reversed.take(3).map((payment) {
                final date = (payment['timestamp'] as Timestamp).toDate();
                final status = payment['status'] ?? 'completed';
                Color statusColor = Colors.green;
                if (status == 'pending') statusColor = Colors.orange;
                if (status == 'rejected') statusColor = Colors.red;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${payment['paymentMethod']} - ${date.day}/${date.month}/${date.year}",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "₹${payment['amount']?.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 12,
                          color: status == 'rejected' ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  void _processWalletPayment(BuildContext context) async {
    final double amount = _invoiceData['remainingAmount'] ?? 0.0;
    
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No remaining amount to pay"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navigate to Wallet Payment Page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletPaymentPage(
          amount: amount,
          userId: widget.userId,
          userName: _invoiceData['userName'] ?? widget.userName,
          totalAmount: _invoiceData['totalAmount'] ?? 0.0,
        ),
      ),
    ).then((value) {
      // Reload data when returning from wallet payment
      _loadInvoiceData();
      _loadPendingPaymentsCount();
    });
  }

  void _processCashPayment(BuildContext context) async {
    final double amount = _invoiceData['remainingAmount'] ?? 0.0;
    
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No remaining amount to pay"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await InvoiceService.createPayment(
        userId: widget.userId,
        userName: _invoiceData['userName'] ?? widget.userName,
        amount: amount,
        paymentMethod: 'Cash',
        totalAmount: _invoiceData['totalAmount'] ?? 0.0,
      );

      // Reload data to show updated amounts
      await _loadInvoiceData();
      await _loadPendingPaymentsCount();
      
      _showPaymentSuccess(context, "Cash");
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPaymentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  "Choose Payment Method",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Payment Amount Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Amount to Pay:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      "₹ ${_invoiceData['remainingAmount']?.toStringAsFixed(2) ?? '0.00'}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.buttonColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Payment Options in Card Format
              Center(
                child: Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  children: [
                    _buildPaymentCard(
                      context,
                      icon: Icons.account_balance_wallet,
                      title: "Wallet",
                      onTap: () {
                        Navigator.pop(context); // Close bottom sheet
                        _processWalletPayment(context);
                      },
                    ),
                    _buildPaymentCard(
                      context,
                      icon: Icons.money,
                      title: "Cash on Delivery",
                      onTap: () {
                        Navigator.pop(context); // Close bottom sheet
                        _processCashPayment(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: AppColors.boxShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppColors.buttonColor),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentSuccess(BuildContext context, String method) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.buttonColor,
                  size: 60,
                ),
                const SizedBox(height: 15),
                Text(
                  "Payment Submitted!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Paid via $method",
                  style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                Text(
                  "Amount: ₹ ${_invoiceData['remainingAmount']?.toStringAsFixed(2) ?? '0.00'}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Payment is pending admin approval",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    foregroundColor: AppColors.textOnGold,
                    minimumSize: const Size(200, 50),
                  ),
                  onPressed: () {
                    // Navigate to Dashboard
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Userdashboard(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text("Go to Dashboard"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use the reusable header
              ReusableHeader(
                title: "Invoice",
                icon: Icons.receipt,
                onBackPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 20),

              _buildInvoiceCard(),

              const SizedBox(height: 30),

              // Only show Pay Now button if there's remaining amount
              if ((_invoiceData['remainingAmount'] ?? 0) > 0)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      foregroundColor: AppColors.textOnGold,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isLoading ? null : () {
                      _showPaymentOptions(context);
                    },
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Pay Now",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              letterSpacing: 1.1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              
              // Show message if no payment needed
              if ((_invoiceData['remainingAmount'] ?? 0) <= 0 && !_isLoading)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        "All Payments Cleared!",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "You have no pending payments.",
                        style: TextStyle(
                          color: Colors.green.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}