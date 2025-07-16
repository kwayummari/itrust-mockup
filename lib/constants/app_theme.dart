import 'package:flutter/material.dart';
import 'package:iwealth/constants/app_color.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColor().mainColor,
    primaryColor: AppColor().blueBTN,

    cardColor: Colors.white,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColor().mainColor,
      elevation: 0,
      surfaceTintColor: AppColor().mainColor,
      titleTextStyle: TextStyle(
        color: AppColor().textColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColor().blueBTN,
        foregroundColor: AppColor().constant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    ),
    // Add more light theme configurations
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    primaryColor: AppColor().blueBTN,
    cardColor: const Color(0xFF1E1E1E),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
    // Add more dark theme configurations
  );

  static Color getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF121212) : Colors.grey[50]!;
  }

  static Color getCardColor(bool isDarkMode) {
    return isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  }

  static Color getTextColor(bool isDarkMode) {
    return isDarkMode ? Colors.white : Colors.black87;
  }
}
