import 'package:flutter/material.dart';

/// Application color palette
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF6D5DD3);
  static const Color secondary = Color(0xFFFF8A34);

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF9AA4B2);
  static const Color textHint = Color(0xFF999999);

  // Background Colors
  static const Color background = Color(0xFFFBFBFC);
  static const Color cardBackground = Colors.white;

  // Border Colors
  static const Color border = Color(0xFFE8E8E8);
  static const Color borderFocused = primary;
  static const Color borderError = Colors.red;

  // Icon Colors
  static const Color iconDefault = Color(0xFF999999);
  static const Color green = Color(0xFF10B981);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [secondary, primary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Shadow Colors
  static Color shadowLight = Colors.black.withOpacity(0.08);

  static const Color white = Colors.white;
}
