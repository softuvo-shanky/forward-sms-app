FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-11-jdk

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:${PATH}"

# Set up Android SDK
RUN mkdir -p /android-sdk
ENV ANDROID_HOME=/android-sdk
ENV PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${PATH}"

# Install Android SDK
RUN curl -o /tmp/commandlinetools.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
RUN unzip /tmp/commandlinetools.zip -d /android-sdk
RUN mkdir -p /android-sdk/cmdline-tools/latest
RUN mv /android-sdk/cmdline-tools/bin /android-sdk/cmdline-tools/latest/
RUN mv /android-sdk/cmdline-tools/lib /android-sdk/cmdline-tools/latest/

# Accept Android licenses
RUN yes | /android-sdk/cmdline-tools/latest/bin/sdkmanager --licenses

# Install Android SDK components
RUN /android-sdk/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Get dependencies and build
RUN flutter pub get
RUN flutter build apk --release

# The APK will be in /app/build/app/outputs/flutter-apk/app-release.apk
