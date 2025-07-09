import '../../domain/entities/memorial.dart';
import '../../domain/repositories/memorial_repository.dart';

/// Mock implementation of the MemorialRepository.
///
/// This implementation provides mock data for testing and development
/// purposes. It does not persist data and resets on app restart.
class MockMemorialRepository implements MemorialRepository {
  // Mock data storage
  final List<Memorial> _memorials = [];
  int _nextId = 1;

  /// Creates a new MockMemorialRepository with sample data.
  MockMemorialRepository() {
    _initializeSampleData();
  }

  /// Initializes the repository with sample memorial data.
  void _initializeSampleData() {
    final now = DateTime.now();

    _memorials.addAll([
      Memorial(
        id: _generateId(),
        plotNumber: 'A-123',
        section: BurialSection.A,
        headstoneMaterial: HeadstoneMaterial.granite,
        inscription: 'In loving memory of John Smith\n1920 - 1995',
        dateOfDeath: DateTime(1995, 6, 15),
        deceasedName: 'John Smith',
        latitude: 51.5074,
        longitude: -0.1278,
        photoPath: null,
        additionalDetails: ['Vase', 'Plaque'],
        createdAt: now,
        updatedAt: now,
      ),
      Memorial(
        id: _generateId(),
        plotNumber: 'B-456',
        section: BurialSection.B,
        headstoneMaterial: HeadstoneMaterial.limestone,
        inscription: 'Rest in peace\nMary Johnson\n1935 - 2000',
        dateOfDeath: DateTime(2000, 3, 22),
        deceasedName: 'Mary Johnson',
        latitude: 51.5075,
        longitude: -0.1279,
        photoPath: null,
        additionalDetails: ['Cross'],
        createdAt: now,
        updatedAt: now,
      ),
      Memorial(
        id: _generateId(),
        plotNumber: 'C-789',
        section: BurialSection.C,
        headstoneMaterial: HeadstoneMaterial.slate,
        inscription:
            'Beloved father and grandfather\nRobert Brown\n1910 - 1988',
        dateOfDeath: DateTime(1988, 12, 10),
        deceasedName: 'Robert Brown',
        latitude: 51.5076,
        longitude: -0.1280,
        photoPath: null,
        additionalDetails: ['Angel statue'],
        createdAt: now,
        updatedAt: now,
      ),
    ]);
  }

  String _generateId() {
    return (_nextId++).toString();
  }

  @override
  Future<Result<List<Memorial>>> getAllMemorials() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return Result.success(_memorials);
  }

  @override
  Future<Result<Memorial>> getMemorialById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final memorial = _memorials.firstWhere(
      (m) => m.id == id,
      orElse: () => throw Exception('Memorial not found'),
    );

    return Result.success(memorial);
  }

  @override
  Future<Result<List<Memorial>>> getMemorialsBySection(
      BurialSection section) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final filteredMemorials = _memorials
        .where(
          (m) => m.section == section,
        )
        .toList();

    return Result.success(filteredMemorials);
  }

  @override
  Future<Result<List<Memorial>>> searchMemorialsByPlotNumber(
      String plotNumber) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final filteredMemorials = _memorials
        .where(
          (m) => m.plotNumber.toLowerCase().contains(plotNumber.toLowerCase()),
        )
        .toList();

    return Result.success(filteredMemorials);
  }

  @override
  Future<Result<List<Memorial>>> searchMemorialsByName(String name) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final filteredMemorials = _memorials
        .where(
          (m) =>
              m.deceasedName?.toLowerCase().contains(name.toLowerCase()) ??
              false,
        )
        .toList();

    return Result.success(filteredMemorials);
  }

  @override
  Future<Result<void>> saveMemorial(Memorial memorial) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final newMemorial = memorial.copyWith(
      id: _generateId(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _memorials.add(newMemorial);
    return const Result.success(null);
  }

  @override
  Future<Result<void>> updateMemorial(Memorial memorial) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _memorials.indexWhere((m) => m.id == memorial.id);
    if (index == -1) {
      return const Result.failure('Memorial not found');
    }

    final updatedMemorial = memorial.copyWith(
      updatedAt: DateTime.now(),
    );

    _memorials[index] = updatedMemorial;
    return const Result.success(null);
  }

  @override
  Future<Result<void>> deleteMemorial(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _memorials.indexWhere((m) => m.id == id);
    if (index == -1) {
      return const Result.failure('Memorial not found');
    }

    _memorials.removeAt(index);
    return const Result.success(null);
  }

  @override
  Future<Result<bool>> plotNumberExists(String plotNumber) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final exists = _memorials.any((m) => m.plotNumber == plotNumber);
    return Result.success(exists);
  }

  @override
  Future<Result<int>> getMemorialCount() async {
    await Future.delayed(const Duration(milliseconds: 100));

    return Result.success(_memorials.length);
  }

  @override
  Future<Result<List<Memorial>>> getMemorialsInBounds(
    double minLat,
    double maxLat,
    double minLng,
    double maxLng,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final filteredMemorials = _memorials.where((m) {
      if (m.latitude == null || m.longitude == null) return false;

      return m.latitude! >= minLat &&
          m.latitude! <= maxLat &&
          m.longitude! >= minLng &&
          m.longitude! <= maxLng;
    }).toList();

    return Result.success(filteredMemorials);
  }

  @override
  Future<Result<void>> syncWithRemote() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    // Mock sync - in real implementation, this would sync with Firebase
    return const Result.success(null);
  }

  @override
  Future<Result<String>> exportData(String format) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock export - in real implementation, this would export to file
    return Result.success('/path/to/exported/data.$format');
  }

  @override
  Future<Result<void>> importData(String filePath, String format) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock import - in real implementation, this would import from file
    return const Result.success(null);
  }
}
