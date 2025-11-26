import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../session_manager.dart';
import '../color.dart';
import '../reusable_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User data with default values
  String name = "Loading...";
  String password = "••••";
  String phone = "Loading...";
  String email = "Loading...";
  String dob = "Loading...";
  String gender = "Loading...";
  String profileImageBase64 = "";
  String userId = "";
  String userName = "";

  // Controllers for text fields
  late TextEditingController nameController;
  late TextEditingController passwordController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController dobController;
  late TextEditingController genderController;

  // Edit mode state
  bool isEditing = false;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with placeholder values
    nameController = TextEditingController();
    passwordController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    dobController = TextEditingController();
    genderController = TextEditingController();

    // Fetch user data from Firebase
    _fetchUserData();
  }

  @override
  void dispose() {
    // Clean up controllers
    nameController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    emailController.dispose();
    dobController.dispose();
    genderController.dispose();
    super.dispose();
  }

  // Fetch user data from Firebase for the logged-in user
  Future<void> _fetchUserData() async {
    try {
      // Check if user is logged in
      final bool isLoggedIn = await SessionManager.isLoggedIn();
      final Map<String, String> userData = await SessionManager.getUserData();

      print('Is logged in: $isLoggedIn');
      print('Session user data: $userData');

      if (!isLoggedIn || userData['userEmail'] == null) {
        setState(() {
          errorMessage = "No user logged in. Please login again.";
          isLoading = false;
        });
        return;
      }

      // Get the logged-in user's email and ID from session
      final String userEmail = userData['userEmail']!;
      final String loggedInUserId = userData['userId'] ?? '';
      userName = userData['userName'] ?? '';

      print('Fetching data for user: $userEmail, ID: $loggedInUserId');

      DocumentSnapshot userDoc;

      // Method 1: Try to get user by document ID (most reliable)
      if (loggedInUserId.isNotEmpty) {
        userDoc = await _firestore
            .collection('users')
            .doc(loggedInUserId)
            .get();
        print('User found by ID: ${userDoc.exists}');

        if (userDoc.exists) {
          await _loadUserData(userDoc);
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
        // Update session with the correct user ID
        await SessionManager.saveLoginSession(
          userType: userData['userType'] ?? 'User',
          userId: userDoc.id,
          userEmail: userEmail,
          userName: userData['userName'] ?? 'User',
        );
        await _loadUserData(userDoc);
        return;
      }

      // If no data found
      setState(() {
        errorMessage = "No user data found for the logged-in user";
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        errorMessage = "Error fetching data: $e";
        isLoading = false;
      });
    }
  }

  // Load user data from document
  Future<void> _loadUserData(DocumentSnapshot userDoc) async {
    final userData = userDoc.data() as Map<String, dynamic>;

    print('User data loaded: $userData');

    setState(() {
      userId = userDoc.id;
      name = userData['name']?.toString() ?? 'Not provided';
      phone = userData['phone']?.toString() ?? 'Not provided';
      email = userData['email']?.toString() ?? 'Not provided';
      dob = _formatDob(userData['dob']?.toString() ?? 'Not provided');
      gender = userData['gender']?.toString() ?? 'Not provided';
      password = userData['password']?.toString() ?? '••••';
      profileImageBase64 = userData['profileImageBase64']?.toString() ?? '';

      // Update controllers with fetched data
      nameController.text = name;
      phoneController.text = phone;
      emailController.text = email;
      dobController.text = dob;
      genderController.text = gender;
      passwordController.text = password;

      isLoading = false;
      errorMessage = null;
    });
  }

  // Format date of birth for display
  String _formatDob(String dob) {
    if (dob == 'Not provided') return dob;

    try {
      // Try to parse the stored format (yyyy-MM-dd)
      final parsedDate = DateTime.tryParse(dob);
      if (parsedDate != null) {
        return "${parsedDate.day}/${parsedDate.month}/${parsedDate.year}";
      }
      return dob; // Return original if parsing fails
    } catch (e) {
      return dob;
    }
  }

  // Parse date of birth for storage
  String _parseDob(String displayDob) {
    if (displayDob == 'Not provided') return '';

    try {
      final parts = displayDob.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final date = DateTime(year, month, day);
        return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      }
      return displayDob; // Return original if parsing fails
    } catch (e) {
      return displayDob;
    }
  }

  // Build profile image widget
  Widget _buildProfileImage() {
    if (profileImageBase64.isNotEmpty) {
      try {
        // Remove any prefix if present (e.g., "data:image/png;base64,")
        String base64Data = profileImageBase64;
        if (base64Data.contains(',')) {
          base64Data = base64Data.split(',').last;
        }

        return ClipOval(
          child: Image.memory(
            base64Decode(base64Data),
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultProfileImage();
            },
          ),
        );
      } catch (e) {
        print('Error decoding Base64 image: $e');
        return _buildDefaultProfileImage();
      }
    } else {
      return _buildDefaultProfileImage();
    }
  }

  // Default profile image widget
  Widget _buildDefaultProfileImage() {
    return ClipOval(
      child: Container(
        width: 100,
        height: 100,
        color: Colors.grey[300],
        child: Icon(Icons.person, size: 40, color: Colors.grey[600]),
      ),
    );
  }

  void toggleEditMode() {
    setState(() {
      if (isEditing) {
        // Save changes to Firebase when exiting edit mode
        _updateUserData();
      } else {
        // Enter edit mode
        isEditing = true;
      }
    });
  }

  void cancelEdit() {
    setState(() {
      // Reset controllers to original values
      nameController.text = name;
      phoneController.text = phone;
      emailController.text = email;
      dobController.text = dob;
      genderController.text = gender;
      passwordController.text = password;
      isEditing = false;
      errorMessage = null;
    });
  }

  // Update user data in Firebase
  Future<void> _updateUserData() async {
    try {
      if (userId.isEmpty) {
        throw Exception("No user ID available");
      }

      // Update using the document ID from session
      await _firestore.collection('users').doc(userId).update({
        'name': nameController.text,
        'phone': phoneController.text,
        'email': emailController.text,
        'dob': _parseDob(dobController.text), // Convert back to storage format
        'gender': genderController.text,
        'password': passwordController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update session with new name if changed
      if (userName != nameController.text) {
        final Map<String, String> userData = await SessionManager.getUserData();
        await SessionManager.saveLoginSession(
          userType: userData['userType'] ?? 'User',
          userId: userId,
          userEmail: emailController.text,
          userName: nameController.text,
        );
      }

      // Update local state
      setState(() {
        name = nameController.text;
        phone = phoneController.text;
        email = emailController.text;
        dob = dobController.text;
        gender = genderController.text;
        password = passwordController.text;
        isEditing = false;
        errorMessage = null;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error updating user data: $e');
      setState(() {
        errorMessage = "Error updating data: $e";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickAndUpdateImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image != null) {
      try {
        final bytes = await image.readAsBytes();
        final base64Image = base64Encode(bytes);

        if (userId.isEmpty) {
          throw Exception("No user ID available");
        }

        await _firestore.collection('users').doc(userId).update({
          'profileImageBase64': base64Image,
        });

        setState(() {
          profileImageBase64 = base64Image;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use the reusable header
              ReusableHeader(
                title: "Profile",
                icon: Icons.person,
                onBackPressed: () => Navigator.pop(context),
              ),

              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 50),
                        const SizedBox(height: 10),
                        Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _fetchUserData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            foregroundColor: AppColors.textOnGold,
                          ),
                          child: const Text('Retry'),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          // Profile image from Firebase Base64 or default
                          Container(
                            width: 100,
                            height: 100,
                            child: _buildProfileImage(),
                          ),

                          // Camera icon for editing (only shown in edit mode)
                          if (isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickAndUpdateImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.buttonColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.cardColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: AppColors.cardColor,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Profile Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileItem("Name", nameController, isEditing),
                          const SizedBox(height: 12),
                          _buildProfileItem(
                            "Password",
                            passwordController,
                            isEditing,
                            isPassword: true,
                          ),
                          const SizedBox(height: 12),
                          _buildProfileItem(
                            "Phone",
                            phoneController,
                            isEditing,
                          ),
                          const SizedBox(height: 12),
                          _buildProfileItem(
                            "Email",
                            emailController,
                            isEditing,
                          ),
                          const SizedBox(height: 12),
                          _buildProfileItem(
                            "Date of Birth",
                            dobController,
                            isEditing,
                          ),
                          const SizedBox(height: 12),
                          _buildProfileItem(
                            "Gender",
                            genderController,
                            isEditing,
                          ),
                          const SizedBox(height: 20),

                          // Error message
                          if (errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          // Edit/Save and Cancel Buttons
                          if (isEditing)
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: toggleEditMode,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.buttonColor,
                                          foregroundColor: AppColors.textOnGold,
                                          minimumSize: const Size(0, 48),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          "Update",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            letterSpacing: 1.1,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: cancelEdit,
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.buttonColorSecondary,
                                          minimumSize: const Size(0, 48),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          side: BorderSide(
                                            color: AppColors.buttonColor,
                                          ),
                                        ),
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            letterSpacing: 1.1,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Note: Tap the camera icon to update profile image',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: toggleEditMode,
                                    icon: Icon(
                                      Icons.edit,
                                      color: AppColors.textOnGold,
                                    ),
                                    label: const Text(
                                      "Edit Profile",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        letterSpacing: 1.1,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.buttonColor,
                                      minimumSize: const Size(0, 48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Improved profile item widget with better layout
  Widget _buildProfileItem(
    String title,
    TextEditingController controller,
    bool isEditing, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.inputFieldColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              if (isEditing)
                Expanded(
                  child: TextField(
                    controller: controller,
                    obscureText: isPassword,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 4,
                      ),
                      border: InputBorder.none,
                      hintText: "Enter $title",
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                )
              else
                Expanded(
                  child: Text(
                    isPassword ? '•' * 8 : controller.text,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}