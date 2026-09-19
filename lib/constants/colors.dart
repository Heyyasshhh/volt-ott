import 'package:flutter/material.dart';

class AppColors {
  static const Color colorBackground = Color(0xFF030507);
  static const Color colorInk = Color(0xFF030507);
  static const Color colorSurface = Color(0xFF07111F);
  static const Color colorSurfaceElevated = Color(0xFF0B1D35);
  static const Color colorPrimary = Color(0xFFFF6A00);
  static const Color colorPrimaryLight = Color(0xFFFFAA00);
  static const Color colorPrimaryDark = Color(0xFFCC4F00);
  static const Color colorAccent = Color(0xFF168CFF);
  static const Color colorElectric = Color(0xFF28B7FF);
  static const Color colorDeepBlue = Color(0xFF0B1D35);
  static const Color colorMidnight = Color(0xFF07111F);
  static const Color colorGold = Color(0xFFFFAA00);
  static const Color colorOrange = Color(0xFFFF6A00);
  static const Color colorSilver = Color(0xFFD9DDE2);
  static const Color colorChrome = Color(0xFFF5F7FA);
  static const Color colorNavShadow = Color(0xFF010204);
  static const Color colorHint = Color(0xFF7A8796);
  static const Color colorTextSecondary = Color(0xFFB7C2CF);
  static const Color colorTextMuted = Color(0xFF6E7B8A);
  static const Color colorInputFill = Color(0x140B1D35);
  static const Color colorInputBorder = Color(0x33D9DDE2);
  static const Color colorHairline = Color(0x22D9DDE2);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6A00), Color(0xFFFFAA00)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient energyTrail = LinearGradient(
    colors: [Color(0xFFFF6A00), Color(0xFF168CFF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF168CFF), Color(0xFF28B7FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandTextGradient = LinearGradient(
    colors: [Color(0xFFF5F7FA), Color(0xFFD9DDE2)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient cinemaWash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00030507),
      Color(0x66030507),
      Color(0xE6030507),
      Color(0xFF030507),
    ],
    stops: [0.0, 0.42, 0.78, 1.0],
  );

  static const LinearGradient chromeSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x00F5F7FA),
      Color(0x22D9DDE2),
      Color(0x00F5F7FA),
    ],
  );
}

class BrandAssets {
  static const String logo = 'assets/images/volt-logo.png';
  static const String mark = 'assets/images/volt-icon.png';
}
