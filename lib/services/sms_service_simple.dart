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
      _isInitialized = true;
    } catch (e) {
      print('Error initializing SMS service: $e');
    }
  }

  static void _setupSmsListener() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onSmsReceived') {
        final Map<dynamic, dynamic> smsData = call.arguments;
        await _handleSmsReceived(smsData);
      }
    });
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

  static void dispose() {
    _isInitialized = false;
  }
}
