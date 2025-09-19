import 'package:flutter/material.dart';
import 'userdashboard.dart';
import 'admin/admindashboard.dart'; 
import 'color.dart';
import 'register_page.dart'; // Import the registration page

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String role = "User";
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Adjust layout based on screen size
          final bool isSmallScreen = constraints.maxHeight < 700;
          
          return SingleChildScrollView( // Wrap with SingleChildScrollView
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with responsive sizing
                    Image.asset(
                      "assets/logo.png", 
                      height: isSmallScreen ? 150 : 200,
                      width: isSmallScreen ? 200 : 280,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),

                    // Container for all login elements with shadow
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppColors.boxShadow,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email field
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: AppColors.boxShadow,
                              ),
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Password field
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: AppColors.boxShadow,
                              ),
                              child: TextFormField(
                                controller: _passwordController,
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Role Selection with compact layout
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.inputFieldColor,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: AppColors.boxShadow,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Role:", 
                                    style: TextStyle(
                                      fontSize: 14,
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
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                        onChanged: (value) {
                                          setState(() {
                                            role = value!;
                                          });
                                        },
                                      ),
                                      const Text(
                                        "User",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textPrimary
                                        ),
                                      ),
                                      Radio<String>(
                                        value: "Admin",
                                        groupValue: role,
                                        activeColor: AppColors.buttonColor,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                        onChanged: (value) {
                                          setState(() {
                                            role = value!;
                                          });
                                        },
                                      ),
                                      const Text(
                                        "Admin",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textPrimary
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Login button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: AppColors.elevatedButtonStyle,
                                onPressed: _handleLogin,
                                child: const Text(
                                  "LOGIN",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    letterSpacing: 1.1,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Register link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                    );
                                  },
                                  child: const Text(
                                    "Register now",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.buttonColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // Handle login logic here
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}