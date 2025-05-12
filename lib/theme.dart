import 'package:flutter/material.dart';

class AppTheme {
  static const darkCanvas = Color(0xFF0E1213);
  static const neonGreen  = Color(0xFFB5FB67);
  static const darkGray   = Color(0xFF1E2122);
  static const mediumGray = Color(0xFF2D3032);
  static const lightGray  = Color(0xFF4D5154);
  static const textGray   = Color(0xFFAAAAAA);

  static const headingStyle = TextStyle(
    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white);
  static const subheadingStyle = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white);
  static const bodyStyle = TextStyle(fontSize: 16, color: Colors.white);
  static const captionStyle = TextStyle(fontSize: 14, color: textGray);

  static final primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: neonGreen,
    foregroundColor: darkCanvas,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  );

  static final secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: neonGreen,
    side: const BorderSide(color: neonGreen, width: 2),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  );

  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) => InputDecoration(
    labelText: labelText,
    hintText: hintText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    labelStyle: const TextStyle(color: textGray),
    hintStyle: const TextStyle(color: textGray),
    filled: true,
    fillColor: darkGray,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: neonGreen, width: 2),
    ),
  );

  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: darkCanvas,
    primaryColor: neonGreen,
    colorScheme: const ColorScheme.dark(
      primary: neonGreen, secondary: neonGreen, surface: darkCanvas),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkCanvas,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
    outlinedButtonTheme: OutlinedButtonThemeData(style: secondaryButtonStyle),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkGray,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: neonGreen, width: 2)),
    ),
  );
}
