import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(

  colorScheme: ColorScheme.light(
    secondary: Colors.black,
    onSecondary: Colors.white,
  ),
  textTheme: TextTheme(
    titleMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      color: Colors.white,
      fontFamily: "Roboto"
    ),
      titleSmall: TextStyle( fontSize: 14 ,fontWeight: FontWeight.w400 , color: Colors.white)
  ),
);
