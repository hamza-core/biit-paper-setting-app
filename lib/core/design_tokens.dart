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
  static const Color border = Color(0xFFE0DBCE);
  static const Color greyText = Color(0xFF666666);
  static const Color lightGreyText = Color(0xFF999999);
  static const Color inactiveTab = Color(0xFFAAAAAA);
  static const Color signOutBackground = Color(0xFFFADBD8);
  static const Color signOutText = Color(0xFF900C0F);
  static const Color cardBorder = Color(0xFFE0DED6);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color successBackground = Color(0xFFE8F5E9);
  static const Color warningBackground = Color(0xFFFFEBEE);
  static const Color warningText = Color(0xFFE65100);
  static const Color disabledButton = Color(0xFFE0DBCE);
  static const Color deleteRed = Color(0xFFC62828);
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
  static const double tiny = 10;
  static const double caption = 12;
  static const double label = 13;
  static const double medium = 16;
  static const double small = 15;
  static const double heading = 20;
  static const double profileName = 22;
  static const double body = 18;
  static const double button = 20;
  static const double subtitle = 20;
  static const double title = 35;
}

class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> soft = [
    BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: Offset(0, 4)),
  ];
}
