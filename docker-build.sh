#!/bin/bash

echo "Building APK using Docker..."

# Build the Docker image
docker build -t forward-sms-app .

# Run the container and copy the APK
docker run --name temp-container forward-sms-app
docker cp temp-container:/app/build/app/outputs/flutter-apk/app-release.apk ./forward-sms-app.apk
docker rm temp-container

echo "APK built successfully: forward-sms-app.apk"
echo "You can now install this APK on your Android device."
