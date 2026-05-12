import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.greyLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.white,
      error: AppColors.error,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      headlineLarge: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.black),
      headlineMedium: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.black),
      titleLarge: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.black),
      titleMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.black),
      bodyLarge: GoogleFonts.poppins(fontSize: 16, color: AppColors.black),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, color: AppColors.greyDark),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0, centerTitle: true,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      titleTextStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: AppColors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.grey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.grey.withOpacity(0.5))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}