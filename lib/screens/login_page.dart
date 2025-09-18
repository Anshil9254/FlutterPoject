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
      backgroundColor: (bgcolor), // Background color same
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

              // Email / Mobile field
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  hintText: "Email/Mobile No.",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Password field
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  hintText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              // Role Selection
              Row(
                children: [
                  const Text("Role : ", style: TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      Radio<String>(
                        value: "User",
                        groupValue: role,
                        onChanged: (value) {
                          setState(() {
                            role = value!;
                          });
                        },
                      ),
                      const Text("User"),
                      Radio<String>(
                        value: "Admin",
                        groupValue: role,
                        onChanged: (value) {
                          setState(() {
                            role = value!;
                          });
                        },
                      ),
                      const Text("Admin"),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (buttonColor), // Green button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _handleLogin,
                  child: const Text(
                    "LOGIN",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
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
