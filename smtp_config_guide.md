# Your SMTP Configuration

## Gmail SMTP Settings Configuration

Use these exact settings in the Forward SMS App:

### SMTP Configuration
- **SMTP Host**: `smtp.gmail.com`
- **SMTP Port**: `587`
- **Username**: `[YOUR_EMAIL]@gmail.com`
- **Password**: `[YOUR_APP_PASSWORD]`
- **Sender Email**: `[YOUR_EMAIL]@gmail.com`
- **Recipient Email**: `[RECIPIENT_EMAIL]@gmail.com` (or any email where you want to receive forwarded SMS)

### Step-by-Step Setup
1. Open the Forward SMS App
2. Tap the Settings icon (gear icon)
3. Enter the configuration above
4. Tap "Test Connection" to verify
5. Tap "Save Settings"
6. Go back to main screen and toggle SMS Forwarding ON

### Security Notes
- Use your Gmail App Password (not your regular password)
- This is the correct way to authenticate with Gmail SMTP
- Never use your regular Gmail password for SMTP

### Testing
1. Send a test SMS to your phone
2. Check your email for the forwarded message
3. The email will have subject: "SMS from [sender_number]"

### Troubleshooting
- If connection fails, verify the App Password is correct
- Ensure 2-Factor Authentication is enabled on your Google account
- Check that "Less secure app access" is disabled (use App Passwords instead)
