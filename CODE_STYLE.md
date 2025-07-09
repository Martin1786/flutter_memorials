# Code Style Guidelines for memorials_flutter

## Project Overview

An App to keep details of graves in an old churchyard. The details are the people buried in the grave, their details such as date of death, inscriptions on headstones, vases, plaques, the position in the churchyard in coordinates on the map, the material of the headstone (e.g. granite, limestone, slate etc.), the plot number (1 to 500), and the section for the burial (sections A to F). A photograph is to be stored. The app should work locally on the phone and update the database (Firebase).

This document defines the coding standards and style guidelines for memorials_flutter, ensuring consistency and maintainability across the codebase.

### Technical Stack
- **Platform**: Mobile (iOS/Android)
- **Framework**: Flutter
- **Language**: Dart
- **Key Dependencies**:
  - provider (State Management)
  - hive (Local Database)
  - flutter_form (Form Handling)
  - image_picker (Image Selection)
  - flutter_local (Localization)
  - dio (HTTP Client)
  - bloc (State Management)
  - get_it (Dependency Injection)

---

## 1. File Organization

### Directory Structure
```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── routes.dart
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   └── utils/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── bloc/
│   ├── pages/
│   ├── widgets/
│   └── themes/
└── shared/
    ├── widgets/
    └── utils/
```

### File Naming Conventions
- **Files**: Use snake_case for all Dart files
  - `memorial_details_page.dart`
  - `memorial_repository_impl.dart`
  - `memorial_bloc.dart`

- **Directories**: Use snake_case for directory names
  - `memorial_details/`
  - `data_sources/`
  - `use_cases/`

### Import/Export Patterns
```dart
// Standard import order
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

// Local imports (relative paths)
import '../models/memorial.dart';
import '../widgets/memorial_card.dart';
import '../../core/constants/app_constants.dart';
```

### Code Grouping Within Files
```dart
// 1. Imports
import 'package:flutter/material.dart';

// 2. Part directives
part 'memorial_model.g.dart';

// 3. Class/Interface definitions
class MemorialModel {
  // 4. Static fields
  static const String tableName = 'memorials';
  
  // 5. Instance fields
  final String id;
  final String plotNumber;
  
  // 6. Constructor
  const MemorialModel({
    required this.id,
    required this.plotNumber,
  });
  
  // 7. Factory constructors
  factory MemorialModel.fromJson(Map<String, dynamic> json) {
    // Implementation
  }
  
  // 8. Getters
  String get displayName => '$plotNumber - $section';
  
  // 9. Methods
  Map<String, dynamic> toJson() {
    // Implementation
  }
  
  // 10. Override methods
  @override
  String toString() {
    return 'MemorialModel(id: $id, plotNumber: $plotNumber)';
  }
}
```

---

## 2. Code Formatting

### Indentation and Spacing
- Use **2 spaces** for indentation (Flutter standard)
- Maximum line length: **80 characters**
- Use trailing commas for better git diffs

```dart
class MemorialCard extends StatelessWidget {
  const MemorialCard({
    super.key,
    required this.memorial,
    required this.onTap,
    this.showDetails = false,
  });

  final Memorial memorial;
  final VoidCallback onTap;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(memorial.plotNumber),
        subtitle: Text(memorial.section),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
```

### Bracket Placement
- Use **Allman style** for opening braces (new line)
- Closing braces on their own line

```dart
if (condition)
{
  // Code here
}
else
{
  // Alternative code
}
```

### Quotes and Semicolons
- Use **double quotes** for strings
- **Always** use semicolons
- Use **single quotes** for characters

```dart
String message = "Hello, World!";
char letter = 'A';
```

### Comments Formatting
```dart
/// Documentation comments for public APIs
/// 
/// This class represents a memorial in the churchyard.
/// It contains all the details about a burial plot.
class Memorial
{
  // Single line comment for implementation details
  
  /*
   * Multi-line comment for complex explanations
   * Use this for detailed implementation notes
   */
}
```

---

## 3. Naming Conventions

### Variables and Functions
- **Variables**: camelCase
- **Functions**: camelCase
- **Private members**: Start with underscore

