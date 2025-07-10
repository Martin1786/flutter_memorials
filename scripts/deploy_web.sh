#!/bin/bash

# Deploy Flutter Memorials Web App
echo "Building Flutter web app..."

# Clean previous build
flutter clean

# Get dependencies
flutter pub get

# Build web app with correct base href
flutter build web --base-href "/flutter_memorials/"

echo "Build completed! Files are in build/web/"
echo ""
echo "To test locally, run:"
echo "cd build/web && python -m http.server 8000"
echo "Then visit: http://localhost:8000"
echo ""
echo "To deploy to GitHub Pages:"
echo "1. Push your code to GitHub"
echo "2. The GitHub Actions workflow will automatically deploy"
echo "3. Your app will be available at: https://yourusername.github.io/flutter_memorials/" 