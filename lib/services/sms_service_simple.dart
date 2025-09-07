import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'email_service.dart';

class SmsService {
  static const MethodChannel _channel = MethodChannel('sms_service');
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) {
      print('🔄 SMS service already initialized');
      return;
    }
    
    try {
      print('🚀 Initializing SMS service...');
      
      // Check if SMS permission is granted
      final status = await Permission.sms.status;
      print('📱 SMS permission status: $status');
      if (status != PermissionStatus.granted) {
        await Permission.sms.request();
      }

      // Set up SMS listener
      _setupSmsListener();
      
      // Start periodic check for SMS from service
      _startPeriodicSmsCheck();
      
      _isInitialized = true;
      print('✅ SMS service initialized successfully');
    } catch (e) {
      print('❌ Error initializing SMS service: $e');
    }
  }

  static void _setupSmsListener() {
    print('🔧 Setting up SMS listener...');
    _channel.setMethodCallHandler((call) async {
      print('📞 Method called: ${call.method}');
      print('📞 Method arguments: ${call.arguments}');
      if (call.method == 'onSmsReceived') {
        final Map<dynamic, dynamic> smsData = call.arguments;
        print('📱 Processing SMS data: $smsData');
        await handleSmsReceived(smsData);
      } else if (call.method == 'debugLog') {
        print('🐛 DEBUG: ${call.arguments}');
      } else {
        print('⚠️ Unknown method: ${call.method}');
      }
    });
    print('✅ SMS listener set up successfully');
    
    // Test the method channel immediately (async)
    _testMethodChannel();
  }

  static Future<void> _testMethodChannel() async {
    print('🧪 Testing method channel setup...');
    try {
      await _channel.invokeMethod('test', {'test': 'Flutter method channel is working'});
      print('✅ Method channel test successful');
    } catch (e) {
      print('❌ Method channel test failed: $e');
    }
  }

  static Future<void> handleSmsReceived(Map<dynamic, dynamic> smsData) async {
    try {
      print('📱 === HANDLING SMS RECEIVED ===');
      final String sender = smsData['sender'] ?? 'Unknown';
      final String message = smsData['message'] ?? '';
      final String timestamp = smsData['timestamp'] ?? DateTime.now().toString();

      print('📱 SMS received from: $sender');
      print('📱 Message length: ${message.length}');
      print('📱 Message preview: ${message.length > 100 ? message.substring(0, 100) + '...' : message}');
      print('📱 Timestamp: $timestamp');

      // Check if forwarding is enabled
      print('📱 Checking SMS forwarding configuration...');
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('sms_forwarding_enabled') ?? false;
      
      print('📱 SMS forwarding enabled: $isEnabled');
      print('📱 Processing SMS from: $sender');
      
      if (isEnabled) {
        print('📧 ✅ SMS forwarding is ENABLED - Attempting to forward SMS to email...');
        try {
          // Forward to email
          print('📧 Calling EmailService.sendSmsToEmail...');
          await EmailService.sendSmsToEmail(sender, message, timestamp);
          print('📧 ✅ SMS forwarding completed successfully');
          
          // Log the successful send
          print('📝 Logging successful SMS send...');
          await logSmsSent(sender, message);
          print('📝 ✅ SMS logged successfully');
        } catch (emailError) {
          print('❌ Error sending email: $emailError');
          print('❌ Email error details: ${emailError.toString()}');
          // Still log the SMS even if email fails
          print('📝 Logging SMS despite email failure...');
          await logSmsSent(sender, message);
          print('📝 ✅ SMS logged despite email failure');
        }
      } else {
        print('⚠️ SMS forwarding is DISABLED - SMS will not be forwarded');
      }
      print('📱 === SMS HANDLING COMPLETED ===');
    } catch (e) {
      print('❌ Error handling SMS: $e');
      print('❌ Error details: ${e.toString()}');
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

  static Future<void> checkSmsFromService() async {
    print('🔍 Manual SMS check from service...');
    await _checkForSmsFromService();
  }

  static Future<void> forceCheckSmsFromService() async {
    print('🔍 Force checking SMS from service...');
    // Clear processed IDs to force reprocessing
    _processedSmsIds.clear();
    await _checkForSmsFromService();
  }

  static Timer? _smsCheckTimer;
  static Set<String> _processedSmsIds = {};

  static void _startPeriodicSmsCheck() {
    print('🔄 Starting periodic SMS check...');
    _smsCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      print('⏰ Periodic SMS check triggered');
      await _checkForSmsFromService();
    });
    print('✅ Periodic SMS check timer started');
  }

  static Future<void> _checkForSmsFromService() async {
    try {
      print('🔍 === CHECKING SMS FROM SERVICE ===');
      final prefs = await SharedPreferences.getInstance();
      final smsJsonString = prefs.getString('sms_messages_json') ?? '';
      print('📄 SMS JSON string length: ${smsJsonString.length}');
      print('📄 SMS JSON string preview: ${smsJsonString.length > 100 ? smsJsonString.substring(0, 100) + '...' : smsJsonString}');
      
      final smsMessages = smsJsonString.isNotEmpty ? smsJsonString.split('|||') : [];
      print('📱 Found ${smsMessages.length} SMS messages in shared preferences');
      print('📱 Processed SMS IDs count: ${_processedSmsIds.length}');
      
      for (int i = 0; i < smsMessages.length; i++) {
        final smsJson = smsMessages[i];
        try {
          print('📱 Processing SMS ${i + 1}/${smsMessages.length}');
          print('📱 Raw SMS JSON: $smsJson');
          
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
          
          print('📱 Parsed SMS - Sender: $sender, Message length: ${message.length}, Timestamp: $timestamp, ReceivedAt: $receivedAt');
          
          // Create unique ID for this SMS
          final smsId = '${sender}_${timestamp}_${receivedAt}';
          print('📱 Generated SMS ID: $smsId');
          
          // Only process if we haven't processed this SMS before
          if (!_processedSmsIds.contains(smsId)) {
            _processedSmsIds.add(smsId);
            print('📱 ✅ NEW SMS - Processing SMS from service - From: $sender');
            print('📱 SMS ID: $smsId');
            print('📱 Message preview: ${message.length > 50 ? message.substring(0, 50) + '...' : message}');
            await handleSmsReceived({
              'sender': sender,
              'message': message,
              'timestamp': timestamp,
            });
          } else {
            print('📱 ⏭️ SKIPPED - SMS already processed: $smsId');
          }
        } catch (e) {
          print('❌ Error parsing SMS ${i + 1} from service: $e');
          print('❌ Raw SMS that failed: $smsJson');
        }
      }
      print('🔍 === SMS CHECK COMPLETED ===');
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
