import 'package:flutter/material.dart';
import 'constants.dart';

ThemeData lightTheme = ThemeData(
  primaryColor: kAppButtonColor,
  scaffoldBackgroundColor: kWhiteColor,
  appBarTheme: AppBarTheme(
    backgroundColor: kAppButtonColor,
    titleTextStyle: TextStyle(color: kMainBlackColor, fontSize: 20),
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kMainBlackColor,
  scaffoldBackgroundColor: Colors.grey[900],
);
