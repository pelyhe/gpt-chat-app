import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static Color white = const Color.fromRGBO(210, 203, 178, 0.25);
  static Color blue = const Color.fromARGB(253, 23, 13, 163);
  static Color appColorBlue = const Color.fromARGB(252, 58, 46, 226);
  static Color kPrimaryColor = const Color(0xFF6F35A5);
  static Color kPrimaryLightColor = const Color(0xFFF1E6FF);
}

class AppFonts {
  static TextStyle headerFont = GoogleFonts.kanit(
      letterSpacing: 3.5,
      fontSize: 40,
      color: AppColors.kPrimaryColor,
      fontWeight: FontWeight.bold);
}

class AppTimeFormats {}
