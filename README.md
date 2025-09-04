# Forward SMS App

A Flutter mobile app for Android that automatically forwards all incoming SMS messages to your email address.

## Features

- 📱 **Automatic SMS Forwarding**: Forwards all incoming SMS messages to your email
- ⚙️ **SMTP Configuration**: Easy setup with any SMTP provider (Gmail, Outlook, etc.)
- 🔒 **Secure**: Uses app passwords and secure SMTP connections
- 🎨 **Modern UI**: Clean and intuitive interface
- ✅ **Test Connection**: Verify email settings before enabling forwarding

## Setup Instructions

### 1. Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android Studio or VS Code with Flutter extension
- Android device or emulator

### 2. Installation

1. Clone or download this project
2. Navigate to the project directory
3. Run `flutter pub get` to install dependencies
4. Connect your Android device or start an emulator
5. Run `flutter run` to build and install the app

### 3. Configuration

1. **Grant Permissions**: The app will request SMS permissions on first launch
2. **Configure SMTP Settings**:
   - Open the app and tap the settings icon
   - Enter your SMTP server details:
     - **SMTP Host**: e.g., `smtp.gmail.com`
     - **SMTP Port**: e.g., `587` (TLS) or `465` (SSL)
     - **Username**: Your email address
     - **Password**: Your email password or app password
     - **Sender Email**: Email address to send from
     - **Recipient Email**: Email address to receive forwarded SMS
3. **Test Connection**: Tap "Test Connection" to verify settings
4. **Enable Forwarding**: Toggle the SMS forwarding switch

### 4. Gmail Setup (Recommended)

For Gmail users:
1. Enable 2-Factor Authentication on your Google account
2. Generate an App Password:
   - Go to Google Account settings
   - Security → 2-Step Verification → App passwords
   - Generate a password for "Mail"
3. Use these settings:
   - **SMTP Host**: `smtp.gmail.com`
   - **SMTP Port**: `587`
   - **Username**: Your Gmail address
   - **Password**: The generated app password (not your regular password)

### 5. Other Email Providers

**Outlook/Hotmail**:
- Host: `smtp-mail.outlook.com`
- Port: `587`

**Yahoo**:
- Host: `smtp.mail.yahoo.com`
- Port: `587` or `465`

**Custom SMTP**:
- Check your email provider's SMTP settings
- Use appropriate port (587 for TLS, 465 for SSL)

## Permissions

The app requires the following Android permissions:
- `READ_SMS`: To read incoming SMS messages
- `RECEIVE_SMS`: To receive SMS broadcasts
- `INTERNET`: To send emails via SMTP
- `WAKE_LOCK`: To process SMS in background

## How It Works

1. The app registers a broadcast receiver for incoming SMS messages
2. When an SMS is received, the app captures the sender, message content, and timestamp
3. The message is formatted as an HTML email and sent via SMTP
4. The email includes sender information, timestamp, and the original message

## Troubleshooting

### SMS Not Being Forwarded
- Check if SMS forwarding is enabled in the app
- Verify SMTP configuration is correct
- Test email connection using the "Test Connection" button
- Ensure SMS permissions are granted

### Email Not Being Sent
- Verify SMTP settings are correct
- Check if your email provider requires app passwords
- Ensure internet connection is available
- Check email provider's SMTP limits

### App Crashes
- Check Flutter and Android SDK versions
- Ensure all dependencies are installed (`flutter pub get`)
- Check device compatibility (Android 5.0+)

## Security Notes

- The app stores SMTP credentials locally on your device
- Use app passwords instead of your main email password
- The app only reads SMS messages, it doesn't send or modify them
- All email communication uses secure SMTP connections

## Development

To modify or extend the app:

1. **Add new features**: Edit the Flutter code in `lib/`
2. **Modify SMS handling**: Update `android/app/src/main/kotlin/.../SmsReceiver.kt`
3. **Change UI**: Modify screens in `lib/screens/`
4. **Add email providers**: Update `lib/services/email_service.dart`

## License

This project is open source and available under the MIT License.

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Verify your SMTP configuration
3. Test with a simple email provider first
4. Check device logs for error messages
