# Flutter Memorials App

A Flutter application for managing churchyard memorials and burial records. This app helps track grave details including people buried, inscriptions, coordinates, materials, plot numbers, sections, and photos.

## 🏗️ Project Structure

```
flutter_memorials/
├── lib/
│   ├── core/
│   │   └── constants/
│   │       └── app_constants.dart
│   ├── data/
│   │   ├── models/
│   │   │   └── memorial_model.dart
│   │   └── repositories/
│   │       └── memorial_repository_impl.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   └── memorial.dart
│   │   └── repositories/
│   │       └── memorial_repository.dart
│   ├── presentation/
│   │   ├── pages/
│   │   │   └── home_page.dart
│   │   ├── providers/
│   │   │   └── memorial_provider.dart
│   │   ├── themes/
│   │   │   └── app_theme.dart
│   │   └── widgets/
│   │       └── memorial_card_widget.dart
│   └── app/
│       └── app.dart
└── pubspec.yaml
```

## 🚀 Features

### Current Features
- **Memorial Management**: Add, view, and manage burial records
- **Search & Filter**: Search by plot number, name, or section
- **Data Visualization**: View memorials with photos, coordinates, and inscriptions
- **Responsive Design**: Works on Android and Windows
- **Clean Architecture**: Follows domain-driven design principles

### Planned Features
- **Firebase Integration**: Cloud storage and synchronization
- **Photo Management**: Upload and store memorial photos
- **GPS Integration**: Location-based memorial discovery
- **Export/Import**: Data backup and restoration
- **Advanced Search**: Filter by date, material, or coordinates

## 📱 Screenshots

*[Screenshots will be added here]*

## 🛠️ Technology Stack

- **Framework**: Flutter 3.4.1+
- **Language**: Dart
- **State Management**: Provider
- **Database**: Firebase Firestore (planned)
- **Platforms**: Android, Windows
- **Architecture**: Clean Architecture with Domain-Driven Design

## 📋 Prerequisites

- Flutter SDK (3.4.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Git

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/Martin1786/flutter_memorials.git
cd flutter_memorials
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run the App
```bash
# For Android
flutter run

# For Windows
flutter run -d windows

# For Web (local development)
flutter run -d chrome
```

### 4. Build for Web Deployment
```bash
# Using the custom build script
chmod +x scripts/build_web.sh
./scripts/build_web.sh

# Or manually
flutter build web --release --web-renderer canvaskit
```

## 🌐 Web Deployment

### Live Demo
The app is automatically deployed to GitHub Pages:
**🌐 https://martin1786.github.io/flutter_memorials**

### Deployment Features
- **Automatic builds** on every push to master
- **Optimized web renderer** (CanvasKit)
- **Service worker** for offline functionality
- **Progressive Web App** (PWA) support
- **Custom loading indicator** and branding

### Web-Specific Optimizations
- **CanvasKit renderer** for better performance
- **Custom service worker** for caching
- **Optimized build size** with tree shaking
- **Responsive design** for all screen sizes

## 📊 Data Model

### Memorial Entity
```dart
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
  final String? photoPath;
  final List<String> additionalDetails;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Burial Sections
- A, B, C, D, E, F

### Headstone Materials
- Granite, Limestone, Slate, Marble, Sandstone, Concrete, Other

## 🎨 UI/UX Features

- **Material Design 3**: Modern, accessible interface
- **Dark/Light Theme**: Automatic theme switching
- **Responsive Layout**: Adapts to different screen sizes
- **Card-based Design**: Clean, organized memorial display
- **Status Icons**: Visual indicators for photos, coordinates, and inscriptions

## 🔧 Development

### Code Style
This project follows Flutter best practices:
- **Clean Architecture**: Separation of concerns
- **Domain-Driven Design**: Business logic in domain layer
- **Provider Pattern**: State management
- **Const Constructors**: Performance optimization
- **Comprehensive Documentation**: Inline code comments

### Linting
The project uses `flutter_lints` for code quality:
```bash
flutter analyze
```

### Testing
```bash
flutter test
```

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  provider: ^6.1.1
  firebase_core: ^2.24.2
  cloud_firestore: ^4.13.0
  uuid: ^4.2.1
  path_provider: ^2.1.1
```

### Dev Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
```

## 🔄 Recent Updates

### Latest Commit (c67c609)
- ✅ Fixed lint warnings (replaced deprecated `withOpacity` with `withAlpha`)
- ✅ Added `const` constructors for performance optimization
- ✅ Restored dialog functionality (fixed `onPressed` callbacks)
- ✅ Added Firebase dependencies for cloud storage
- ✅ Restored missing entity and repository files
- ✅ Enhanced UI with proper theme handling

## 🚧 Roadmap

### Phase 1: Core Features ✅
- [x] Basic memorial management
- [x] Mock data implementation
- [x] UI/UX foundation
- [x] Code architecture setup

### Phase 2: Firebase Integration 🔄
- [ ] Firebase project setup
- [ ] Firestore data models
- [ ] Authentication system
- [ ] Real-time synchronization

### Phase 3: Advanced Features 📋
- [ ] Photo upload and storage
- [ ] GPS location services
- [ ] Advanced search and filtering
- [ ] Data export/import

### Phase 4: Production Ready 🚀
- [ ] Performance optimization
- [ ] Comprehensive testing
- [ ] App store deployment
- [ ] User documentation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Martin1786**
- GitHub: [@Martin1786](https://github.com/Martin1786)
- Project: [Flutter Memorials](https://github.com/Martin1786/flutter_memorials)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for cloud services
- The Flutter community for best practices and guidance

---

**Built with ❤️ using Flutter**
