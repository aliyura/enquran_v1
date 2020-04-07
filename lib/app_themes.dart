import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  AppTheme._();

  static Color HexColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String language = "Both";
  static bool initialized = false;
  static Color background = Color(0xff323de9);
  static const Color nearlyWhite = Color(0xFFFAFAFA);
  static const Color white = Color(0xFFFFFFFF);

  static const Color nearlyBlack = Colors.black87;
  static const Color grey = Color(0xFF3A5160);
  static const Color dark_grey = Color(0xFF313A44);

  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Colors.black87;
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color spacer = Color(0xFFF2F2F2);
  static const String fontName = 'Roboto';

  static Color appColor = HexColor('#5961d6');
  static const TextStyle inpuStyle =
      TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  static const String appName = "Sliplus";

  static LinearGradient gradientBody = LinearGradient(colors: [
    AppTheme.appColor,
    Colors.red,
  ], begin: Alignment.topLeft, end: Alignment.bottomRight);

  static const TextTheme textTheme = TextTheme(
    display1: display1,
    headline: headline,
    title: title,
    subtitle: subtitle,
    body2: body2,
    body1: body1,
    caption: caption,
  );

  static const TextStyle display1 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: darkerText,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: darkerText,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: darkText,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: darkText,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.05,
    color: darkText,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.2,
    color: lightText, // was lightText
  );

  static initilizeTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String color = prefs.getString('background');
    String init = prefs.getString('init');

    if (color != null && color != '') {
      String valueString = color.split('(0x')[1].split(')')[0];
      int value = int.parse(valueString, radix: 16);
      Color currentColor = new Color(value);
      background = currentColor;
    }
      if (init != null && init != '') {
        initialized=true;
      }else{
        initialized=false;
      }

    initilizeLanguage(prefs);
  }

  static initilizeLanguage(SharedPreferences prefs) async {
    String chosenLanguage = prefs.getString('language');

    if (chosenLanguage != null && chosenLanguage != '') {
      language = chosenLanguage;
    }else{
      language="Both";
    }
  }
}