```dart
// Variables
String plotNumber = "A-123";
int burialCount = 5;
bool isActive = true;

// Functions
void saveMemorial(Memorial memorial) { }
String formatPlotNumber(String number) { }

// Private members
String _internalId = "";
void _validateData() { }
```

### Classes and Interfaces
- **Classes**: PascalCase
- **Interfaces**: PascalCase with 'I' prefix (optional)
- **Enums**: PascalCase

```dart
class MemorialDetailsPage extends StatelessWidget { }
class IMemorialRepository { }
enum BurialSection { A, B, C, D, E, F }
```

### Constants
- **Global constants**: SCREAMING_SNAKE_CASE
- **Class constants**: SCREAMING_SNAKE_CASE

```dart
// Global constants
const String APP_NAME = "Memorials Flutter";
const int MAX_PLOT_NUMBER = 500;

// Class constants
class MemorialConstants
{
  static const String TABLE_NAME = "memorials";
  static const int MAX_PHOTO_SIZE = 1024 * 1024; // 1MB
}
```

### File Names
- **Dart files**: snake_case.dart
- **Test files**: snake_case_test.dart
- **Widget files**: descriptive_name_widget.dart

```dart
// Examples
memorial_details_page.dart
memorial_card_widget.dart
memorial_repository_test.dart
```

---

## 4. Dart/Flutter Guidelines

### Type Annotations
- **Always** use explicit type annotations for public APIs
- Use `var` sparingly, prefer explicit types
- Use `final` for immutable variables

```dart
// Good
final String plotNumber = "A-123";
final Memorial memorial = Memorial(id: "1", plotNumber: "A-123");
List<Memorial> memorials = [];

// Avoid
var plotNumber = "A-123"; // Less clear
```

### Null Safety
- Use null safety features extensively
- Use `?` for nullable types
- Use `!` only when absolutely certain
- Use `late` for initialization

```dart
class Memorial
{
  final String id;
  final String? inscription; // Nullable
  late final String displayName; // Late initialization
  
  Memorial({required this.id, this.inscription})
  {
    displayName = inscription ?? "No inscription";
  }
}
```

### Error Handling
```dart
// Use try-catch for expected errors
try
{
  final result = await repository.saveMemorial(memorial);
  return result;
}
on NetworkException catch (e)
{
  throw MemorialException("Failed to save memorial: ${e.message}");
}
on Exception catch (e)
{
  throw MemorialException("Unexpected error: ${e.toString()}");
}

// Use Result pattern for better error handling
class Result<T>
{
  final T? data;
  final String? error;
  
  const Result.success(this.data) : error = null;
  const Result.failure(this.error) : data = null;
  
  bool get isSuccess => error == null;
}
```

### Async/Await Patterns
```dart
// Always use async/await instead of .then()
Future<List<Memorial>> getMemorials() async
{
  try
  {
    final response = await repository.getAllMemorials();
    return response;
  }
  catch (e)
  {
    throw MemorialException("Failed to fetch memorials: $e");
  }
}

// Use FutureBuilder for UI
FutureBuilder<List<Memorial>>(
  future: getMemorials(),
  builder: (context, snapshot)
  {
    if (snapshot.connectionState == ConnectionState.waiting)
    {
      return CircularProgressIndicator();
    }
    
    if (snapshot.hasError)
    {
      return ErrorWidget(snapshot.error.toString());
    }
    
    final memorials = snapshot.data ?? [];
    return ListView.builder(
      itemCount: memorials.length,
      itemBuilder: (context, index) => MemorialCard(memorial: memorials[index]),
    );
  },
)
```

---

## 5. Widget Guidelines

