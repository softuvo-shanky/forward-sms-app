import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    _isInitialized = true;
  }

  static Future<void> sendSmsToEmail(String sender, String message, String timestamp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get SMTP configuration
      final smtpHost = prefs.getString('smtp_host');
      final smtpPort = prefs.getInt('smtp_port') ?? 587;
      final smtpUsername = prefs.getString('smtp_username');
      final smtpPassword = prefs.getString('smtp_password');
      final recipientEmail = prefs.getString('recipient_email');
      final senderEmail = prefs.getString('sender_email');

      if (smtpHost == null || smtpUsername == null || smtpPassword == null || 
          recipientEmail == null || senderEmail == null) {
        print('SMTP configuration incomplete');
        return;
      }

      // Create email message
      final emailMessage = Message()
        ..from = Address(senderEmail, 'SMS Forwarder')
        ..recipients.add(recipientEmail)
        ..subject = 'SMS from $sender'
        ..html = '''
          <h3>New SMS Received</h3>
          <p><strong>From:</strong> $sender</p>
          <p><strong>Time:</strong> $timestamp</p>
          <p><strong>Message:</strong></p>
          <div style="background-color: #f5f5f5; padding: 10px; border-radius: 5px;">
            $message
          </div>
        ''';

      // Configure SMTP server
      final smtpServer = gmail(smtpUsername, smtpPassword);

      // Send email
      final sendReport = await send(emailMessage, smtpServer);
      print('Email sent successfully: ${sendReport.toString()}');
      
    } catch (e) {
      print('Error sending email: $e');
    }
  }

  static Future<void> saveSmtpConfig({
    required String smtpHost,
    required int smtpPort,
    required String smtpUsername,
    required String smtpPassword,
    required String recipientEmail,
    required String senderEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('smtp_host', smtpHost);
    await prefs.setInt('smtp_port', smtpPort);
    await prefs.setString('smtp_username', smtpUsername);
    await prefs.setString('smtp_password', smtpPassword);
    await prefs.setString('recipient_email', recipientEmail);
    await prefs.setString('sender_email', senderEmail);
  }

  static Future<Map<String, dynamic>?> getSmtpConfig() async {
    final prefs = await SharedPreferences.getInstance();
    
    final smtpHost = prefs.getString('smtp_host');
    if (smtpHost == null) return null;
    
    return {
      'smtp_host': smtpHost,
      'smtp_port': prefs.getInt('smtp_port') ?? 587,
      'smtp_username': prefs.getString('smtp_username') ?? '',
      'smtp_password': prefs.getString('smtp_password') ?? '',
      'recipient_email': prefs.getString('recipient_email') ?? '',
      'sender_email': prefs.getString('sender_email') ?? '',
    };
  }

  static Future<bool> testConnection() async {
    try {
      final config = await getSmtpConfig();
      if (config == null) return false;

      final smtpServer = gmail(config['smtp_username'], config['smtp_password']);

      // Try to send a test email
      final testMessage = Message()
        ..from = Address(config['sender_email'], 'SMS Forwarder Test')
        ..recipients.add(config['recipient_email'])
        ..subject = 'SMS Forwarder Test'
        ..text = 'This is a test email to verify SMTP configuration.';

      await send(testMessage, smtpServer);
      return true;
    } catch (e) {
      print('SMTP test failed: $e');
      return false;
    }
  }
}
