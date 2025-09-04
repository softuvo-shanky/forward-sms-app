# How to Build APK for Forward SMS App

## Prerequisites

### 1. Install Flutter
1. Download Flutter SDK from: https://flutter.dev/docs/get-started/install/windows
2. Extract to `C:\flutter` (or any location you prefer)
3. Add Flutter to your PATH:
   - Open System Properties → Environment Variables
   - Add `C:\flutter\bin` to your PATH variable
4. Restart your command prompt/PowerShell

### 2. Install Android Studio
1. Download from: https://developer.android.com/studio
2. Install with default settings
3. Open Android Studio and install Android SDK
4. Accept all license agreements

### 3. Verify Installation
```bash
flutter doctor
```
Make sure all items show ✓ (green checkmarks)

## Building the APK

### Method 1: Debug APK (Quick Build)
```bash
# Navigate to project directory
cd D:\Cursor\ForwardSMSApp

# Get dependencies
flutter pub get

# Build debug APK
flutter build apk --debug
```
**Output**: `build\app\outputs\flutter-apk\app-debug.apk`

### Method 2: Release APK (Optimized)
```bash
# Build release APK
flutter build apk --release
```
**Output**: `build\app\outputs\flutter-apk\app-release.apk`

### Method 3: Split APKs (Smaller file size)
```bash
# Build split APKs for different architectures
flutter build apk --split-per-abi
```
**Output**: 
- `build\app\outputs\flutter-apk\app-arm64-v8a-release.apk`
- `build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk`
- `build\app\outputs\flutter-apk\app-x86_64-release.apk`

## Installation Instructions

### Install on Android Device
1. Enable "Developer Options" on your Android device:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
2. Enable "USB Debugging" in Developer Options
3. Connect device via USB
4. Install APK:
   ```bash
   flutter install
   ```
   OR manually install the APK file from your device

### Manual APK Installation
1. Copy the APK file to your Android device
2. On your device, go to Settings → Security
3. Enable "Install from Unknown Sources" or "Allow from this source"
4. Open the APK file and install

## Troubleshooting

### If Flutter is not recognized:
1. Add Flutter to PATH: `C:\flutter\bin`
2. Restart command prompt
3. Run `flutter doctor` to verify

### If build fails:
1. Run `flutter clean`
2. Run `flutter pub get`
3. Try building again

### If Android SDK issues:
1. Open Android Studio
2. Go to SDK Manager
3. Install Android SDK Platform 33 or higher
4. Install Android SDK Build-Tools

## APK File Locations

After successful build, find your APK files in:
- **Debug APK**: `build\app\outputs\flutter-apk\app-debug.apk`
- **Release APK**: `build\app\outputs\flutter-apk\app-release.apk`
- **Split APKs**: `build\app\outputs\flutter-apk\` (multiple files)

## Quick Commands Summary

```bash
# Setup (run once)
flutter doctor
flutter pub get

# Build APK
flutter build apk --release

# Install on connected device
flutter install
```

## File Size Optimization

The release APK will be approximately 15-25 MB. For smaller file size:
- Use `flutter build apk --split-per-abi` (creates separate APKs for different CPU architectures)
- Use `flutter build appbundle` for Google Play Store (smaller download size)

## Security Note

The APK will be signed with a debug certificate. For production use, you should:
1. Generate a release keystore
2. Configure signing in `android/app/build.gradle`
3. Build with release signing

Would you like me to help you with any specific step or troubleshoot any issues?
