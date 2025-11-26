// Updated color.dart (clean version)
import 'package:flutter/material.dart';

class AppColors {
  // Main colors
  static const Color bgColor = Color(0xFFFFFEEF); // Beige background
  static const Color cardColor = Color(0xFFFFF2D9); // White for cards
  static const Color buttonColor = Color(0xFF1F6C3B); // Gold color for buttons
  static const Color buttonColorSecondary = Color(0xFFF44336); 
  static const Color successColor = Color(0xFF4CAF50); // Green color for success

  // Input fields and containers
  static const Color inputFieldColor = Color(0xFFFFFCEA); // Light yellow for input fields
  
  // Gold color variations
  static const Color gold = Color(0xFFDCCB87); // Primary gold
  static const Color goldDark = Color(0xFFC4B379); // Darker gold
  static const Color goldLight = Color(0xFFFFFCEA); // Lighter gold (same as inputFieldColor)
  
  // Text colors
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.black54;
  static const Color textOnGold = Colors.black;
  
  // Shadow colors
  static const Color shadowColor = Color(0x1A000000); // Black with 10% opacity
  
  // Method to get color scheme for date picker
  static ColorScheme get datePickerColorScheme {
    return const ColorScheme.light(
      primary: AppColors.gold, // Gold color for selected date
      onPrimary: AppColors.textOnGold, // Text color for selected date
    );
  }
  
  // Method to get dialog theme
  static DialogTheme get dialogTheme {
    return DialogTheme(
      backgroundColor: AppColors.bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
  
  // Method to get box shadow
  static List<BoxShadow> get boxShadow {
    return [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        spreadRadius: 1,
        blurRadius: 3,
        offset: const Offset(0, 1),
      ),
    ];
  }
  
  // Method to get elevated button style
  static ButtonStyle get elevatedButtonStyle {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonColor,
      foregroundColor: AppColors.textOnGold,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
    );
  }
}