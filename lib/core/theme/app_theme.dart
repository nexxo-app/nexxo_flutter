import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF2196F3); // Blue Accent
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color backgroundLight = Color(0xFFF5F5F7);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Liquid Glass Colors
  static const Color glassLight = Color(0x99FFFFFF);
  static const Color glassDark = Color(0x991E1E1E);
  static const Color glassBorderLight = Color(0x33FFFFFF);
  static const Color glassBorderDark = Color(0x33FFFFFF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,

        surface: surfaceLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: GoogleFonts.robotoFlexTextTheme(ThemeData.light().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,

        surface: surfaceDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: GoogleFonts.robotoFlexTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }

  // Glassmorphism Decoration Helper
  static BoxDecoration glassDecoration({required bool isDark, Color? color}) {
    return BoxDecoration(
      color: color ?? (isDark ? glassDark : glassLight),
      borderRadius: BorderRadius.circular(24), // Slightly more rounded
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white.withValues(
                alpha: 0.6,
              ), // Increased visibility for light mode
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05), // Softer shadow
          blurRadius: 16,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
