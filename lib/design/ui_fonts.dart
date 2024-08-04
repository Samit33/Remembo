import 'dart:ui';

class UIFonts {
  static const String fontRegular = 'assets/fonts/CamptonBlack.otf';
  static const String fontBold = 'assets/fonts/CamptonBold.otf';
  static const String fontItalic = 'assets/fonts/italic.ttf';

  static TextStyle regularTextStyle = TextStyle(
    fontFamily: fontRegular,
    fontWeight: FontWeight.normal,
  );

  static TextStyle boldTextStyle = TextStyle(
    fontFamily: fontBold,
    fontWeight: FontWeight.bold,
  );

  static TextStyle italicTextStyle = TextStyle(
    fontFamily: fontItalic,
    fontStyle: FontStyle.italic,
  );
}
