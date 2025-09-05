import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'email_service.dart';

class SmsService {
  static const MethodChannel _channel = MethodChannel('sms_service');
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Check if SMS permission is granted
      final status = await Permission.sms.status;
      if (status != PermissionStatus.granted) {
        await Permission.sms.request();
      }

      // Set up SMS listener
      _setupSmsListener();
      
      // Start periodic check for SMS from service
      _startPeriodicSmsCheck();
      
      _isInitialized = true;
    } catch (e) {
      print('Error initializing SMS service: $e');
    }
  }

  static void _setupSmsListener() {
    print('🔧 Setting up SMS listener...');
    _channel.setMethodCallHandler((call) async {
      print('📞 Method called: ${call.method}');
      if (call.method == 'onSmsReceived') {
        final Map<dynamic, dynamic> smsData = call.arguments;
        print('📱 Processing SMS data: $smsData');
        await _handleSmsReceived(smsData);
      } else {
        print('⚠️ Unknown method: ${call.method}');
      }
    });
    print('✅ SMS listener set up successfully');
  }

  static Future<void> _handleSmsReceived(Map<dynamic, dynamic> smsData) async {
    try {
      final String sender = smsData['sender'] ?? 'Unknown';
      final String message = smsData['message'] ?? '';
      final String timestamp = smsData['timestamp'] ?? DateTime.now().toString();

      print('📱 SMS received from: $sender');
      print('📱 Message: $message');
      print('📱 Timestamp: $timestamp');

      // Check if forwarding is enabled
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('sms_forwarding_enabled') ?? false;
      
      print('📱 SMS forwarding enabled: $isEnabled');
      
      if (isEnabled) {
        print('📧 Attempting to forward SMS to email...');
        // Forward to email
        await EmailService.sendSmsToEmail(sender, message, timestamp);
        print('📧 SMS forwarding completed');
        
        // Log the successful send
        await logSmsSent(sender, message);
      } else {
        print('⚠️ SMS forwarding is disabled');
      }
    } catch (e) {
      print('❌ Error handling SMS: $e');
    }
  }

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('sms_forwarding_enabled') ?? false;
  }

  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sms_forwarding_enabled', enabled);
  }

  static Future<void> logSmsSent(String sender, String message) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    final logEntry = '$now|$sender|${message.length} chars';
    
    // Get existing logs
    final existingLogs = prefs.getStringList('sms_logs') ?? [];
    existingLogs.add(logEntry);
    
    // Keep only last 100 entries
    if (existingLogs.length > 100) {
      existingLogs.removeRange(0, existingLogs.length - 100);
    }
    
    await prefs.setStringList('sms_logs', existingLogs);
    print('📝 Logged SMS: $logEntry');
  }

  static Future<List<String>> getSmsLogs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('sms_logs') ?? [];
  }

  static Future<int> getSmsCount() async {
    final logs = await getSmsLogs();
    return logs.length;
  }

  static Timer? _smsCheckTimer;
  static Set<String> _processedSmsIds = {};

  static void _startPeriodicSmsCheck() {
    print('🔄 Starting periodic SMS check...');
    _smsCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _checkForSmsFromService();
    });
  }

  static Future<void> _checkForSmsFromService() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final smsMessages = prefs.getStringSet('sms_messages') ?? {};
      
      for (final smsJson in smsMessages) {
        try {
          final parts = smsJson.split('|');
          String sender = 'Unknown';
          String message = '';
          String timestamp = '0';
          String receivedAt = '0';
          
          for (final part in parts) {
            if (part.startsWith('sender=')) {
              sender = part.split('=')[1];
            } else if (part.startsWith('message=')) {
              message = part.split('=')[1];
            } else if (part.startsWith('timestamp=')) {
              timestamp = part.split('=')[1];
            } else if (part.startsWith('received_at=')) {
              receivedAt = part.split('=')[1];
            }
          }
          
          // Create unique ID for this SMS
          final smsId = '${sender}_${timestamp}_${receivedAt}';
          
          // Only process if we haven't processed this SMS before
          if (!_processedSmsIds.contains(smsId)) {
            _processedSmsIds.add(smsId);
            
            print('📱 Processing SMS from service - From: $sender');
            await _handleSmsReceived({
              'sender': sender,
              'message': message,
              'timestamp': timestamp,
            });
          }
        } catch (e) {
          print('❌ Error parsing SMS from service: $e');
        }
      }
    } catch (e) {
      print('❌ Error checking SMS from service: $e');
    }
  }

  static void dispose() {
    _isInitialized = false;
    _smsCheckTimer?.cancel();
    _smsCheckTimer = null;
  }
}
