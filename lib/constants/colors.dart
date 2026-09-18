import 'package:flutter/material.dart';

class AppColors {
  static const Color colorBackground = Color(0xFF030609);
  static const Color colorInk = Color(0xFF020407);
  static const Color colorSurface = Color(0xFF071426);
  static const Color colorSurfaceElevated = Color(0xFF0B2B55);
  static const Color colorPrimary = Color(0xFFFF6A00);
  static const Color colorPrimaryLight = Color(0xFFFFB000);
  static const Color colorPrimaryDark = Color(0xFFCC4F00);
  static const Color colorAccent = Color(0xFF008CFF);
  static const Color colorElectric = Color(0xFF20B8FF);
  static const Color colorDeepBlue = Color(0xFF0B2B55);
  static const Color colorMidnight = Color(0xFF071426);
  static const Color colorGold = Color(0xFFFFB000);
  static const Color colorOrange = Color(0xFFFF6A00);
  static const Color colorSilver = Color(0xFFD9DDE3);
  static const Color colorChrome = Color(0xFFF3F5F7);
  static const Color colorNavShadow = Color(0xFF010204);
  static const Color colorHint = Color(0xFF7A8796);
  static const Color colorTextSecondary = Color(0xFFB7C2CF);
  static const Color colorTextMuted = Color(0xFF6E7B8A);
  static const Color colorInputFill = Color(0x00000000);
  static const Color colorInputBorder = Color(0x55008CFF);
  static const Color colorHairline = Color(0x33D9DDE3);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6A00), Color(0xFFFFB000)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient energyTrail = LinearGradient(
    colors: [Color(0xFFFF6A00), Color(0xFFFFB000), Color(0xFF20B8FF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF008CFF), Color(0xFF20B8FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandTextGradient = LinearGradient(
    colors: [
      Color(0xFFFF6A00),
      Color(0xFFFFB000),
      Color(0xFFD9DDE3),
      Color(0xFF20B8FF),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient cinemaWash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00030609),
      Color(0x99030609),
      Color(0xF2030609),
    ],
  );

  static const LinearGradient chromeSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x00F3F5F7),
      Color(0x66D9DDE3),
      Color(0x00F3F5F7),
    ],
  );
}

class BrandAssets {
  static const String logo = 'assets/images/volt-logo.png';
  static const String mark = 'assets/images/volt-icon.png';
}
