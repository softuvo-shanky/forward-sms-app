#!/bin/bash

echo "Building Forward SMS App APK..."
echo

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter is not installed or not in PATH"
    echo "Please install Flutter and add it to your PATH"
    echo "Download from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "Flutter found! Starting build process..."
echo

# Clean previous builds
echo "Cleaning previous builds..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build release APK
echo "Building release APK..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo
    echo "✅ APK built successfully!"
    echo
    echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
    echo
    echo "You can now install this APK on your Android device."
    echo
else
    echo
    echo "❌ Build failed! Please check the error messages above."
    echo
    exit 1
fi
