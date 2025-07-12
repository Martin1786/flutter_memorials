enum BurialSection { A, B, C, D, E, F }

extension BurialSectionExtension on BurialSection {
  String get displayName => name;
}

enum HeadstoneMaterial {
  granite,
  limestone,
  slate,
  marble,
  sandstone,
  concrete,
  other
}

extension HeadstoneMaterialExtension on HeadstoneMaterial {
  String get displayName {
    switch (this) {
      case HeadstoneMaterial.granite:
        return 'Granite';
      case HeadstoneMaterial.limestone:
        return 'Limestone';
      case HeadstoneMaterial.slate:
        return 'Slate';
      case HeadstoneMaterial.marble:
        return 'Marble';
      case HeadstoneMaterial.sandstone:
        return 'Sandstone';
      case HeadstoneMaterial.concrete:
        return 'Concrete';
      case HeadstoneMaterial.other:
        return 'Other';
    }
  }
}

class Memorial {
  final String id;
  final String plotNumber;
  final BurialSection section;
  final HeadstoneMaterial headstoneMaterial;
  final String? inscription;
  final DateTime? dateOfDeath;
  final String? deceasedName;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final List<String> additionalDetails;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Memorial({
    required this.id,
    required this.plotNumber,
    required this.section,
    required this.headstoneMaterial,
    this.inscription,
    this.dateOfDeath,
    this.deceasedName,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.additionalDetails = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayName => ' A0$plotNumber - ${section.displayName}';
  bool get hasPhoto => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasCoordinates => latitude != null && longitude != null;
  bool get hasInscription => inscription != null && inscription!.isNotEmpty;
}
