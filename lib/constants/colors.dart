import 'package:flutter/material.dart';

class AppColors {
  static const Color colorBackground = Color(0xFF07070C);
  static const Color colorSurface = Color(0xFF12121A);
  static const Color colorSurfaceElevated = Color(0xFF1A1A24);
  static const Color colorPrimary = Color(0xFFFF3D8A);
  static const Color colorPrimaryLight = Color(0xFF22D3EE);
  static const Color colorPrimaryDark = Color(0xFF7C3AED);
  static const Color colorAccent = Color(0xFF38BDF8);
  static const Color colorNavShadow = Color(0xFF05050A);
  static const Color colorHint = Color(0xFF8B8B97);
  static const Color colorTextSecondary = Color(0xFFA1A1AA);
  static const Color colorTextMuted = Color(0xFF6B7280);
  static const Color colorGold = Color(0xFFF5C542);
  static const Color colorInputFill = Color(0xFF16161F);
  static const Color colorInputBorder = Color(0xFF2A2A36);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF4D9A), Color(0xFFA855F7)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFE879A8), Color(0xFFA855F7), Color(0xFF7C3AED)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient brandTextGradient = LinearGradient(
    colors: [
      Color(0xFFFF4D9A),
      Color(0xFFF5C542),
      Color(0xFF34D399),
      Color(0xFF38BDF8),
      Color(0xFFA855F7),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
