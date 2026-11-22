import 'package:flutter/material.dart';

// All values below are taken from the Figma design.
class AppColors {
  static const Color background = Color(0xFFF0EDE4);
  static const Color primary = Color(0xFF004741);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xB5000000); // black 71%
  static const Color hint = Color(0x66000000); // black 40%
  static const Color white = Color(0xFFFFFFFF);
  static const Color shadow = Color(0x40000000); // black 25%
}

class AppSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double screenPadding = 24;
}

class AppRadius {
  static const double card = 16;
  static const double button = 16;
}

class AppFontSize {
  static const double small = 15;
  static const double body = 18;
  static const double button = 20;
  static const double subtitle = 20;
  static const double title = 35;
}

class AppShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4)),
  ];
}
