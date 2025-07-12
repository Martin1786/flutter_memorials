import '../../domain/entities/memorial.dart';
import '../../domain/repositories/memorial_repository.dart';

class MockMemorialRepository implements MemorialRepository {
  final List<Memorial> _memorials = [];

  MockMemorialRepository() {
    final now = DateTime.now();
    _memorials.addAll([
      Memorial(
        id: '1',
        plotNumber: 'A-123',
        section: BurialSection.A,
        headstoneMaterial: HeadstoneMaterial.granite,
        inscription: 'In loving memory of John Smith\n1920 - 1995',
        dateOfDeath: DateTime(1995, 6, 15),
        deceasedName: 'John Smith',
        latitude: 51.5074,
        longitude: -0.1278,
        imageUrl: null,
        additionalDetails: ['Vase', 'Plaque'],
        createdAt: now,
        updatedAt: now,
      ),
      Memorial(
        id: '2',
        plotNumber: 'B-456',
        section: BurialSection.B,
        headstoneMaterial: HeadstoneMaterial.limestone,
        inscription: 'Rest in peace\nMary Johnson\n1935 - 2000',
        dateOfDeath: DateTime(2000, 3, 22),
        deceasedName: 'Mary Johnson',
        latitude: 51.5075,
        longitude: -0.1279,
        imageUrl: null,
        additionalDetails: ['Cross'],
        createdAt: now,
        updatedAt: now,
      ),
    ]);
  }

  @override
  Future<Result<List<Memorial>>> getAllMemorials() async {
    return Result.success(_memorials);
  }

  @override
  Future<Result<Memorial>> getMemorialById(String id) async {
    final memorial = _memorials.firstWhere((m) => m.id == id,
        orElse: () => _memorials.first);
    return Result.success(memorial);
  }

  @override
  Future<Result<List<Memorial>>> getMemorialsBySection(
      BurialSection section) async {
    return Result.success(
        _memorials.where((m) => m.section == section).toList());
  }

  @override
  Future<Result<List<Memorial>>> searchMemorialsByPlotNumber(
      String plotNumber) async {
    return Result.success(
        _memorials.where((m) => m.plotNumber.contains(plotNumber)).toList());
  }

  @override
  Future<Result<List<Memorial>>> searchMemorialsByName(String name) async {
    return Result.success(_memorials
        .where((m) => m.deceasedName?.contains(name) ?? false)
        .toList());
  }

  @override
  Future<Result<void>> saveMemorial(Memorial memorial) async {
    _memorials.add(memorial);
    return Result.success(null);
  }

  @override
  Future<Result<void>> updateMemorial(Memorial memorial) async {
    final index = _memorials.indexWhere((m) => m.id == memorial.id);
    if (index != -1) _memorials[index] = memorial;
    return Result.success(null);
  }

  @override
  Future<Result<void>> deleteMemorial(String id) async {
    _memorials.removeWhere((m) => m.id == id);
    return Result.success(null);
  }

  @override
  Future<Result<bool>> plotNumberExists(String plotNumber) async {
    return Result.success(_memorials.any((m) => m.plotNumber == plotNumber));
  }

  @override
  Future<Result<int>> getMemorialCount() async {
    return Result.success(_memorials.length);
  }

  @override
  Future<Result<List<Memorial>>> getMemorialsInBounds(
      double minLat, double maxLat, double minLng, double maxLng) async {
    return Result.success(_memorials.where((m) {
      if (m.latitude == null || m.longitude == null) return false;
      return m.latitude! >= minLat &&
          m.latitude! <= maxLat &&
          m.longitude! >= minLng &&
          m.longitude! <= maxLng;
    }).toList());
  }

  @override
  Future<Result<void>> syncWithRemote() async {
    return Result.success(null);
  }

  @override
  Future<Result<String>> exportData(String format) async {
    return Result.success('mock_export_path.$format');
  }

  @override
  Future<Result<void>> importData(String filePath, String format) async {
    return Result.success(null);
  }
}
