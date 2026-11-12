import 'package:flutter/material.dart';

/// KantinQ Design System Color Tokens
/// Mengikuti spesifikasi desing.md
class AppColors {
  AppColors._();

  // Primary Palette (Warm Appetite Coral / Sunset)
  static const Color primary = Color(0xFFFF5722);
  static const Color primaryDark = Color(0xFFD84315);
  static const Color primaryLight = Color(0xFFFFCCBC);
  static const Color primaryContainer = Color(0xFFFFEBE5);

  // Secondary Palette (Emerald Fresh Teal)
  static const Color secondary = Color(0xFF00897B);
  static const Color secondaryDark = Color(0xFF00695C);
  static const Color secondaryLight = Color(0xFFB2DFDB);
  static const Color secondaryContainer = Color(0xFFE0F2F1);

  // Accent Colors
  static const Color accent = Color(0xFFFFB300); // Amber Gold for ratings & promo
  static const Color accentLight = Color(0xFFFFF8E1);

  // Neutral Palette
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F5);
  static const Color outline = Color(0xFFE9ECEF);
  static const Color outlineVariant = Color(0xFFDEE2E6);

  // Typography Colors
  static const Color textPrimary = Color(0xFF1E2022);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textMuted = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Semantic / Status Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color successContainer = Color(0xFFE8F5E9);
  
  static const Color warning = Color(0xFFEF6C00);
  static const Color warningContainer = Color(0xFFFFF3E0);
  
  static const Color error = Color(0xFFD32F2F);
  static const Color errorContainer = Color(0xFFFFEBEE);

  static const Color info = Color(0xFF1976D2);
  static const Color infoContainer = Color(0xFFE3F2FD);

  // Shadows
  static const BoxShadow softShadow = BoxShadow(
    color: Color(0x0C000000),
    blurRadius: 16,
    offset: Offset(0, 4),
    spreadRadius: 0,
  );

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 12,
    offset: Offset(0, 3),
    spreadRadius: 0,
  );

  static const BoxShadow primaryShadow = BoxShadow(
    color: Color(0x28FF5722),
    blurRadius: 20,
    offset: Offset(0, 6),
    spreadRadius: 0,
  );
}
