import '../../core/constants/app_constants.dart';
import '../../domain/entities/memorial.dart';

/// Utility class for validating memorial data.
///
/// This class provides static methods for validating various aspects
/// of memorial data, including plot numbers, coordinates, and other fields.
class MemorialValidator {
  /// Validates a plot number format and range.
  ///
  /// [value] The plot number to validate.
  /// Returns null if valid, error message if invalid.
  static String? validatePlotNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.errorPlotNumberRequired;
    }

    final trimmedValue = value.trim();
    final plotRegex = RegExp(r'^[A-F]-\d{1,3}$');

    if (!plotRegex.hasMatch(trimmedValue)) {
      return AppConstants.errorPlotNumberFormat;
    }

    final parts = trimmedValue.split('-');
    if (parts.length != 2) {
      return AppConstants.errorPlotNumberFormat;
    }

    final number = int.tryParse(parts[1]);
    if (number == null ||
        number < AppConstants.minPlotNumber ||
        number > AppConstants.maxPlotNumber) {
      return AppConstants.errorPlotNumberRange;
    }

    return null;
  }

  /// Validates a burial section.
  ///
  /// [value] The section to validate.
  /// Returns null if valid, error message if invalid.
  static String? validateSection(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.errorSectionRequired;
    }

    final section = value.trim().toUpperCase();
    final validSections = BurialSection.values.map((s) => s.name);

    if (!validSections.contains(section)) {
      return 'Section must be one of: ${validSections.join(', ')}';
    }

    return null;
  }

  /// Validates a headstone material.
  ///
  /// [value] The material to validate.
  /// Returns null if valid, error message if invalid.
  static String? validateHeadstoneMaterial(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.errorMaterialRequired;
    }

    final material = value.trim().toLowerCase();
    final validMaterials = HeadstoneMaterial.values.map((m) => m.name);

    if (!validMaterials.contains(material)) {
      return 'Material must be one of: ${validMaterials.join(', ')}';
    }

    return null;
  }

  /// Validates coordinates (latitude and longitude).
  ///
  /// [latitude] The latitude coordinate.
  /// [longitude] The longitude coordinate.
  /// Returns null if valid, error message if invalid.
  static String? validateCoordinates(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) {
      return AppConstants.errorCoordinatesRequired;
    }

    if (latitude < -90 || latitude > 90) {
      return AppConstants.errorInvalidLatitude;
    }

    if (longitude < -180 || longitude > 180) {
      return AppConstants.errorInvalidLongitude;
    }

    return null;
  }

  /// Validates an inscription.
  ///
  /// [value] The inscription to validate.
  /// Returns null if valid, error message if invalid.
  static String? validateInscription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Inscription is optional
    }

    if (value.trim().length > AppConstants.maxInscriptionLength) {
      return 'Inscription must be no more than ${AppConstants.maxInscriptionLength} characters';
    }

    return null;
  }

  /// Validates a deceased name.
  ///
  /// [value] The name to validate.
  /// Returns null if valid, error message if invalid.
  static String? validateDeceasedName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Name is optional
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }

    if (value.trim().length > 100) {
      return 'Name must be no more than 100 characters';
    }

    return null;
  }

  /// Validates a date of death.
  ///
  /// [value] The date to validate.
  /// Returns null if valid, error message if invalid.
  static String? validateDateOfDeath(DateTime? value) {
    if (value == null) {
      return null; // Date is optional
    }

    final now = DateTime.now();
    if (value.isAfter(now)) {
      return 'Date of death cannot be in the future';
    }

    // Check if date is not too far in the past (e.g., more than 200 years)
    final minDate = DateTime(now.year - 200, now.month, now.day);
    if (value.isBefore(minDate)) {
      return 'Date of death cannot be more than 200 years ago';
    }

    return null;
  }

  /// Validates additional details.
  ///
  /// [details] The list of additional details to validate.
  /// Returns null if valid, error message if invalid.
  static String? validateAdditionalDetails(List<String> details) {
    if (details.isEmpty) {
      return null; // Additional details are optional
    }

    for (final detail in details) {
      if (detail.trim().isEmpty) {
        return 'Additional details cannot contain empty items';
      }

      if (detail.trim().length > 200) {
        return 'Each additional detail must be no more than 200 characters';
      }
    }

    return null;
  }

  /// Validates a complete memorial object.
  ///
  /// [memorial] The memorial to validate.
  /// Returns a map of field names to error messages, empty if valid.
  static Map<String, String> validateMemorial(Memorial memorial) {
    final errors = <String, String>{};

    // Validate required fields
    final plotNumberError = validatePlotNumber(memorial.plotNumber);
    if (plotNumberError != null) {
      errors['plotNumber'] = plotNumberError;
    }

    final sectionError = validateSection(memorial.section.name);
    if (sectionError != null) {
      errors['section'] = sectionError;
    }

    final materialError =
        validateHeadstoneMaterial(memorial.headstoneMaterial.name);
    if (materialError != null) {
      errors['headstoneMaterial'] = materialError;
    }

    // Validate optional fields
    final inscriptionError = validateInscription(memorial.inscription);
    if (inscriptionError != null) {
      errors['inscription'] = inscriptionError;
    }

    final nameError = validateDeceasedName(memorial.deceasedName);
    if (nameError != null) {
      errors['deceasedName'] = nameError;
    }

    final dateError = validateDateOfDeath(memorial.dateOfDeath);
    if (dateError != null) {
      errors['dateOfDeath'] = dateError;
    }

    final coordinatesError =
        validateCoordinates(memorial.latitude, memorial.longitude);
    if (coordinatesError != null) {
      errors['coordinates'] = coordinatesError;
    }

    final detailsError = validateAdditionalDetails(memorial.additionalDetails);
    if (detailsError != null) {
      errors['additionalDetails'] = detailsError;
    }

    return errors;
  }

  /// Checks if a plot number format is valid without checking range.
  ///
  /// [plotNumber] The plot number to check.
  /// Returns true if the format is valid.
  static bool isValidPlotNumberFormat(String plotNumber) {
    final plotRegex = RegExp(r'^[A-F]-\d{1,3}$');
    return plotRegex.hasMatch(plotNumber.trim());
  }

  /// Extracts the section letter from a plot number.
  ///
  /// [plotNumber] The plot number in format "A-123".
  /// Returns the section letter or null if invalid format.
  static String? extractSectionFromPlotNumber(String plotNumber) {
    if (!isValidPlotNumberFormat(plotNumber)) {
      return null;
    }

    return plotNumber.split('-')[0];
  }

  /// Extracts the number from a plot number.
  ///
  /// [plotNumber] The plot number in format "A-123".
  /// Returns the number as an integer or null if invalid format.
  static int? extractNumberFromPlotNumber(String plotNumber) {
    if (!isValidPlotNumberFormat(plotNumber)) {
      return null;
    }

    final parts = plotNumber.split('-');
    return int.tryParse(parts[1]);
  }
}
