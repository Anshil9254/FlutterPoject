import 'package:flutter/material.dart';
import 'usermanagement.dart';
import 'milkcollection.dart';
import 'sellmilk.dart';
import 'buymilkpayment.dart';
import 'sellmilkpayment.dart';
import '../user/settings.dart';
import '../color.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor, // Using the getter from color.dart
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Row(
                children: const [
                  Icon(Icons.account_circle, size: 40),
                  SizedBox(width: 8),
                  Text(
                    "Welcome, John",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Dashboard Title
              const Text(
                "Admin Dashboard",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Grid Menu
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildDashboardCard(
                      context,
                      title: "User Management",
                      icon: Icons.people,
                      page: const UserManagement(),
                    ),
                    _buildDashboardCard(
                      context,
                      title: "Milk Collection Entry",
                      imagePath: "assets/milk_bottle.png",
                      page: const MilkEntryPage(),
                    ),
                    _buildDashboardCard(
                      context,
                      title: "Milk Selling",
                      icon: Icons.attach_money,
                      page: const SellMilkPage(),
                    ),
                    _buildDashboardCard(
                      context,
                      title: "Buy Milk Payment",
                      icon: Icons.assignment_turned_in,
                      page: const BuyMilkPaymentPage(),
                    ),
                    _buildDashboardCard(
                      context,
                      title: "Sell Milk Payment",
                      icon: Icons.assignment_turned_in,
                      page: const SellMilkPaymentPage(),
                    ),
                    _buildDashboardCard(
                      context,
                      title: "Settings",
                      icon: Icons.settings,
                      page: const SettingsScreen(),
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

  /// Flexible Dashboard Card (Supports Icon or Image)
  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    IconData? icon,
    String? imagePath,
    required Widget page,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Card(
        color: AppColors.cardColor, // Using the getter from color.dart
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 3,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imagePath != null)
                Image.asset(
                  imagePath,
                  height: 50,
                  width: 50,
                  fit: BoxFit.contain,
                )
              else if (icon != null)
                Icon(icon, size: 50, color: Colors.black),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
