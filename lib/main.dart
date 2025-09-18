// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/userdashboard.dart';
import 'screens/splash.dart';
<<<<<<< HEAD
<<<<<<< HEAD


=======
import '';
>>>>>>> fc03a063525718cbb5d313f4aadbdab21b01c0ed
=======
import '';
>>>>>>> fc03a063525718cbb5d313f4aadbdab21b01c0ed
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
