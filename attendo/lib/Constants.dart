import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const primaryColor = Color.fromRGBO(112, 231, 171, 1);
const secondaryColor = Color.fromRGBO(68, 103, 83, 1);

AppBarTheme customAppBarTheme = AppBarTheme(
  backgroundColor: primaryColor,
  iconTheme: IconThemeData(color: secondaryColor),
  titleTextStyle: GoogleFonts.poppins(
    color: secondaryColor,
    fontSize: 20.0,
  ),
);

ThemeData themeData = ThemeData(
  appBarTheme: customAppBarTheme,
  iconTheme: IconThemeData(color: secondaryColor),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(secondaryColor),
      backgroundColor: WidgetStateProperty.all(primaryColor),
      textStyle: WidgetStateProperty.all(
        GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: secondaryColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: secondaryColor, width: 2.0),
    ),
    labelStyle: GoogleFonts.poppins(color: secondaryColor),
    hintStyle: GoogleFonts.poppins(color: secondaryColor),
    prefixIconColor: secondaryColor
  ),
);
