import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

const ColorScheme _lightColorScheme = ColorScheme.light(
  primary: kPurpleColor,
  onPrimary: kWhiteColor,
  secondary: kBrownColor,
  onSecondary: kWhiteColor,
  background: kWhiteColor,
  onBackground: kMainBlackColor,
  surface: kWhiteColor,
  onSurface: kMainBlackColor,
);

const ColorScheme _darkColorScheme = ColorScheme.dark(
  primary: kPurpleColor,
  onPrimary: kWhiteColor,
  secondary: kBrownColor,
  onSecondary: kWhiteColor,
  background: Color(0xFF121212),
  onBackground: kWhiteColor,
  surface: Color(0xFF1E1E1E),
  onSurface: kWhiteColor,
);

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _lightColorScheme,
  cupertinoOverrideTheme: const CupertinoThemeData(primaryColor: kAppButtonColor),
  scaffoldBackgroundColor: _lightColorScheme.background,
  textTheme: GoogleFonts.poppinsTextTheme(),
  appBarTheme: AppBarTheme(
    backgroundColor: _lightColorScheme.primary,
    foregroundColor: _lightColorScheme.onPrimary,
    titleTextStyle: GoogleFonts.poppins(
      color: _lightColorScheme.onPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  cardTheme: CardTheme(
    color: kGlassLight,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    },
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _darkColorScheme,
  scaffoldBackgroundColor: _darkColorScheme.background,
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
  appBarTheme: AppBarTheme(
    backgroundColor: _darkColorScheme.primary,
    foregroundColor: _darkColorScheme.onPrimary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _darkColorScheme.primary,
      foregroundColor: _darkColorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  cardTheme: CardTheme(
    color: kGlassDark,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    },
  ),
);
