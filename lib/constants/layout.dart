import 'package:flutter/material.dart';

class AppLayout {
  static const double tablet = 720;
  static const double desktop = 1100;
  static const double dockHeight = 68;
  static const double pageGutter = 20;
  static const double desktopGutter = 56;
  static const double radius = 8;
  static const double radiusSm = 6;
  static const double radiusLg = 14;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  static double gutter(BuildContext context) =>
      isDesktop(context) ? desktopGutter : pageGutter;

  static int portraitColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1400) return 6;
    if (width >= desktop) return 5;
    if (width >= tablet) return 4;
    return 2;
  }
}
