import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user/userdashboard.dart';
import 'admin/admindashboard.dart'; 
import 'color.dart';
import 'register_page.dart';
import '../session_manager.dart'; // Import SessionManager

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
  bool _isLoading = false;
  bool _checkingAutoLogin = true;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    try {
      final bool isLoggedIn = await SessionManager.isLoggedIn();
      
      if (isLoggedIn) {
        // Auto-login user using SessionManager
        final Map<String, String> userData = await SessionManager.getUserData();
        final String? userEmail = userData['userEmail'];
        final String? userType = userData['userType'];

        if (userEmail != null && userType != null) {
          await _autoLoginUser(userEmail, userType);
        } else {
          setState(() {
            _checkingAutoLogin = false;
          });
        }
      } else {
        setState(() {
          _checkingAutoLogin = false;
        });
      }
    } catch (e) {
      print("Auto-login error: $e");
      setState(() {
        _checkingAutoLogin = false;
      });
    }
  }

  Future<void> _autoLoginUser(String email, String userRole) async {
    try {
      // Query Firestore to verify user still exists
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final userData = userDoc.data();
        
        // Navigate directly to appropriate dashboard
        if (userRole == "User") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Userdashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboard()),
          );
        }
      } else {
        // User no longer exists in database, clear saved data
        await SessionManager.clearSession();
        setState(() {
          _checkingAutoLogin = false;
        });
      }
    } catch (e) {
      print("Auto-login verification error: $e");
      setState(() {
        _checkingAutoLogin = false;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Query Firestore for user with matching email
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: _emailController.text.trim())
            .get();

        if (querySnapshot.docs.isEmpty) {
          // No user found with this email
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No account found with this email")),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Get the first matching user document
        final userDoc = querySnapshot.docs.first;
        final userData = userDoc.data();
        final String userId = userDoc.id;

        // Check if password matches (stored in plain text as requested)
        if (userData['password'] == _passwordController.text) {
          // Check if the selected role matches the user's role
          if (userData['role']?.toLowerCase() == role.toLowerCase()) {
            // Save login information using SessionManager
            await SessionManager.saveLoginSession(
              userType: role,
              userId: userId,
              userEmail: _emailController.text.trim(),
              userName: userData['name'] ?? 'User',
            );
            
            // Successful login - navigate to appropriate dashboard
            if (role == "User") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Userdashboard()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdminDashboard()),
              );
            }
          } else {
            // Role doesn't match
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("You are not registered as a $role")),
            );
          }
        } else {
          // Password doesn't match
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Incorrect password")),
          );
        }
      } catch (e) {
        print("Login error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred during login")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Add logout functionality to both dashboards
  static Future<void> logout(BuildContext context) async {
    await SessionManager.clearSession();
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking auto-login
    if (_checkingAutoLogin) {
      return Scaffold(
        backgroundColor: AppColors.bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.buttonColor),
              ),
              const SizedBox(height: 20),
              Text(
                "Checking login...",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              // Adjust layout based on screen size
              final bool isSmallScreen = constraints.maxHeight < 700;
              
              return SingleChildScrollView(
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
                                    onPressed: _isLoading ? null : _handleLogin,
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
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
          
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}