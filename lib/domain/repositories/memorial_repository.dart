import '../entities/memorial.dart';

class Result<T> {
  final T? data;
  final String? error;
  Result.success(this.data) : error = null;
  Result.failure(this.error) : data = null;
  bool get isSuccess => error == null;
}

abstract class MemorialRepository {
  Future<Result<List<Memorial>>> getAllMemorials();
  Future<Result<Memorial>> getMemorialById(String id);
  Future<Result<List<Memorial>>> getMemorialsBySection(BurialSection section);
  Future<Result<List<Memorial>>> searchMemorialsByPlotNumber(String plotNumber);
  Future<Result<List<Memorial>>> searchMemorialsByName(String name);
  Future<Result<void>> saveMemorial(Memorial memorial);
  Future<Result<void>> updateMemorial(Memorial memorial);
  Future<Result<void>> deleteMemorial(String id);
  Future<Result<bool>> plotNumberExists(String plotNumber);
  Future<Result<int>> getMemorialCount();
  Future<Result<List<Memorial>>> getMemorialsInBounds(
    double minLat,
    double maxLat,
    double minLng,
    double maxLng,
  );
  Future<Result<void>> syncWithRemote();
  Future<Result<String>> exportData(String format);
  Future<Result<void>> importData(String filePath, String format);
}
