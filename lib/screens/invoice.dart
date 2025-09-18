import 'package:flutter/material.dart';
import 'userdashboard.dart';
import 'admin/payment_card.dart';
import 'admin/payment_upi.dart';
import 'admin/payment_wallet.dart';
import 'color.dart';

class InvoicePage extends StatelessWidget {
  const InvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        backgroundColor: bgcolor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Invoice",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // Invoice Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Invoice #1234",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Date: 20 April, 2024",
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    
                    // Invoice Table
                    Table(
                      border: const TableBorder(
                        horizontalInside: BorderSide(width: 1, color: Colors.black12),
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(1),
                      },
                      children: const [
                        TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Item",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Amount",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("2 Liters Milk"),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("₹ 60.00"),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Total",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("₹ 60.00",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Pay Now Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _showPaymentOptions(context);
                  },
                  child: const Text(
                    "Pay Now",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgcolor,
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
              const Center(
                child: Text(
                  "Choose Payment Method",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      icon: Icons.credit_card,
                      title: "Credit/Debit Card",
                      onTap: () => _navigateToCardPayment(context),
                    ),
                    _buildPaymentCard(
                      context,
                      icon: Icons.account_balance,
                      title: "UPI Payment",
                      onTap: () => _navigateToUPIPayment(context),
                    ),
                    _buildPaymentCard(
                      context,
                      icon: Icons.account_balance_wallet,
                      title: "Wallet",
                      onTap: () => _navigateToWalletPayment(context),
                    ),
                    _buildPaymentCard(
                      context,
                      icon: Icons.money,
                      title: "Cash on Delivery",
                      onTap: () => _processCashPayment(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: buttonColor),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCardPayment(BuildContext context) {
    Navigator.pop(context); // Close the bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CardPaymentPage(),
      ),
    );
  }

  void _navigateToUPIPayment(BuildContext context) {
    Navigator.pop(context); // Close the bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UPIPaymentPage(),
      ),
    );
  }

  void _navigateToWalletPayment(BuildContext context) {
    Navigator.pop(context); // Close the bottom sheet
    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => WalletPaymentPage(amount: 60.00),
  ),
);
  }

  void _processCashPayment(BuildContext context) {
    Navigator.pop(context); // Close the bottom sheet
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: bgcolor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.money, size: 50, color: Colors.green),
                const SizedBox(height: 15),
                const Text(
                  "Cash on Delivery",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Your order has been placed successfully. Please keep the exact amount ready for delivery.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
                      onPressed: () {
                        Navigator.pop(context);
                        _showPaymentSuccess(context, "Cash on Delivery");
                      },
                      child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPaymentSuccess(BuildContext context, String method) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: bgcolor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 15),
                const Text(
                  "Payment Successful!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text("Paid via $method", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
                  onPressed: () {
                    // Navigate to Dashboard
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Userdashboard()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text("Go to Dashboard", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

