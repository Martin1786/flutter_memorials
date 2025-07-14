import 'package:flutter/material.dart';

/// Application constants used throughout the memorials_flutter app.
///
/// This file contains all the constant values that are used across
/// different parts of the application, including database names,
/// validation rules, and default values.
class AppConstants {
  // Database constants
  static const String memorialsBox = 'memorials';
  static const String sectionsBox = 'sections';
  static const String photosBox = 'photos';

  // Validation constants
  static const int minPlotNumber = 1;
  static const int maxPlotNumber = 500;
  static const int maxPhotoSize = 1024 * 1024; // 1MB
  static const int maxInscriptionLength = 1000;

  // Default values
  static const String defaultSection = 'A';
  static const String defaultMaterial = 'granite';

  // UI constants
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 8.0;
  static const double cardElevation = 4.0;
  static const double borderRadius = 8.0;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Error messages
  static const String errorPlotNumberRequired = 'Plot number is required';
  static const String errorPlotNumberFormat =
      'Plot number must be in format A-123';
  static const String errorPlotNumberRange =
      'Plot number must be between 1 and 500';
  static const String errorSectionRequired = 'Section is required';
  static const String errorMaterialRequired = 'Headstone material is required';
  static const String errorCoordinatesRequired = 'Coordinates are required';
  static const String errorInvalidLatitude = 'Invalid latitude';
  static const String errorInvalidLongitude = 'Invalid longitude';

  // Success messages
  static const String successMemorialSaved = 'Memorial saved successfully';
  static const String successMemorialDeleted = 'Memorial deleted successfully';
  static const String successPhotoUploaded = 'Photo uploaded successfully';

  // App information
  static const String appName = "St. John's Memorials";
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Churchyard Memorial Management App';

  // Global UI colors
  static const Color nameWithPhotoColor = Colors.green;
}