### Widget Structure
```dart
class MemorialDetailsPage extends StatefulWidget
{
  const MemorialDetailsPage({
    super.key,
    required this.memorialId,
  });

  final String memorialId;

  @override
  State<MemorialDetailsPage> createState() => _MemorialDetailsPageState();
}

class _MemorialDetailsPageState extends State<MemorialDetailsPage>
{
  // State variables
  Memorial? _memorial;
  bool _isLoading = false;
  String? _error;

  // Lifecycle methods
  @override
  void initState()
  {
    super.initState();
    _loadMemorial();
  }

  @override
  void dispose()
  {
    // Cleanup resources
    super.dispose();
  }

  // Private methods
  Future<void> _loadMemorial() async
  {
    setState(() => _isLoading = true);
    
    try
    {
      final memorial = await MemorialRepository().getById(widget.memorialId);
      setState(() => _memorial = memorial);
    }
    catch (e)
    {
      setState(() => _error = e.toString());
    }
    finally
    {
      setState(() => _isLoading = false);
    }
  }

  // Build method
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: Text("Memorial Details"),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody()
  {
    if (_isLoading)
    {
      return Center(child: CircularProgressIndicator());
    }
    
    if (_error != null)
    {
      return Center(child: Text("Error: $_error"));
    }
    
    if (_memorial == null)
    {
      return Center(child: Text("Memorial not found"));
    }
    
    return _buildMemorialDetails();
  }

  Widget _buildMemorialDetails()
  {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlotInfo(),
          SizedBox(height: 16.0),
          _buildBurialDetails(),
          SizedBox(height: 16.0),
          _buildHeadstoneInfo(),
        ],
      ),
    );
  }
}
```

### State Management with Provider
```dart
// Provider setup
class MemorialProvider extends ChangeNotifier
{
  List<Memorial> _memorials = [];
  bool _isLoading = false;
  String? _error;

  List<Memorial> get memorials => _memorials;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMemorials() async
  {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try
    {
      _memorials = await MemorialRepository().getAll();
    }
    catch (e)
    {
      _error = e.toString();
    }
    finally
    {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Usage in widget
class MemorialsPage extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
    return Consumer<MemorialProvider>(
      builder: (context, provider, child)
      {
        if (provider.isLoading)
        {
          return Center(child: CircularProgressIndicator());
        }
        
        if (provider.error != null)
        {
          return Center(child: Text("Error: ${provider.error}"));
        }
        
        return ListView.builder(
          itemCount: provider.memorials.length,
          itemBuilder: (context, index) => MemorialCard(
            memorial: provider.memorials[index],
          ),
        );
      },
    );
  }
}
```

---

## 6. Documentation Standards

### Documentation Comments
```dart
/// A memorial represents a burial plot in the churchyard.
/// 
/// This class contains all the details about a specific burial plot,
/// including the plot number, section, headstone details, and burial information.
/// 
/// Example usage:
/// ```dart
/// final memorial = Memorial(
///   id: "1",
///   plotNumber: "A-123",
///   section: BurialSection.A,
///   headstoneMaterial: HeadstoneMaterial.granite,
/// );
/// ```
class Memorial
{
  /// Unique identifier for the memorial
  final String id;
  
  /// Plot number (1-500)
  final String plotNumber;
  
  /// Burial section (A-F)
  final BurialSection section;
  
  /// Material of the headstone
  final HeadstoneMaterial headstoneMaterial;
  
  /// Creates a new memorial instance.
  /// 
  /// [id] must be unique across all memorials.
  /// [plotNumber] must be between 1 and 500.
  /// [section] must be a valid burial section.
  const Memorial({
    required this.id,
    required this.plotNumber,
    required this.section,
    required this.headstoneMaterial,
  });
}
```

### README Structure
```markdown
# Memorials Flutter

A mobile application for managing churchyard memorials and burial records.

## Features

- View and manage burial plots (1-500)
- Organize by sections (A-F)
- Store headstone details and materials
- Capture and store photographs
- Local database with Firebase sync
- GPS coordinates for plot locations

## Getting Started

### Prerequisites

- Flutter SDK 3.4.1 or higher
- Dart SDK 3.4.1 or higher
- Android Studio / VS Code
- Firebase project setup

### Installation

1. Clone the repository
2. Run `flutter pub get`
3. Configure Firebase
4. Run `flutter run`

## Architecture

This project follows Clean Architecture principles with the following layers:

- **Presentation**: UI components and state management
- **Domain**: Business logic and entities
- **Data**: Data sources and repositories

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
```

---

## 7. Testing Standards

### Test File Organization
```
test/
├── unit/
│   ├── models/
│   ├── repositories/
│   └── usecases/
├── widget/
│   └── pages/
└── integration/
    └── app_test.dart
