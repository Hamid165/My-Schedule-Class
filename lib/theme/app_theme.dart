import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Definisi tema aplikasi - light dan dark mode
class AppTheme {
  // ───────── Warna Utama ─────────
  static const Color primaryColor = Color(0xFF2D2D2D);
  static const Color accentColor = Color(0xFFD4A853);
  static const Color bgLight = Color(0xFFF8F5F0);
  static const Color bgDark = Color(0xFF1A1A1A);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2C2C2C);
  static const Color surfaceLight = Color(0xFFF0EBE3);
  static const Color surfaceDark = Color(0xFF242424);

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textLight = Color(0xFFE8E8E8);
  static const Color dividerLight = Color(0xFFE0DAD3);
  static const Color dividerDark = Color(0xFF3A3A3A);

  // ───────── Light Theme ─────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgLight,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceLight,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.dmSans(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.5),
        headlineLarge: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
        headlineMedium: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
        bodyLarge: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary),
        bodyMedium: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary),
        labelSmall: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: textSecondary, letterSpacing: 0.5),
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: dividerLight, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.dmSans(color: textSecondary, fontSize: 14),
        hintStyle: GoogleFonts.dmSans(color: textSecondary, fontSize: 14),
      ),
      dividerTheme: const DividerThemeData(color: dividerLight, thickness: 1, space: 0),
    );
  }

  // ───────── Dark Theme ─────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFD4A853),
        secondary: accentColor,
        surface: surfaceDark,
        onPrimary: Color(0xFF1A1A1A),
        onSurface: textLight,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.dmSans(fontSize: 32, fontWeight: FontWeight.w700, color: textLight, letterSpacing: -0.5),
        headlineLarge: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.w700, color: textLight),
        headlineMedium: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w600, color: textLight),
        titleLarge: GoogleFonts.dmSans(fontSize: 17, fontWeight: FontWeight.w600, color: textLight),
        titleMedium: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: textLight),
        bodyLarge: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w400, color: textLight),
        bodyMedium: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w400, color: const Color(0xFFAAAAAA)),
        labelSmall: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF888888), letterSpacing: 0.5),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: textLight),
        titleTextStyle: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w700, color: textLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: const Color(0xFF1A1A1A),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: dividerDark, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: accentColor, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF9A9A), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.dmSans(color: const Color(0xFF888888), fontSize: 14),
        hintStyle: GoogleFonts.dmSans(color: const Color(0xFF888888), fontSize: 14),
      ),
      dividerTheme: const DividerThemeData(color: dividerDark, thickness: 1, space: 0),
    );
  }
}
