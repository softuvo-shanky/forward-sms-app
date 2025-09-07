import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    _isInitialized = true;
  }

  static Future<void> sendSmsToEmail(String sender, String message, String timestamp) async {
    try {
      print('📧 === EMAIL SERVICE START ===');
      print('📧 Attempting to send SMS to email...');
      print('📧 Sender: $sender');
      print('📧 Message length: ${message.length}');
      print('📧 Timestamp: $timestamp');
      
      final prefs = await SharedPreferences.getInstance();
      
      // Get SMTP configuration
      print('📧 Loading SMTP configuration...');
      final smtpHost = prefs.getString('smtp_host');
      final smtpPort = prefs.getInt('smtp_port') ?? 587;
      final smtpUsername = prefs.getString('smtp_username');
      final smtpPassword = prefs.getString('smtp_password');
      final recipientEmail = prefs.getString('recipient_email');
      final senderEmail = prefs.getString('sender_email');

      print('📧 SMTP Config loaded:');
      print('📧 Host: $smtpHost');
      print('📧 Port: $smtpPort');
      print('📧 Username: $smtpUsername');
      print('📧 Password: ${smtpPassword != null && smtpPassword.length > 0 ? '***' + smtpPassword.substring(smtpPassword.length - 3) : 'EMPTY'}');
      print('📧 Recipient: $recipientEmail');
      print('📧 Sender: $senderEmail');

      if (smtpHost == null || smtpUsername == null || smtpPassword == null || 
          recipientEmail == null || senderEmail == null) {
        print('📧 ❌ SMTP configuration incomplete');
        print('📧 Missing: ${smtpHost == null ? 'host ' : ''}${smtpUsername == null ? 'username ' : ''}${smtpPassword == null ? 'password ' : ''}${recipientEmail == null ? 'recipient ' : ''}${senderEmail == null ? 'sender ' : ''}');
        throw Exception('SMTP configuration incomplete');
      }

      // Create email message
      print('📧 Creating email message...');
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

      print('📧 Email message created successfully');

      // Configure SMTP server
      print('📧 Configuring SMTP server...');
      final smtpServer = SmtpServer(
        smtpHost,
        port: smtpPort,
        username: smtpUsername,
        password: smtpPassword,
        allowInsecure: false,
        ssl: smtpPort == 465,
      );

      print('📧 SMTP server configured');
      print('📧 Attempting to send email...');

      // Send email
      final sendReport = await send(emailMessage, smtpServer);
      print('📧 ✅ Email sent successfully: ${sendReport.toString()}');
      print('📧 === EMAIL SERVICE COMPLETED ===');
      
    } catch (e) {
      print('📧 ❌ Error sending email: $e');
      print('📧 ❌ Error details: ${e.toString()}');
      print('📧 === EMAIL SERVICE FAILED ===');
      rethrow; // Re-throw to let caller handle the error
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

      final smtpServer = SmtpServer(
        config['smtp_host'],
        port: config['smtp_port'],
        username: config['smtp_username'],
        password: config['smtp_password'],
        allowInsecure: false,
        ssl: config['smtp_port'] == 465,
      );

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
