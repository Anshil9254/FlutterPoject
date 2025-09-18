import 'package:flutter/material.dart';
import 'color.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // User data
  String name = "Johan Deo";
  String password = "1234";
  String mobile = "7854961444";
  String email = "j@gmail.com";
  String dob = "25/4/1996";
  String address = "24 Main st, Surat";

  // Controllers for text fields
  late TextEditingController nameController;
  late TextEditingController passwordController;
  late TextEditingController mobileController;
  late TextEditingController emailController;
  late TextEditingController dobController;
  late TextEditingController addressController;

  // Edit mode state
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current values
    nameController = TextEditingController(text: name);
    passwordController = TextEditingController(text: password);
    mobileController = TextEditingController(text: mobile);
    emailController = TextEditingController(text: email);
    dobController = TextEditingController(text: dob);
    addressController = TextEditingController(text: address);
  }

  @override
  void dispose() {
    // Clean up controllers
    nameController.dispose();
    passwordController.dispose();
    mobileController.dispose();
    emailController.dispose();
    dobController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void toggleEditMode() {
    setState(() {
      if (isEditing) {
        // Save changes when exiting edit mode
        name = nameController.text;
        password = passwordController.text;
        mobile = mobileController.text;
        email = emailController.text;
        dob = dobController.text;
        address = addressController.text;
      }
      isEditing = !isEditing;
    });
  }

  void cancelEdit() {
    setState(() {
      // Reset controllers to original values
      nameController.text = name;
      passwordController.text = password;
      mobileController.text = mobile;
      emailController.text = email;
      dobController.text = dob;
      addressController.text = address;
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (bgcolor),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),

              // Profile title
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (cardColor),
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
                child: Row(
                  children: const [
                    Icon(Icons.person, size: 26, color: Colors.black),
                    SizedBox(width: 10),
                    Text(
                      "Profile",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Profile Image
              Center(
                child: Stack(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage('assets/profile.png'),
                    ),
                    if (isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration:  BoxDecoration(
                            color: (buttonColor),
                            shape: BoxShape.circle,
                          ),
                          child:  Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: (cardColor),
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
                  color: (cardColor),
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
                    _buildEditableItem("Name", nameController, isEditing),
                    const SizedBox(height: 8),
                    _buildEditableItem("Password", passwordController, isEditing, isPassword: true),
                    const SizedBox(height: 8),
                    _buildEditableItem("Mobile", mobileController, isEditing),
                    const SizedBox(height: 8),
                    _buildEditableItem("Email", emailController, isEditing),
                    const SizedBox(height: 8),
                    _buildEditableItem("DOB", dobController, isEditing),
                    const SizedBox(height: 8),
                    _buildEditableItem("Address", addressController, isEditing),
                    const SizedBox(height: 20),

                    // Edit/Save and Cancel Buttons
                    if (isEditing) 
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: toggleEditMode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Update",
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: cancelEdit,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                side: const BorderSide(color: Colors.grey),
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: toggleEditMode,
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: const Text(
                            "Edit",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
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

  // Build editable or display item based on edit mode
  Widget _buildEditableItem(String title, TextEditingController controller, bool isEditing, {bool isPassword = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          if (isEditing)
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: isPassword,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            )
          else
            Flexible(
              child: Text(
                isPassword ? '•' * controller.text.length : controller.text,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }
}