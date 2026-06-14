import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF207F56);
const Color primaryColor15 = Color(0xFF0F3D29);
const Color primaryContainerColor = Color(0xFFE0F3DC);
const Color onPrimaryColor = Color(0xFFFFFFFF);
const Color secondaryColor = Color(0xFFE3E8E6);
const Color pauseColor = Color(0xFFFFF9C2);
const Color outlineColor = Color(0xFFADEBD0);

const Color errorColor = Color(0xFFB3261E);
const Color errorContainerColor = Color(0xFFF7EDED);

const Color surfaceColor = Color(0xFFFFFFFF);
const Color onSurfaceColor = Color(0xFFF9FAFA);
const Color onSurfaceActiveColor = Color(0xFFF9F7FD);

const Color textPrimaryColor = Color(0xFF131615);
const Color textSecondaryColor = Color(0xFF5E6E67);
const Color textTertiaryColor = Color(0xFF91A19A);

final ThemeData baseTheme = ThemeData(
  useMaterial3: true,
  fontFamily: null,
  scaffoldBackgroundColor: surfaceColor,
  colorScheme: const ColorScheme.light(
    primary: primaryColor,
    primaryContainer: primaryContainerColor,
    onPrimary: onPrimaryColor,
    secondary: secondaryColor,
    surface: surfaceColor,
    onSurfaceVariant: onSurfaceActiveColor,
    error: errorColor,
    errorContainer: errorContainerColor,
  ),

  textTheme: const TextTheme(
    // H1 (Bold • 32)
    headlineLarge: TextStyle(
      color: textPrimaryColor,
      fontWeight: FontWeight.w700,
      fontSize: 32,
    ),

    // H2 (Bold • 24)
    headlineMedium: TextStyle(
      color: textPrimaryColor,
      fontWeight: FontWeight.w700,
      fontSize: 24,
    ),

    // H2 (Medium • 24)
    headlineSmall: TextStyle(
      color: textPrimaryColor,
      fontWeight: FontWeight.w500,
      fontSize: 24,
    ),

    // Body Regular • 16
    bodyLarge: TextStyle(
      color: textPrimaryColor,
      fontWeight: FontWeight.w400,
      fontSize: 16,
    ),

    // Body Medium • 16 
    bodyMedium: TextStyle(
      color: textPrimaryColor,
      fontWeight: FontWeight.w500,
      fontSize: 16,
    ),

    // Body Bold • 16 — зручно дати через titleMedium
    titleMedium: TextStyle(
      color: textPrimaryColor,
      fontWeight: FontWeight.w700,
      fontSize: 16,
    ),

    // Caption Regular • 12
    labelSmall: TextStyle(
      color: textSecondaryColor,
      fontWeight: FontWeight.w400,
      fontSize: 12,
    ),
  ),
);

final ThemeData lightTheme = baseTheme.copyWith(

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: onPrimaryColor,
      minimumSize: const Size(358, 56),
      elevation: 0, 
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      textStyle: baseTheme.textTheme.bodyMedium,
      alignment: Alignment.center,
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      backgroundColor: secondaryColor,
      foregroundColor: textPrimaryColor,
      minimumSize: const Size(358, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      side: BorderSide.none, 
      textStyle: baseTheme.textTheme.bodyMedium,
      alignment: Alignment.center,
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,

    fillColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.focused)) {
        return onSurfaceActiveColor;
      }
      return onSurfaceColor;
    }),

    hintStyle: baseTheme.textTheme.bodyLarge?.copyWith(
      color: textTertiaryColor,
    ),

    prefixIconColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.focused)) {
        return textPrimaryColor;
      }
      if (states.contains(WidgetState.error)) {
        return errorColor;
      }
      return textTertiaryColor;
    }),

    suffixIconColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.focused)) {
        return textPrimaryColor;
      }
      return textTertiaryColor;
    }),

    contentPadding: const EdgeInsets.symmetric(
      vertical: 20.0,
      horizontal: 16.0
    ),

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
      borderSide: BorderSide.none,
    ), 
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: surfaceColor,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    titleTextStyle: baseTheme.textTheme.headlineSmall,
    iconTheme: const IconThemeData(
      color: textPrimaryColor,
      size: 24
    ),
  ),

  bottomNavigationBarTheme: BottomNavigationBarThemeData (
    backgroundColor: onSurfaceColor,
    elevation: 0,

    selectedItemColor: primaryColor15,
    unselectedItemColor: textSecondaryColor,

    selectedLabelStyle: baseTheme.textTheme.labelSmall,
    unselectedLabelStyle: baseTheme.textTheme.labelSmall,
    
  ),

);
