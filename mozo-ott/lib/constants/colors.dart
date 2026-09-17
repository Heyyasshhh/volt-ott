import 'package:flutter/material.dart';

class AppColors {
  static const Color colorBackground = Color(0xFF070B18);
  static const Color colorSurface = Color(0xFF12182A);
  static const Color colorSurfaceElevated = Color(0xFF1A2238);
  static const Color colorPrimary = Color(0xFFD946EF);
  static const Color colorPrimaryLight = Color(0xFF22D3EE);
  static const Color colorPrimaryDark = Color(0xFF7C3AED);
  static const Color colorAccent = Color(0xFF22D3EE);
  static const Color colorNavShadow = Color(0xFF050814);
  static const Color colorHint = Color(0xFF8B8B97);
  static const Color colorTextSecondary = Color(0xFFA1A1AA);
  static const Color colorTextMuted = Color(0xFF6B7280);
  static const Color colorGold = Color(0xFFF5C542);
  static const Color colorInputFill = Color(0xFF12182A);
  static const Color colorInputBorder = Color(0xFF2A3350);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF472B6), Color(0xFFA855F7)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFE879F9), Color(0xFFA855F7), Color(0xFF38BDF8)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient brandTextGradient = LinearGradient(
    colors: [
      Color(0xFF22D3EE),
      Color(0xFF818CF8),
      Color(0xFFD946EF),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
