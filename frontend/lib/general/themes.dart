import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static Color white = const Color.fromRGBO(210, 203, 178, 0.25);
  static Color blue = const Color.fromARGB(253, 23, 13, 163);
  static Color appBarColor = Color.fromARGB(255, 29, 34, 36);
  static Color? kPrimaryColor = Color.fromARGB(255, 29, 34, 36);
  static Color? kPrimaryLightColor = Colors.yellow[200];
  static Color? chatColor = Colors.yellow[200];
}

class AppFonts {
  static TextStyle headerFont = GoogleFonts.kanit(
      letterSpacing: 3.5,
      fontSize: 40,
      color: AppColors.kPrimaryColor,
      fontWeight: FontWeight.bold);
}

class AppTimeFormats {}

// ignore: non_constant_identifier_names
Widget AppText(String text,
    {Color? color,
    double fontSize = 15,
    double? spacing,
    FontWeight? weight = FontWeight.normal,
    int? maxlines = 1,
    double minFontSize = 10,
    double stepGranularity = 1,
    TextAlign textAlign = TextAlign.start,
    TextOverflow overflow = TextOverflow.ellipsis,
    TextStyle? style}) {
  return AutoSizeText(
    text,
    style: style ??
        GoogleFonts.mavenPro(
            color: color,
            letterSpacing: spacing,
            fontWeight: weight,
            fontSize: fontSize),
    textAlign: textAlign,
    minFontSize: minFontSize,
    stepGranularity: stepGranularity,
    maxLines: maxlines,
  );
}