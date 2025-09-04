# Testing SMS Forwarding App

## Prerequisites
1. Install the app on your Android device
2. Configure SMTP settings in the app
3. Grant SMS permissions when prompted

## Test Steps

### 1. Initial Setup
1. Open the app
2. Go to Settings (gear icon)
3. Configure your SMTP settings:
   - **SMTP Host**: `smtp.gmail.com` (for Gmail)
   - **SMTP Port**: `587`
   - **Username**: Your Gmail address
   - **Password**: Your Gmail app password (not regular password)
   - **Sender Email**: Your Gmail address
   - **Recipient Email**: Email where you want to receive forwarded SMS
4. Tap "Test Connection" to verify settings
5. Tap "Save Settings"

### 2. Enable SMS Forwarding
1. Go back to the main screen
2. Toggle the "SMS Forwarding" switch to ON
3. You should see a green confirmation message

### 3. Test SMS Forwarding
1. Send a test SMS to your device from another phone
2. Check your email for the forwarded message
3. The email should contain:
   - Sender's phone number
   - Timestamp
   - Original message content

### 4. Verify Email Format
The forwarded email should look like:
```
Subject: SMS from +1234567890

New SMS Received
From: +1234567890
Time: 2024-01-15 10:30:45.123
Message:
[Your test message content here]
```

## Troubleshooting

### If SMS is not being forwarded:
1. Check if SMS forwarding is enabled (green switch)
2. Verify SMTP configuration is correct
3. Test email connection again
4. Check device permissions in Android Settings

### If email is not being sent:
1. Verify SMTP settings are correct
2. Use app password for Gmail (not regular password)
3. Check internet connection
4. Try with a different email provider

### If app crashes:
1. Check Android version (requires 5.0+)
2. Ensure all permissions are granted
3. Restart the app
4. Check device storage space

## Gmail App Password Setup
1. Go to Google Account settings
2. Security → 2-Step Verification
3. App passwords → Generate password for "Mail"
4. Use this password in the app (not your regular Gmail password)

## Alternative Email Providers
- **Outlook**: smtp-mail.outlook.com:587
- **Yahoo**: smtp.mail.yahoo.com:587
- **Custom**: Check your provider's SMTP settings
