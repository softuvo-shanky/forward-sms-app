@echo off
echo Building Forward SMS App APK...
echo.

REM Check if Flutter is available
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter and add it to your PATH
    echo Download from: https://flutter.dev/docs/get-started/install/windows
    pause
    exit /b 1
)

echo Flutter found! Starting build process...
echo.

REM Clean previous builds
echo Cleaning previous builds...
flutter clean

REM Get dependencies
echo Getting dependencies...
flutter pub get

REM Build release APK
echo Building release APK...
flutter build apk --release

if %errorlevel% equ 0 (
    echo.
    echo ✅ APK built successfully!
    echo.
    echo APK location: build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo You can now install this APK on your Android device.
    echo.
    pause
) else (
    echo.
    echo ❌ Build failed! Please check the error messages above.
    echo.
    pause
)
