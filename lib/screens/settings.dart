import 'package:dairyproject/screens/login_page.dart';
import 'package:dairyproject/screens/profile.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
     // background cream color

    return Scaffold(
      backgroundColor: Color(0xFFFFFBEF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Settings Title
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.settings, size: 26, color: Colors.black),
                    SizedBox(width: 10),
                    Text(
                      "Settings",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Center all settings buttons
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _settingsButton(context, Icons.person, "Account", const ProfileScreen()),
                      const SizedBox(height: 12),
                      _settingsButton(context, Icons.lock, "Privacy and Security", const PrivacyPage()),
                      const SizedBox(height: 12),
                      _settingsButton(context, Icons.info, "About", const AboutPage()),
                      const SizedBox(height: 12),
                      _settingsButton(context, Icons.logout, "Log Out", const LoginScreen()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Button Widget with navigation
  static Widget _settingsButton(BuildContext context, IconData icon, String label, Widget page) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4D8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.black),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy Pages (Replace with your actual pages)

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});
  @override
  Widget build(BuildContext context) {
    return _simplePage(context, "Privacy & Security Page");
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return _simplePage(context, "About Page");
  }
}



// Reusable simple page
Widget _simplePage(BuildContext context, String title) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFFFFF4D8),
      title: Text(title, style: const TextStyle(color: Colors.black)),
      iconTheme: const IconThemeData(color: Colors.black),
    ),
    body: Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
