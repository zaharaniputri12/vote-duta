import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1A237E);
  static const Color primaryDark = Color(0xFF0D1642);
  static const Color primaryLight = Color(0xFF3949AB);
  static const Color accent = Color(0xFFFFD700);
  static const Color accentDark = Color(0xFFDAA520);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1A1A1A);
  static const Color grey = Color(0xFF8E8E93);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyDark = Color(0xFF424242);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);
  static const Color white70 = Color(0xB3FFFFFF);

  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryLight, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}