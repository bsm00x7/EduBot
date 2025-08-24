import 'package:flutter/material.dart';

ThemeData  lightTheme = ThemeData(
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.light(
      secondary: Colors.white,
        onSecondary: Colors.blue,
        onPrimary: Colors.black
    ),
    textTheme: TextTheme(
        titleMedium:  TextStyle(  fontSize: 24 ,fontWeight: FontWeight.w300 , color: Colors.black),
        titleSmall:  TextStyle( fontSize: 14 ,fontWeight: FontWeight.w300, color: Colors.black)
    ),

);