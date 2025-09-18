import 'package:flutter/material.dart';
import 'userdashboard.dart';
import 'admin/admindashboard.dart'; 
import 'color.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String role = "User";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor, // Using the getter from color.dart
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Center(
                child: Column(
                  children: [
                    Image.asset("assets/logo.png", height: 300, width: 420),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // Container for all login elements with shadow
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.boxShadow,
                ),
                child: Column(
                  children: [
                    // Email field
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: AppColors.boxShadow,
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email, color: AppColors.textSecondary),
                          hintText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.inputFieldColor,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password field
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: AppColors.boxShadow,
                      ),
                      child: TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock, color: AppColors.textSecondary),
                          hintText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.inputFieldColor,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Role Selection
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.inputFieldColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: AppColors.boxShadow,
                      ),
                      child: Row(
                        children: [
                          const Text(
                            "Role : ", 
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary
                            ),
                          ),
                          Row(
                            children: [
                              Radio<String>(
                                value: "User",
                                groupValue: role,
                                activeColor: AppColors.buttonColor,
                                onChanged: (value) {
                                  setState(() {
                                    role = value!;
                                  });
                                },
                              ),
                              const Text(
                                "User",
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                              Radio<String>(
                                value: "Admin",
                                groupValue: role,
                                activeColor: AppColors.buttonColor,
                                onChanged: (value) {
                                  setState(() {
                                    role = value!;
                                  });
                                },
                              ),
                              const Text(
                                "Admin",
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Login button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: AppColors.elevatedButtonStyle,
                        onPressed: _handleLogin,
                        child: const Text(
                          "LOGIN",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
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

  void _handleLogin() {
    // Handle login logic here
    // ignore: avoid_print
    print("Login button pressed with role: $role");

    // Navigate to appropriate dashboard based on role
    if (role == "User") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Userdashboard()),
      );
    } else if (role == "Admin") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboard()),
      );
    }
  }
}