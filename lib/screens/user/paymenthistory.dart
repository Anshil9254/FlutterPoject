import 'package:flutter/material.dart';
import '../color.dart';
import '../reusable_header.dart'; // Make sure to import the reusable header

class PaymentHistoryPage extends StatelessWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for payment history
    final List<Map<String, dynamic>> payments = [
      {"date": "25 April, 2024", "invoice": "Invoice 10", "amount": "₹60"},
      {"date": "24 April, 2024", "invoice": "Invoice 9", "amount": "₹30"},
      {"date": "23 April, 2024", "invoice": "Invoice 8", "amount": "₹150"},
      {"date": "22 April, 2024", "invoice": "Invoice 7", "amount": "₹100"},
      {"date": "21 April, 2024", "invoice": "Invoice 6", "amount": "₹50"},
      {"date": "20 April, 2024", "invoice": "Invoice 5", "amount": "₹80"},
    ];

    return Scaffold(
      backgroundColor: AppColors.bgColor, // Cream background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use the reusable header
              ReusableHeader(
                title: "Payment History",
                icon: Icons.payment,
                onBackPressed: () => Navigator.pop(context),
              ),
              
              const SizedBox(height: 16),
              
              // Month filter
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20, color: Colors.black),
                    SizedBox(width: 10),
                    Text("April 2024", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Payment history list
              Expanded(
                child: ListView.builder(
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                payment["date"],
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                payment["invoice"],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            payment["amount"],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}