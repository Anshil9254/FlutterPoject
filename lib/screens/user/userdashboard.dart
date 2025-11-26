import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../session_manager.dart';
import '../color.dart';
import 'milkhistory.dart';
import 'invoice.dart';
import 'paymenthistory.dart';
import 'settings.dart';
import 'profile.dart';

// Main Dashboard
class Userdashboard extends StatefulWidget {
  const Userdashboard({super.key});

  @override
  State<Userdashboard> createState() => _UserdashboardState();
}

class _UserdashboardState extends State<Userdashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Dynamic dashboard data
  double _todaySupply = 0.0;
  double _outstandingAmount = 0.0;
  double _currentMonthBill = 0.0;
  int _todayEntriesCount = 0;

  // User ID and Name for navigation
  String _userId = '';
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      // Check if user is logged in using SessionManager
      final bool isLoggedIn = await SessionManager.isLoggedIn();
      final Map<String, String> userData = await SessionManager.getUserData();
      
      print('Is logged in: $isLoggedIn');
      print('Session user data: $userData');

      if (!isLoggedIn || userData['userEmail'] == null) {
        setState(() {
          _errorMessage = "No user logged in. Please login again.";
          _isLoading = false;
        });
        return;
      }

      // Get the logged-in user's email and ID from session
      final String userEmail = userData['userEmail']!;
      final String loggedInUserId = userData['userId'] ?? '';
      final String userName = userData['userName'] ?? '';

      print('Fetching data for user: $userEmail, ID: $loggedInUserId');

      DocumentSnapshot userDoc;

      // Method 1: Try to get user by document ID (most reliable)
      if (loggedInUserId.isNotEmpty) {
        userDoc = await _firestore.collection('users').doc(loggedInUserId).get();
        print('User found by ID: ${userDoc.exists}');
        
        if (userDoc.exists) {
          await _loadUserData(userDoc, loggedInUserId, userName);
          await _fetchDashboardData(loggedInUserId);
          return;
        }
      }

      // Method 2: Try to get user by email (fallback)
      final QuerySnapshot usersSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      print('Users found by email: ${usersSnapshot.docs.length}');

      if (usersSnapshot.docs.isNotEmpty) {
        userDoc = usersSnapshot.docs.first;
        final userId = userDoc.id;
        final userData = userDoc.data() as Map<String, dynamic>;
        final String name = userData['name'] ?? 'User';
        await _loadUserData(userDoc, userId, name);
        await _fetchDashboardData(userId);
        return;
      }

      // If no data found
      setState(() {
        _errorMessage = "No user data found for the logged-in user";
        _isLoading = false;
      });

    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _errorMessage = "Error fetching data: $e";
        _isLoading = false;
      });
    }
  }

  // Load user data from document
  Future<void> _loadUserData(DocumentSnapshot userDoc, String userId, String userName) async {
    final userData = userDoc.data() as Map<String, dynamic>;
    
    print('User data loaded: $userData');
    
    setState(() {
      _userData = userData;
      _userId = userId;
      _userName = userName;
    });
  }

  // Fetch dynamic dashboard data
  Future<void> _fetchDashboardData(String userId) async {
    try {
      final DateTime today = DateTime.now();
      final DateTime firstDayOfMonth = DateTime(today.year, today.month, 1);
      
      // Fetch milk collection data
      final milkDoc = await _firestore.collection('milk').doc(userId).get();
      
      double todaySupply = 0.0;
      double currentMonthBill = 0.0;
      int todayEntriesCount = 0;

      if (milkDoc.exists && milkDoc.data()?['milkEntries'] != null) {
        final Map<String, dynamic> milkEntries = milkDoc.data()!['milkEntries'];
        
        milkEntries.forEach((key, entry) {
          if (entry is Map<String, dynamic>) {
            final Timestamp entryDate = entry['date'] ?? Timestamp.now();
            final DateTime entryDateTime = entryDate.toDate();
            final double quantity = (entry['quantity'] ?? 0.0).toDouble();
            final double totalPrice = (entry['totalPrice'] ?? 0.0).toDouble();

            // Check if entry is from today
            if (_isSameDay(entryDateTime, today)) {
              todaySupply += quantity;
              todayEntriesCount++;
            }

            // Check if entry is from current month
            if (entryDateTime.isAfter(firstDayOfMonth.subtract(const Duration(days: 1)))) {
              currentMonthBill += totalPrice;
            }
          }
        });
      }

      // Calculate outstanding amount (TotalAmount - paidAmount)
      double outstandingAmount = 0.0;
      if (milkDoc.exists) {
        final milkData = milkDoc.data()!;
        final double totalAmount = (milkData['TotalAmount'] ?? 0.0).toDouble();
        final double paidAmount = (milkData['paidAmount'] ?? 0.0).toDouble();
        outstandingAmount = totalAmount - paidAmount;
      }

      setState(() {
        _todaySupply = todaySupply;
        _outstandingAmount = outstandingAmount;
        _currentMonthBill = currentMonthBill;
        _todayEntriesCount = todayEntriesCount;
        _isLoading = false;
        _errorMessage = '';
      });

      print('Dashboard data loaded:');
      print('Today Supply: $todaySupply L');
      print('Outstanding Amount: ₹$outstandingAmount');
      print('Current Month Bill: ₹$currentMonthBill');
      print('Today Entries Count: $todayEntriesCount');

    } catch (e) {
      print('Error fetching dashboard data: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = "Error loading dashboard data: $e";
      });
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // Refresh method
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    await _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    // Quick buttons data with navigation - Now using functions to create pages
    final List<Map<String, dynamic>> quickButtons = [
      {
        "icon": "assets/milk_bottle.png",
        "isAsset": true,
        "label": "View Milk History",
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MilkHistoryPage()),
          );
        },
      },
      {
        "icon": Icons.receipt_long,
        "isAsset": false,
        "label": "View Invoices",
        "onTap": _userId.isNotEmpty ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InvoicePage(
                userId: _userId,
                userName: _userName,
              ),
            ),
          );
        } : null,
      },
      {
        "icon": Icons.access_time,
        "isAsset": false,
        "label": "Payment History",
        "onTap": _userId.isNotEmpty ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentHistoryPage(userId: _userId), // FIX: Added userId parameter
            ),
          );
        } : null,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Welcome with User Info - Dynamic
              _buildWelcomeSection(),
              const SizedBox(height: 20),

              // Show error message if any
              if (_errorMessage.isNotEmpty) _buildErrorSection(),

              const Text(
                "Customer Dashboard",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Dashboard Cards - Arranged like the second example
              Row(
                children: [
                  Expanded(
                    child: _dashboardCard(
                      "${_todaySupply.toStringAsFixed(1)} L",
                      "Today's Supply",
                      subtitle: _todayEntriesCount > 0 ? "${_todayEntriesCount} entries" : "No entries today",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dashboardCard(
                      "₹ ${_outstandingAmount.toStringAsFixed(0)}",
                      "Outstanding Amount",
                      subtitle: _outstandingAmount > 0 ? "Payment pending" : "All paid",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _dashboardCard(
                "₹ ${_currentMonthBill.toStringAsFixed(0)}",
                "Current Month Bill",
                subtitle: "As of ${DateFormat('dd MMM').format(DateTime.now())}",
                center: false,
              ),
              const SizedBox(height: 20),

              const Text(
                "Quick Actions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: _isLoading 
                    ? _buildLoadingQuickButtons()
                    : ListView.separated(
                        itemCount: quickButtons.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final button = quickButtons[index];
                          return _quickButton(
                            button['icon'],
                            button['label'],
                            isAsset: button['isAsset'],
                            onTap: button['onTap'],
                            isDisabled: button['onTap'] == null,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _errorMessage.isNotEmpty
          ? FloatingActionButton(
              onPressed: _refreshData,
              backgroundColor: AppColors.buttonColor,
              child: const Icon(Icons.refresh, color: Colors.white),
            )
          : null,

      // Bottom Navigation Bar
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: 0,
            backgroundColor: AppColors.bgColor,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black87,
            selectedLabelStyle: const TextStyle(fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Userdashboard()),
                );
              } else if (index == 1) {
                if (_userId.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InvoicePage(
                        userId: _userId,
                        userName: _userName,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please wait while we load your data"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
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
        ),
      ),
    );
  }

  // Welcome Section Widget
  Widget _buildWelcomeSection() {
    if (_isLoading) {
      return Row(
        children: [
          Container(
            width: 56,
            height: 56,
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
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Please wait",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (_userData == null) {
      return Row(
        children: [
          _buildPlaceholderAvatar(),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome, User",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "User data not available",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        // Profile Image - Dynamic
        _buildProfileImage(),
        const SizedBox(width: 12),
        // User Info - Dynamic
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome, ${_userData?["name"] ?? "User"}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "User ID: ${_userData?["userId"] ?? "N/A"}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              Text(
                _userData?["email"] ?? "No email",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Error Section Widget
  Widget _buildErrorSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.red[600], size: 20),
            onPressed: _refreshData,
          ),
        ],
      ),
    );
  }

  // Loading state for quick buttons
  Widget _buildLoadingQuickButtons() {
    return ListView.separated(
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppColors.boxShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 120,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Profile Image Widget
  Widget _buildProfileImage() {
    final profileImage = _userData?["profileImageBase64"];
    
    // Check if base64 string is valid and complete
    bool isValidBase64 = profileImage != null && 
                        profileImage.toString().isNotEmpty &&
                        profileImage.toString().length > 100;

    if (isValidBase64) {
      try {
        // Remove any prefix if present (e.g., "data:image/png;base64,")
        String base64Data = profileImage.toString();
        if (base64Data.contains(',')) {
          base64Data = base64Data.split(',').last;
        }
        
        return CircleAvatar(
          radius: 28,
          backgroundColor: Colors.black12,
          backgroundImage: MemoryImage(
            base64Decode(base64Data),
          ),
        );
      } catch (e) {
        print('Error decoding profile image: $e');
        return _buildDefaultAvatar();
      }
    } else {
      // Show placeholder with first letter if no valid image
      return _buildDefaultAvatar();
    }
  }

  // Default Avatar with first letter
  Widget _buildDefaultAvatar() {
    final name = _userData?['name']?.toString() ?? 'User';
    final firstName = name.split(' ').first;
    final firstLetter = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U';
    
    return CircleAvatar(
      radius: 28,
      backgroundColor: _getAvatarColor(name),
      child: Text(
        firstLetter,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Placeholder Avatar (fallback)
  Widget _buildPlaceholderAvatar() {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.black12,
      child: Icon(Icons.person, size: 30, color: Colors.black),
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

  // Dashboard card widget
  Widget _dashboardCard(
    String value,
    String label, {
    String? subtitle,
    bool center = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.boxShadow,
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
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Quick Button widget
  Widget _quickButton(
    dynamic icon,
    String label, {
    VoidCallback? onTap,
    bool isAsset = false,
    bool isDisabled = false,
  }) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[300] : AppColors.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColors.boxShadow,
        ),
        child: Row(
          children: [
            isAsset
                ? Image.asset(
                    icon,
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                    color: isDisabled ? Colors.grey[600] : null,
                  )
                : Icon(
                    icon, 
                    size: 22, 
                    color: isDisabled ? Colors.grey[600] : Colors.black
                  ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16, 
                color: isDisabled ? Colors.grey[600] : Colors.black
              ),
            ),
            if (isDisabled) ...[
              const SizedBox(width: 8),
              const Icon(Icons.info_outline, size: 16, color: Colors.orange),
            ],
          ],
        ),
      ),
    );
  }
}