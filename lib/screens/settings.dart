import 'package:dairyproject/screens/login_page.dart';
import 'package:dairyproject/screens/profile.dart';
import 'package:flutter/material.dart';
import 'color.dart';
import 'reusable_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use the reusable header
              ReusableHeader(
                title: "Settings",
                icon: Icons.settings,
                onBackPressed: () => Navigator.pop(context),
              ),

              // Settings options
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _settingsButton(context, Icons.person, "Account",
                        const ProfileScreen()),
                    const SizedBox(height: 16),
                    _settingsButton(context, Icons.lock, "Privacy and Security",
                        const PrivacyPage()),
                    const SizedBox(height: 16),
                    _settingsButton(
                        context, Icons.info, "About", const AboutPage()),
                    const SizedBox(height: 16),
                    _logoutButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Settings button widget
  static Widget _settingsButton(
      BuildContext context, IconData icon, String label, Widget page) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColors.boxShadow,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.black),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 18, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  // Logout button with different styling
  static Widget _logoutButton(BuildContext context) {
    return InkWell(
      onTap: () {
        _showLogoutConfirmationDialog(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.buttonColorSecondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.buttonColorSecondary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.logout, size: 24, color: AppColors.buttonColorSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                "Log Out",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.buttonColorSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Logout confirmation dialog
  static void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout, size: 48, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text(
                  "Log Out",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Are you sure you want to log out?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColorSecondary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        "Log Out",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
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
}

// Privacy Page
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text("Privacy & Security"),
        backgroundColor: const Color.fromRGBO(255, 242, 217, 1),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildCard(
                title: "Data Privacy",
                content:
                    "We respect your privacy and do not share your personal data with third parties without consent.",
              ),
              _buildCard(
                title: "Data Collection",
                content:
                    "We collect minimal information such as your name, email, and preferences to provide better services.",
              ),
              _buildCard(
                title: "User Control",
                content:
                    "You can update or delete your account information anytime from Settings.",
              ),
              _buildCard(
                title: "Security Measures",
                content:
                    "We use end-to-end encryption and regular audits to protect your data.",
              ),
              _buildCard(
                title: "Permissions",
                content:
                    "This app may request access to camera, location, or storage for specific features.",
              ),
              _buildCard(
                title: "Contact",
                content:
                    "If you have questions, contact us at support@example.com.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: AppColors.cardColor, // keep same card background
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(content, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

// About Page
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return _simplePage(context, "About");
  }
}

// Reusable simple page
Widget _simplePage(BuildContext context, String title) {
  return Scaffold(
    backgroundColor: AppColors.bgColor,
    appBar: AppBar(
      backgroundColor: const Color.fromRGBO(255, 242, 217, 1),
      title: Text(title, style: const TextStyle(color: Colors.black)),
      iconTheme: const IconThemeData(color: Colors.black),
      elevation: 0,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppColors.boxShadow,
            ),
            child: Text(
              "This is the $title page. Add your content here.",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    ),
  );
}
