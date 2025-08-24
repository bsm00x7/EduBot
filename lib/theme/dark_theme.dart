import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.light(
    secondary: Colors.black,
    onSecondary: Colors.white,
  ),
  textTheme: TextTheme(
    titleMedium: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
      titleSmall:  GoogleFonts.openSans( fontSize: 14 ,fontWeight: FontWeight.w400 , color: Colors.white)
  ),
);
