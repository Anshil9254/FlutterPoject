import 'package:flutter/material.dart';
import 'color.dart';
import 'milkhistory.dart';
import 'invoice.dart';
import 'admin/paymenthistory.dart';
import 'settings.dart';
import 'profile.dart';

// Main Dashboard
class Userdashboard extends StatelessWidget {
  const Userdashboard({super.key});

  @override
  Widget build(BuildContext context) {

    // Quick buttons data with navigation
    final List<Map<String, dynamic>> quickButtons = [
      {
        "icon": "assets/milk_bottle.png", // Image asset
        "isAsset": true,
        "label": "View Milk History",
        "page": const MilkHistoryPage(),
      },
      {
        "icon": Icons.receipt_long, // IconData
        "isAsset": false,
        "label": "View Invoices",
        "page": const InvoicePage(),
      },
      {
        "icon": Icons.access_time,
        "isAsset": false,
        "label": "Payment History",
        "page": const PaymentHistoryPage(),
      },
    ];

    return Scaffold(
      backgroundColor: (bgcolor),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Welcome
              Row(
                children: const [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.black12,
                    child: Icon(Icons.person, size: 40, color: Colors.black),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Welcome, John",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                "Customer Dashboard",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Supply + Outstanding row
              Row(
                children: [
                  Expanded(child: _dashboardCard("32", "Today's supply")),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dashboardCard("₹ 500", "Outstanding amount"),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Current month bill
              _dashboardCard("1,250", "Current month bill", center: false),
              const SizedBox(height: 20),

              const Text(
                "Quick buttons",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Quick Buttons List
              Expanded(
                child: ListView.separated(
                  itemCount: quickButtons.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final button = quickButtons[index];
                    return _quickButton(
                      button['icon'],
                      button['label'],
                      isAsset: button['isAsset'],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => button['page'],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // 0 = Home by default
        backgroundColor: (bgcolor),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black87,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Userdashboard()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InvoicePage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Invoices"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }

  // Dashboard card widget
  static Widget _dashboardCard(
    String value,
    String label, {
    bool center = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (cardColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: center
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // Quick Button widget (updated to handle asset or icon)
  static Widget _quickButton(
    dynamic icon,
    String label, {
    VoidCallback? onTap,
    bool isAsset = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: (cardColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            isAsset
                ? Image.asset(
                    icon,
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                  )
                : Icon(icon, size: 22, color: Colors.black),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
