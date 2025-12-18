import 'package:flutter/material.dart';

/// App-wide color palette
/// Sage Green (#6B8E23, #8FBC8F) for eco-friendly vibe
/// Clean White for backgrounds
/// Soft Gold for money/points
/// Dark Slate Grey for readable text
class AppColors {
  // Primary Colors - Sage Green Theme
  static const Color primary = Color(0xFF6B8E23); // Sage Green Dark
  static const Color primaryLight = Color(0xFF8FBC8F); // Sage Green Light
  static const Color primaryDark = Color(0xFF556B2F); // Dark Olive Green

  // Secondary Colors
  static const Color secondary = Color(0xFFFFD700); // Soft Gold
  static const Color secondaryLight = Color(0xFFFFE55C);

  // Neutral Colors
  static const Color background = Color(0xFFFFFFFF); // Clean White
  static const Color surface = Color(0xFFF5F5F5); // Off White
  static const Color cardBackground = Color(0xFFFAFAFA);

  // Text Colors
  static const Color textPrimary = Color(0xFF2F4F4F); // Dark Slate Grey
  static const Color textSecondary = Color(0xFF708090); // Slate Grey
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // Transaction Status Colors
  static const Color pending = Color(0xFFFFB74D);
  static const Color approved = Color(0xFF66BB6A);
  static const Color rejected = Color(0xFFEF5350);

  // Shadows & Overlays
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x66000000);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);
}
