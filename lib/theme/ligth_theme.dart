import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
ThemeData  lightTheme = ThemeData(

    colorScheme: ColorScheme.light(
      secondary: Colors.white,
        onSecondary: Colors.blue
    ),
    textTheme: TextTheme(
        titleMedium:  GoogleFonts.poppins( fontSize: 24 ,fontWeight: FontWeight.w400 , color: Colors.black),
        titleSmall:  GoogleFonts.openSans( fontSize: 14 ,fontWeight: FontWeight.w400 , color: Colors.black)
    ),

);