// Hive model temporarily disabled to avoid build errors.
/*
import 'package:hive/hive.dart';

import '../../domain/entities/memorial.dart';

part 'memorial_model.g.dart';

/// Hive data model for memorial storage.
///
/// This class represents the data layer model for memorials,
/// providing serialization and deserialization capabilities
/// for local storage using Hive database.
@HiveType(typeId: 0)
class MemorialModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  @HiveIndex()
  final String plotNumber;

  @HiveField(2)
  @HiveIndex()
  final String section;

  @HiveField(3)
  @HiveIndex()
  final String headstoneMaterial;

  @HiveField(4)
  final String? inscription;

  @HiveField(5)
  final DateTime? dateOfDeath;

  @HiveField(6)
  final String? deceasedName;

  @HiveField(7)
  final double? latitude;

  @HiveField(8)
  final double? longitude;

  @HiveField(9)
  final String? photoPath;

  @HiveField(10)
  final List<String> additionalDetails;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  /// Creates a new MemorialModel instance.
  const MemorialModel({
    required this.id,
    required this.plotNumber,
    required this.section,
    required this.headstoneMaterial,
    this.inscription,
    this.dateOfDeath,
    this.deceasedName,
    this.latitude,
    this.longitude,
    this.photoPath,
    this.additionalDetails = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a MemorialModel from a domain Memorial entity.
  factory MemorialModel.fromDomain(Memorial memorial) {
    return MemorialModel(
      id: memorial.id,
      plotNumber: memorial.plotNumber,
      section: memorial.section.name,
      headstoneMaterial: memorial.headstoneMaterial.name,
      inscription: memorial.inscription,
      dateOfDeath: memorial.dateOfDeath,
      deceasedName: memorial.deceasedName,
      latitude: memorial.latitude,
      longitude: memorial.longitude,
      photoPath: memorial.photoPath,
      additionalDetails: memorial.additionalDetails,
      createdAt: memorial.createdAt,
      updatedAt: memorial.updatedAt,
    );
  }

  /// Converts this model to a domain Memorial entity.
  Memorial toDomain() {
    return Memorial(
      id: id,
      plotNumber: plotNumber,
      section: BurialSection.values.firstWhere(
        (section) => section.name == this.section,
      ),
      headstoneMaterial: HeadstoneMaterial.values.firstWhere(
        (material) => material.name == headstoneMaterial,
      ),
      inscription: inscription,
      dateOfDeath: dateOfDeath,
      deceasedName: deceasedName,
      latitude: latitude,
      longitude: longitude,
      photoPath: photoPath,
      additionalDetails: additionalDetails,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a copy of this model with the given fields replaced.
  MemorialModel copyWith({
    String? id,
    String? plotNumber,
    String? section,
    String? headstoneMaterial,
    String? inscription,
    DateTime? dateOfDeath,
    String? deceasedName,
    double? latitude,
    double? longitude,
    String? photoPath,
    List<String>? additionalDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MemorialModel(
      id: id ?? this.id,
      plotNumber: plotNumber ?? this.plotNumber,
      section: section ?? this.section,
      headstoneMaterial: headstoneMaterial ?? this.headstoneMaterial,
      inscription: inscription ?? this.inscription,
      dateOfDeath: dateOfDeath ?? this.dateOfDeath,
      deceasedName: deceasedName ?? this.deceasedName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoPath: photoPath ?? this.photoPath,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plotNumber': plotNumber,
      'section': section,
      'headstoneMaterial': headstoneMaterial,
      'inscription': inscription,
      'dateOfDeath': dateOfDeath?.toIso8601String(),
      'deceasedName': deceasedName,
      'latitude': latitude,
      'longitude': longitude,
      'photoPath': photoPath,
      'additionalDetails': additionalDetails,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a MemorialModel from a JSON map.
  factory MemorialModel.fromJson(Map<String, dynamic> json) {
    return MemorialModel(
      id: json['id'] as String,
      plotNumber: json['plotNumber'] as String,
      section: json['section'] as String,
      headstoneMaterial: json['headstoneMaterial'] as String,
      inscription: json['inscription'] as String?,
      dateOfDeath: json['dateOfDeath'] != null
          ? DateTime.parse(json['dateOfDeath'] as String)
          : null,
      deceasedName: json['deceasedName'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      photoPath: json['photoPath'] as String?,
      additionalDetails: List<String>.from(json['additionalDetails'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'MemorialModel(id: $id, plotNumber: $plotNumber, section: $section)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MemorialModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
*/
