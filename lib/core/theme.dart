import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

ThemeData lightTheme = ThemeData(
  primaryColor: kAppButtonColor,
  scaffoldBackgroundColor: kWhiteColor,
  textTheme: GoogleFonts.poppinsTextTheme(),
  appBarTheme: AppBarTheme(
    backgroundColor: kAppButtonColor,
    titleTextStyle: GoogleFonts.poppins(
      color: kMainBlackColor,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kMainBlackColor,
  scaffoldBackgroundColor: Colors.grey[900],
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
);
