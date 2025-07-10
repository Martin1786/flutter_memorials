#!/bin/bash

# Flutter Memorials Web Build Script
# This script optimizes the web build for production deployment

echo "🚀 Building Flutter Memorials for Web..."

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Analyze code
echo "📊 Analyzing code..."
flutter analyze

# Run tests
echo "🧪 Running tests..."
flutter test

# Build for web with optimizations
echo "🔨 Building web version..."
flutter build web \
  --release \
  --web-renderer canvaskit \
  --dart-define=FLUTTER_WEB_USE_SKIA=true \
  --dart-define=FLUTTER_WEB_AUTO_DETECT=true

# Optimize build size
echo "📦 Optimizing build..."
cd build/web

# Remove unnecessary files
rm -rf canvaskit/profiling
rm -rf canvaskit/skwasm.js

echo "✅ Web build completed successfully!"
echo "📁 Build output: build/web/"
echo "🌐 Deploy to: https://martin1786.github.io/flutter_memorials" 