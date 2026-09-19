import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:volt/constants/colors.dart';
import 'package:volt/constants/layout.dart';

class AppTheme {
  static const String fontFamily = 'Inter';
  static const String displayFamily = 'Inter';

  static ThemeData dark() {
    const textTheme = TextTheme(
      displayLarge: TextStyle(
        fontFamily: displayFamily,
        fontSize: 44,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.8,
        height: 1.05,
      ),
      displayMedium: TextStyle(
        fontFamily: displayFamily,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.4,
        height: 1.1,
      ),
      headlineMedium: TextStyle(
        fontFamily: displayFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: -0.2,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.colorTextSecondary,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.colorSilver,
        letterSpacing: 0.4,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.colorBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.colorPrimary,
        secondary: AppColors.colorAccent,
        surface: AppColors.colorSurface,
        onPrimary: Color(0xFFF5F7FA),
        onSurface: Colors.white,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.colorBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        titleTextStyle: TextStyle(
          fontFamily: displayFamily,
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      dividerColor: AppColors.colorHairline,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.colorSurfaceElevated,
        contentTextStyle: const TextStyle(color: Colors.white, fontFamily: fontFamily),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppLayout.radius)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.colorAccent,
      ),
    );
  }
}

class AppTextStyles {
  static const TextStyle displayTitle = TextStyle(
    fontFamily: AppTheme.displayFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.08,
    letterSpacing: -0.6,
  );

  static const TextStyle editorial = TextStyle(
    fontFamily: AppTheme.displayFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.15,
    letterSpacing: -0.2,
  );

  static const TextStyle eyebrow = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.colorAccent,
    letterSpacing: 0.6,
    height: 1.2,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: AppTheme.displayFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: -0.2,
  );

  static const TextStyle seeAll = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.colorAccent,
  );

  static const TextStyle meta = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.colorTextSecondary,
    height: 1.45,
    letterSpacing: 0.1,
  );

  static const TextStyle chrome = TextStyle(
    fontFamily: AppTheme.fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.colorSilver,
    letterSpacing: 0.2,
  );
}
