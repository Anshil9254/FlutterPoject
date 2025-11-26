import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'usermanagement.dart';
import 'milkcollection.dart';
import 'sellmilk.dart';
import 'buymilkpayment.dart';
import 'sellmilkpayment.dart';
import 'adminsettings.dart';
import '../color.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _adminData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    try {
      // Fetch admin data from Firestore 'users' collection where userId = 1
      final querySnapshot = await _firestore
          .collection('users')
          .where('userId', isEqualTo: 1)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _adminData = querySnapshot.docs.first.data();
          _isLoading = false;
        });
        print('Admin data fetched: ${_adminData?['name']}');
        print('Profile image field: ${_adminData?['profileImageBase64']}');
      } else {
        setState(() {
          _isLoading = false;
        });
        print('No admin user found');
      }
    } catch (e) {
      print('Error fetching admin data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

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
              // Welcome Section - Dynamic from Firestore
              _buildWelcomeSection(),
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
                      page: const Adminsettings(),
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

  Widget _buildWelcomeSection() {
    if (_isLoading) {
      return Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Loading...",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Please wait",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        // Profile Image - Using the same approach as UserManagement
        _buildProfileImage(),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, ${_adminData?['name'] ?? 'Admin'}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _adminData?['email'] ?? 'No email',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileImage() {
    final profileImage = _adminData?['profileImageBase64'];
    
    // If no profile image, show default avatar with first letter
    if (profileImage == null || profileImage.toString().isEmpty) {
      return _buildDefaultAvatar();
    }

    // Use the same approach as in UserManagement
    try {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: MemoryImage(base64Decode(profileImage)),
            fit: BoxFit.cover,
          ),
        ),
      );
    } catch (e) {
      print('Error loading profile image: $e');
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    final name = _adminData?['name']?.toString() ?? 'Admin';
    final firstName = name.split(' ').first;
    final firstLetter = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'A';
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getAvatarColor(name),
      ),
      child: Center(
        child: Text(
          firstLetter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    // Generate consistent color based on name
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];
    final index = name.length % colors.length;
    return colors[index];
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
        color: AppColors.cardColor,
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
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.image, size: 50, color: Colors.grey);
                  },
                )
              else if (icon != null)
                Icon(icon, size: 50, color: Colors.black),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}