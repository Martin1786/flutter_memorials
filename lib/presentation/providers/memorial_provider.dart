import 'package:flutter/foundation.dart';

import '../../domain/entities/memorial.dart';
import '../../domain/repositories/memorial_repository.dart';

/// Provider for managing memorial state throughout the application.
///
/// This class manages the state of memorials, including loading,
/// error handling, and CRUD operations using the Provider pattern.
class MemorialProvider extends ChangeNotifier {
  final MemorialRepository _repository;

  // State variables
  List<Memorial> _memorials = [];
  bool _isLoading = false;
  String? _error;
  Memorial? _selectedMemorial;

  /// Creates a new MemorialProvider instance.
  ///
  /// [repository] The repository to use for data operations.
  MemorialProvider(this._repository);

  // Getters
  List<Memorial> get memorials => _memorials;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Memorial? get selectedMemorial => _selectedMemorial;

  /// Returns the number of memorials.
  int get memorialCount => _memorials.length;

  /// Returns true if there are no memorials.
  bool get isEmpty => _memorials.isEmpty;

  /// Returns true if there are memorials.
  bool get isNotEmpty => _memorials.isNotEmpty;

  /// Loads all memorials from the repository.
  Future<void> loadMemorials() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _repository.getAllMemorials();

      if (result.isSuccess) {
        _memorials = result.data ?? [];
        _clearError();
      } else {
        _setError(result.error ?? 'Failed to load memorials');
      }
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Loads a specific memorial by ID.
  Future<void> loadMemorialById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _repository.getMemorialById(id);

      if (result.isSuccess) {
        _selectedMemorial = result.data;
        _clearError();
      } else {
        _setError(result.error ?? 'Failed to load memorial');
      }
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Loads memorials by section.
  Future<void> loadMemorialsBySection(BurialSection section) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _repository.getMemorialsBySection(section);

      if (result.isSuccess) {
        _memorials = result.data ?? [];
        _clearError();
      } else {
        _setError(result.error ??
            'Failed to load memorials for section ${section.name}');
      }
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Searches memorials by plot number.
  Future<void> searchMemorialsByPlotNumber(String plotNumber) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _repository.searchMemorialsByPlotNumber(plotNumber);

      if (result.isSuccess) {
        _memorials = result.data ?? [];
        _clearError();
      } else {
        _setError(result.error ?? 'Failed to search memorials');
      }
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Searches memorials by deceased name.
  Future<void> searchMemorialsByName(String name) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _repository.searchMemorialsByName(name);

      if (result.isSuccess) {
        _memorials = result.data ?? [];
        _clearError();
      } else {
        _setError(result.error ?? 'Failed to search memorials');
      }
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Saves a new memorial.
  Future<bool> saveMemorial(Memorial memorial) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _repository.saveMemorial(memorial);

      if (result.isSuccess) {
        _memorials.add(memorial);
        _clearError();
        return true;
      } else {
        _setError(result.error ?? 'Failed to save memorial');
        return false;
      }
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates an existing memorial.
  Future<bool> updateMemorial(Memorial memorial) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _repository.updateMemorial(memorial);

      if (result.isSuccess) {
        final index = _memorials.indexWhere((m) => m.id == memorial.id);
        if (index != -1) {
          _memorials[index] = memorial;
        }

        if (_selectedMemorial?.id == memorial.id) {
          _selectedMemorial = memorial;
        }

        _clearError();
        return true;
      } else {
        _setError(result.error ?? 'Failed to update memorial');
        return false;
      }
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Deletes a memorial.
  Future<bool> deleteMemorial(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _repository.deleteMemorial(id);

      if (result.isSuccess) {
        _memorials.removeWhere((m) => m.id == id);

        if (_selectedMemorial?.id == id) {
          _selectedMemorial = null;
        }

        _clearError();
        return true;
      } else {
        _setError(result.error ?? 'Failed to delete memorial');
        return false;
      }
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Checks if a plot number exists.
  Future<bool> plotNumberExists(String plotNumber) async {
    try {
      final result = await _repository.plotNumberExists(plotNumber);
      return result.isSuccess && (result.data ?? false);
    } catch (e) {
      return false;
    }
  }

  /// Gets memorials within coordinate bounds.
  Future<void> getMemorialsInBounds(
    double minLat,
    double maxLat,
    double minLng,
    double maxLng,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _repository.getMemorialsInBounds(
        minLat,
        maxLat,
        minLng,
        maxLng,
      );

      if (result.isSuccess) {
        _memorials = result.data ?? [];
        _clearError();
      } else {
        _setError(result.error ?? 'Failed to load memorials in bounds');
      }
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Syncs data with remote storage.
  Future<bool> syncWithRemote() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _repository.syncWithRemote();

      if (result.isSuccess) {
        // Reload memorials after sync
        await loadMemorials();
        _clearError();
        return true;
      } else {
        _setError(result.error ?? 'Failed to sync with remote');
        return false;
      }
    } catch (e) {
      _setError('Unexpected error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Selects a memorial for detailed view.
  void selectMemorial(Memorial memorial) {
    _selectedMemorial = memorial;
    notifyListeners();
  }

  /// Clears the selected memorial.
  void clearSelectedMemorial() {
    _selectedMemorial = null;
    notifyListeners();
  }

  /// Clears all error states.
  void clearError() {
    _clearError();
  }

  /// Refreshes the memorial list.
  Future<void> refresh() async {
    await loadMemorials();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
