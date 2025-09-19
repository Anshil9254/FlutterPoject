import 'package:flutter/material.dart';
import '../color.dart';

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
      backgroundColor: (AppColors.bgColor), // Cream background
      appBar: AppBar(
        backgroundColor: (AppColors.bgColor),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Payment History",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // Month filter
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (AppColors.cardColor),
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
                      color: (AppColors.cardColor),
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
    );
  }
}
