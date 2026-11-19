import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color primaryTeal = Color(0xFF0F766E);
  static const Color secondaryEmerald = Color(0xFF047857);
  static const Color darkBackground = Color(0xFF0B131E);
  static const Color darkSurface = Color(0xFF131F2E);
  static const Color darkCard = Color(0xFF1A2A3D);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryGold,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        secondary: primaryTeal,
        surface: darkSurface,
        background: darkBackground,
        onPrimary: Colors.black,
        onSurface: textLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: primaryGold),
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardTheme(
        color: darkCard,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: const TextStyle(color: primaryGold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGold, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryGold,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
