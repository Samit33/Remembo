// Suggested code may be subject to a license. Learn more: ~LicenseLog:3986981351.
import 'package:flutter/material.dart';

//Make a static class to keep this colors in
class UIColors {
  static const Color primaryColor = Color(0xFF007BFF);
  static const Color primaryColorLight = Color.fromARGB(255, 157, 205, 255);
  static const Color secondaryColor = Color(0xFF35B651);
  static const Color secondaryColorLight = Color.fromARGB(255, 194, 250, 189);
  static const Color secondaryBGColor = Color(0xFFD6FFDF);
  static const Color iconColor = Color.fromARGB(255, 253, 245, 245);
  static const Color disabledColor = Color.fromARGB(255, 214, 214, 214);
  static const Color accentColor = Color(0xffff8a67);
  static const Color errorColor = Color.fromARGB(255, 240, 86, 75);
  static const Color successColor = Color.fromARGB(255, 157, 248, 160);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color infoColor = Color(0xFF2196F3);
  static const Color dropShadowColor = Color.fromARGB(141, 201, 201, 201);
  static const Color headerColor = Color(0xFF333333);
  static const Color subHeaderColor = Color(0xFF666666);
  static const Color bodyColor = Color(0xFF999999);
  static const TextStyle headerTextStyle = TextStyle(
    color: headerColor,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  // Make a gradient color
  static const Color primaryGradientColor1 = Color(0xFF7472F5);
  static const Color primaryGradientColor2 = Color(0xFF3F68FA);
  static const Color secondaryGradientColor1 =
      Color.fromARGB(255, 84, 250, 120);
  static const Color secondaryGradientColor2 = Color.fromARGB(255, 76, 184, 99);

  // Add BoxShadow constants
  static const BoxShadow dropShadow = BoxShadow(
    color: dropShadowColor,
    spreadRadius: 2,
    blurRadius: 5,
    offset: Offset(0, 3),
  );

  static const BoxShadow lighterDropShadow = BoxShadow(
    color: dropShadowColor,
    blurRadius: 3,
    spreadRadius: 1,
    offset: Offset(0, 3),
  );
}
