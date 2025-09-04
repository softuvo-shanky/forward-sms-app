import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_advanced/sms_advanced.dart';
import 'email_service.dart';

class SmsService {
  static const MethodChannel _channel = MethodChannel('sms_service');
  static StreamSubscription? _smsSubscription;
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
    _smsSubscription = _channel.setMethodCallHandler((call) async {
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

      print('SMS received from: $sender');
      print('Message: $message');

      // Check if forwarding is enabled
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('sms_forwarding_enabled') ?? false;
      
      if (isEnabled) {
        // Forward to email
        await EmailService.sendSmsToEmail(sender, message, timestamp);
      }
    } catch (e) {
      print('Error handling SMS: $e');
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

  static void dispose() {
    _smsSubscription?.cancel();
    _smsSubscription = null;
    _isInitialized = false;
  }
}