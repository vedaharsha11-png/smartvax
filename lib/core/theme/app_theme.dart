import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xff080c55);
  static const blue = Color(0xff0878FF);
  static const cyan = Color(0xff21CEEF);
  static const violet = Color(0xff9258F5);
  static const lavender = Color(0xffC9B8FF);
  static const pink = Color(0xffF367B1);
  static const mint = Color(0xff18BE99);
  static const light = Color(0xffF4F9FF);
  static const secondary = Color(0xff466391);
  static const amber = Color(0xffE8A33B);
}

ThemeData buildTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: 'Nunito',
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.blue,
    primary: AppColors.blue,
    secondary: AppColors.violet,
    surface: Colors.white,
  ),
  textTheme: const TextTheme(
    headlineSmall: TextStyle(
      color: AppColors.navy,
      fontWeight: FontWeight.w800,
      letterSpacing: -.6,
    ),
    titleLarge: TextStyle(
      color: AppColors.navy,
      fontWeight: FontWeight.w800,
      letterSpacing: -.3,
    ),
    titleMedium: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w700),
    bodyLarge: TextStyle(color: AppColors.navy, height: 1.35),
    bodyMedium: TextStyle(color: AppColors.secondary, height: 1.35),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.white.withValues(alpha: .75),
    selectedColor: const Color(0xffb6dcff),
    side: const BorderSide(color: Colors.white, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    labelStyle: const TextStyle(
      color: AppColors.navy,
      fontWeight: FontWeight.w700,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: Colors.white.withValues(alpha: .46),
      side: const BorderSide(color: Colors.white, width: 1.6),
      minimumSize: const Size(48, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      textStyle: const TextStyle(
        fontFamily: 'Nunito',
        fontWeight: FontWeight.w800,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withValues(alpha: .62),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: .9)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: .9)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.navy,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
);
