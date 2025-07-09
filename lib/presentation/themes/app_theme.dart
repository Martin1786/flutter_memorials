import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Application theme configuration.
///
/// This class defines the light and dark themes for the memorials app,
/// including colors, typography, and component styles.
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Color palette
  static const Color _primaryColor = Color(0xFF2E7D32); // Dark green
  static const Color _primaryVariant = Color(0xFF1B5E20);
  static const Color _secondaryColor = Color(0xFF8BC34A); // Light green
  static const Color _secondaryVariant = Color(0xFF689F38);
  static const Color _surfaceColor = Color(0xFFFFFFFF);
  static const Color _errorColor = Color(0xFFD32F2F);
  static const Color _onPrimaryColor = Color(0xFFFFFFFF);
  static const Color _onSecondaryColor = Color(0xFF000000);
  static const Color _onSurfaceColor = Color(0xFF000000);
  static const Color _onErrorColor = Color(0xFFFFFFFF);

  // Dark theme colors
  static const Color _darkPrimaryColor = Color(0xFF4CAF50);
  static const Color _darkPrimaryVariant = Color(0xFF2E7D32);
  static const Color _darkSecondaryColor = Color(0xFF81C784);
  static const Color _darkSecondaryVariant = Color(0xFF4CAF50);
  static const Color _darkSurfaceColor = Color(0xFF121212);
  static const Color _darkErrorColor = Color(0xFFEF5350);
  static const Color _darkOnPrimaryColor = Color(0xFF000000);
  static const Color _darkOnSecondaryColor = Color(0xFF000000);
  static const Color _darkOnSurfaceColor = Color(0xFFFFFFFF);
  static const Color _darkOnErrorColor = Color(0xFF000000);

  /// Light theme for the application.
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color scheme
    colorScheme: const ColorScheme.light(
      primary: _primaryColor,
      primaryContainer: _primaryVariant,
      secondary: _secondaryColor,
      secondaryContainer: _secondaryVariant,
      surface: _surfaceColor,
      error: _errorColor,
      onPrimary: _onPrimaryColor,
      onSecondary: _onSecondaryColor,
      onSurface: _onSurfaceColor,
      // onBackground is deprecated; use onSurface instead
      onError: _onErrorColor,
    ),

    // App bar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: _primaryColor,
      foregroundColor: _onPrimaryColor,
      elevation: AppConstants.cardElevation,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _onPrimaryColor,
      ),
    ),

    // Card theme
    cardTheme: const CardThemeData(
      elevation: AppConstants.cardElevation,
    ),

    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: _onPrimaryColor,
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    ),

    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryColor,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: 8,
        ),
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
      filled: true,
      fillColor: _surfaceColor,
    ),

    // Floating action button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: _onPrimaryColor,
      elevation: 6,
    ),

    // Bottom navigation bar theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _surfaceColor,
      selectedItemColor: _primaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Typography
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: _onSurfaceColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: _onSurfaceColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: _onSurfaceColor,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: _onSurfaceColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _onSurfaceColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _onSurfaceColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: _onSurfaceColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: _onSurfaceColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: _onSurfaceColor,
      ),
    ),
  );

  /// Dark theme for the application.
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Color scheme
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimaryColor,
      primaryContainer: _darkPrimaryVariant,
      secondary: _darkSecondaryColor,
      secondaryContainer: _darkSecondaryVariant,
      surface: _darkSurfaceColor,
      error: _darkErrorColor,
      onPrimary: _darkOnPrimaryColor,
      onSecondary: _darkOnSecondaryColor,
      onSurface: _darkOnSurfaceColor,
      // onBackground is deprecated; use onSurface instead
      onError: _darkOnErrorColor,
    ),

    // App bar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkPrimaryColor,
      foregroundColor: _darkOnPrimaryColor,
      elevation: AppConstants.cardElevation,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _darkOnPrimaryColor,
      ),
    ),

    // Card theme
    cardTheme: const CardThemeData(
      elevation: AppConstants.cardElevation,
    ),

    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimaryColor,
        foregroundColor: _darkOnPrimaryColor,
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    ),

    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkPrimaryColor,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: 8,
        ),
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
      filled: true,
      fillColor: _darkSurfaceColor,
    ),

    // Floating action button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _darkPrimaryColor,
      foregroundColor: _darkOnPrimaryColor,
      elevation: 6,
    ),

    // Bottom navigation bar theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkSurfaceColor,
      selectedItemColor: _darkPrimaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Typography
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: _darkOnSurfaceColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: _darkOnSurfaceColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: _darkOnSurfaceColor,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: _darkOnSurfaceColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _darkOnSurfaceColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _darkOnSurfaceColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: _darkOnSurfaceColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: _darkOnSurfaceColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: _darkOnSurfaceColor,
      ),
    ),
  );
}
