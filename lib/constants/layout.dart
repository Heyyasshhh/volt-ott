import 'package:flutter/material.dart';

class AppLayout {
  static const double tablet = 720;
  static const double desktop = 1100;
  static const double dockHeight = 72;
  static const double pageGutter = 22;
  static const double desktopGutter = 56;
  static const double radius = 4;
  static const double radiusSm = 2;
  static const double radiusLg = 18;

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
