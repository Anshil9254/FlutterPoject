import 'package:flutter/material.dart';
import '../color.dart';
import '../reusable_header.dart'; // Make sure to import the reusable header

class MilkHistoryPage extends StatelessWidget {
  const MilkHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Milk History Data
    final List<Map<String, String>> milkHistory = [
      {"date": "25 April, 2024", "ltr": "Ltr. 10.5"},
      {"date": "24 April, 2024", "ltr": "Ltr. 7"},
      {"date": "23 April, 2024", "ltr": "Ltr. 8.2"},
      {"date": "22 April, 2024", "ltr": "Ltr. 7.4"},
      {"date": "21 April, 2024", "ltr": "Ltr. 5"},
      {"date": "20 April, 2024", "ltr": "Ltr. 9"},
      {"date": "19 April, 2024", "ltr": "Ltr. 4"},
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
                title: "Milk History",
                icon: Icons.history,
                onBackPressed: () => Navigator.pop(context),
              ),
              
              const SizedBox(height: 16),
              
              // Month Selector
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.calendar_today, size: 22, color: Colors.black),
                    SizedBox(width: 12),
                    Text("April 2024", style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Milk history list
              Expanded(
                child: ListView.builder(
                  itemCount: milkHistory.length,
                  padding: const EdgeInsets.only(bottom: 12),
                  itemBuilder: (context, index) {
                    final item = milkHistory[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        vertical: 7,
                        horizontal: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left side: Milk Bottle Image
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/milk_bottle.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback icon if asset missing
                                  return const Icon(Icons.local_drink, size: 30);
                                },
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Right side: Date + Ltr (takes remaining space)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["date"] ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item["ltr"] ?? '',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Optional trailing chevron (comment out if not needed)
                          // const Icon(Icons.chevron_right, color: Colors.black26),
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