import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FreshPourApp());
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