```

### Test Naming Conventions
```dart
// Unit tests
class MemorialModelTest
{
  group('Memorial Model', ()
  {
    test('should create memorial from JSON', ()
    {
      // Arrange
      final json = {
        'id': '1',
        'plotNumber': 'A-123',
        'section': 'A',
      };
      
      // Act
      final memorial = Memorial.fromJson(json);
      
      // Assert
      expect(memorial.id, equals('1'));
      expect(memorial.plotNumber, equals('A-123'));
      expect(memorial.section, equals(BurialSection.A));
    });
    
    test('should convert to JSON', ()
    {
      // Arrange
      final memorial = Memorial(
        id: '1',
        plotNumber: 'A-123',
        section: BurialSection.A,
      );
      
      // Act
      final json = memorial.toJson();
      
      // Assert
      expect(json['id'], equals('1'));
      expect(json['plotNumber'], equals('A-123'));
      expect(json['section'], equals('A'));
    });
  });
}
```

### Widget Tests
```dart
class MemorialCardTest
{
  testWidgets('should display memorial information', (WidgetTester tester) async
  {
    // Arrange
    final memorial = Memorial(
      id: '1',
      plotNumber: 'A-123',
      section: BurialSection.A,
    );
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: MemorialCard(memorial: memorial),
      ),
    );
    
    // Assert
    expect(find.text('A-123'), findsOneWidget);
    expect(find.text('Section A'), findsOneWidget);
  });
}
```

### Mock Data
```dart
class MockMemorialRepository extends Mock implements MemorialRepository
{
  @override
  Future<List<Memorial>> getAll() async
  {
    return [
      Memorial(id: '1', plotNumber: 'A-123', section: BurialSection.A),
      Memorial(id: '2', plotNumber: 'B-456', section: BurialSection.B),
    ];
  }
}
```

---

## 8. Performance Guidelines

### Widget Optimization
```dart
// Use const constructors where possible
const MemorialCard({required this.memorial});

// Use RepaintBoundary for complex widgets
RepaintBoundary(
  child: ComplexChartWidget(data: chartData),
)

// Use ListView.builder for large lists
ListView.builder(
  itemCount: memorials.length,
  itemBuilder: (context, index) => MemorialCard(
    memorial: memorials[index],
  ),
)
```

### Image Optimization
```dart
// Use appropriate image formats
Image.asset(
  'assets/images/headstone.png',
  width: 200,
  height: 200,
  fit: BoxFit.cover,
  cacheWidth: 400, // Optimize memory usage
  cacheHeight: 400,
)

// Compress images before storage
Future<File> compressImage(File imageFile) async
{
  final compressedFile = await FlutterImageCompress.compressAndGetFile(
    imageFile.path,
    '${imageFile.path}_compressed.jpg',
    quality: 85,
    minWidth: 1024,
    minHeight: 1024,
  );
  
  return compressedFile ?? imageFile;
}
```

### Database Optimization
```dart
// Use indexes for frequently queried fields
@HiveType(typeId: 0)
class Memorial extends HiveObject
{
  @HiveField(0)
  String id;
  
  @HiveField(1)
  @HiveIndex() // Add index for plot number
  String plotNumber;
  
  @HiveField(2)
  @HiveIndex() // Add index for section
  String section;
}
```

---

## 9. Security Guidelines

### Data Validation
```dart
class MemorialValidator
{
  static String? validatePlotNumber(String? value)
  {
    if (value == null || value.isEmpty)
    {
      return 'Plot number is required';
    }
    
    final plotRegex = RegExp(r'^[A-F]-\d{1,3}$');
    if (!plotRegex.hasMatch(value))
    {
      return 'Plot number must be in format A-123';
    }
    
    final number = int.tryParse(value.split('-')[1]);
    if (number == null || number < 1 || number > 500)
    {
      return 'Plot number must be between 1 and 500';
    }
    
    return null;
  }
  
  static String? validateCoordinates(double? latitude, double? longitude)
  {
    if (latitude == null || longitude == null)
    {
      return 'Coordinates are required';
    }
    
    if (latitude < -90 || latitude > 90)
    {
      return 'Invalid latitude';
    }
    
    if (longitude < -180 || longitude > 180)
    {
      return 'Invalid longitude';
    }
    
    return null;
  }
}
```

### Secure Storage
```dart
// Use secure storage for sensitive data
class SecureStorageService
{
  static const _storage = FlutterSecureStorage();
  
