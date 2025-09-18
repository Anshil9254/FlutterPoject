// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/userdashboard.dart';
import 'screens/splash.dart';

void main() {
  runApp(FreshPourApp());
}

class FreshPourApp extends StatelessWidget {
  const FreshPourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
  '/': (context) => SplashScreen(),
  '/LoginScreen': (context) => LoginScreen(),
},

    );
  }
}