  static Future<void> saveApiKey(String apiKey) async
  {
    await _storage.write(key: 'api_key', value: apiKey);
  }
  
  static Future<String?> getApiKey() async
  {
    return await _storage.read(key: 'api_key');
  }
}
```

### Input Sanitization
```dart
class InputSanitizer
{
  static String sanitizeText(String input)
  {
    // Remove potentially dangerous characters
    return input
        .replaceAll(RegExp(r'[<>"\']'), '')
        .trim();
  }
  
  static String sanitizeFileName(String fileName)
  {
    // Remove invalid characters for file names
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .trim();
  }
}
```

---

## 10. Development Workflow

### Git Workflow
```bash
# Branch naming
feature/memorial-details-page
bugfix/fix-plot-number-validation
hotfix/critical-database-issue

# Commit message format
feat: add memorial details page
fix: validate plot number range
docs: update README with installation steps
test: add unit tests for Memorial model
refactor: extract validation logic to separate class
```

### Pull Request Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Widget tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes
```

---

## Enforcement and Tools

### Analysis Options
```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_single_quotes: true
    always_use_package_imports: true
    avoid_print: true
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    prefer_final_fields: true
    prefer_final_locals: true
    unnecessary_const: true
    unnecessary_new: true
    unnecessary_this: true
    use_key_in_widget_constructors: true

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  errors:
    invalid_annotation_target: ignore
```

### IDE Configuration
```json
// .vscode/settings.json
{
  "dart.lineLength": 80,
  "dart.insertArgumentPlaceholders": true,
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  }
}
```

### Pre-commit Hooks
```yaml
# .github/workflows/pre-commit.yml
name: Pre-commit Checks

on: [push, pull_request]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.4.1'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk --debug
```

---

## Best Practices

### Code Quality
- Keep functions small and focused (max 20 lines)
- Follow DRY (Don't Repeat Yourself) principles
- Maintain separation of concerns
- Use meaningful variable and function names
- Write self-documenting code
- Handle errors appropriately

### Performance
- Use const constructors where possible
- Implement proper caching strategies
- Optimize image loading and storage
- Use appropriate data structures
- Minimize widget rebuilds

### Maintainability
- Write clear documentation
- Use consistent patterns throughout the codebase
- Implement proper error handling
- Follow SOLID principles
- Keep dependencies updated
- Write comprehensive tests

### Collaboration
- Write clear commit messages
- Document breaking changes
- Maintain changelog
- Review code thoroughly
- Share knowledge and best practices
- Use pair programming for complex features

---

## Project-Specific Conventions

### Memorial Data Structure
```dart
class Memorial
{
  final String id;
  final String plotNumber; // Format: "A-123"
  final BurialSection section; // A, B, C, D, E, F
  final HeadstoneMaterial material; // granite, limestone, slate, etc.
  final String? inscription;
  final DateTime? dateOfDeath;
  final String? deceasedName;
  final double? latitude;
  final double? longitude;
  final String? photoPath;
  final List<String> additionalDetails; // vases, plaques, etc.
  
  const Memorial({
    required this.id,
    required this.plotNumber,
    required this.section,
    required this.material,
    this.inscription,
    this.dateOfDeath,
    this.deceasedName,
    this.latitude,
    this.longitude,
    this.photoPath,
    this.additionalDetails = const [],
  });
}
```

### Database Schema
```dart
// Hive boxes
const String MEMORIALS_BOX = 'memorials';
const String SECTIONS_BOX = 'sections';
const String PHOTOS_BOX = 'photos';

// Indexes for efficient querying
@HiveIndex()
String plotNumber;

@HiveIndex()
String section;

@HiveIndex()
String material;
```

### Localization
```dart
// Use flutter_local for internationalization
class AppLocalizations
{
  static const String plotNumber = 'plot_number';
  static const String section = 'section';
  static const String headstoneMaterial = 'headstone_material';
  static const String inscription = 'inscription';
  static const String dateOfDeath = 'date_of_death';
  static const String deceasedName = 'deceased_name';
  static const String coordinates = 'coordinates';
  static const String photo = 'photo';
  static const String additionalDetails = 'additional_details';
}
```

This comprehensive style guide ensures consistency, maintainability, and best practices throughout the memorials_flutter project. All team members should follow these guidelines to maintain code quality and project standards. 