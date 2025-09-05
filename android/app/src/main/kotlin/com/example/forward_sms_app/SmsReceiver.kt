package com.example.forward_sms_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.telephony.SmsMessage
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

class SmsReceiver : BroadcastReceiver() {
    private var methodChannel: MethodChannel? = null

    override fun onReceive(context: Context, intent: Intent) {
        Log.d("SmsReceiver", "Broadcast received!")
        Log.d("SmsReceiver", "Action: ${intent.action}")
        Log.d("SmsReceiver", "Intent: $intent")
        
        // Send debug log to Flutter
        sendDebugLogToFlutter("Broadcast received! Action: ${intent.action}")
        
        if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            Log.d("SmsReceiver", "SMS_RECEIVED_ACTION detected!")
            sendDebugLogToFlutter("SMS_RECEIVED_ACTION detected!")
            
            val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
            Log.d("SmsReceiver", "Found ${messages.size} messages")
            sendDebugLogToFlutter("Found ${messages.size} messages")
            
            for (message in messages) {
                val sender = message.originatingAddress ?: "Unknown"
                val messageBody = message.messageBody ?: ""
                val timestamp = System.currentTimeMillis().toString()
                
                Log.d("SmsReceiver", "Processing SMS from: $sender")
                Log.d("SmsReceiver", "Message: $messageBody")
                Log.d("SmsReceiver", "Timestamp: $timestamp")
                
                // Send to Flutter
                sendSmsToFlutter(context, sender, messageBody, timestamp)
            }
        } else {
            Log.w("SmsReceiver", "Received broadcast with action: ${intent.action}")
            sendDebugLogToFlutter("Received broadcast with action: ${intent.action}")
        }
    }

    fun sendSmsToFlutter(context: Context, sender: String, message: String, timestamp: String) {
        try {
            Log.d("SmsReceiver", "Attempting to send to Flutter...")
            
            // Try to get the Flutter engine
            val flutterEngine = FlutterEngineCache.getInstance().get("main")
            if (flutterEngine != null) {
                Log.d("SmsReceiver", "Flutter engine found, creating method channel")
                methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sms_service")
                
                // Send debug log to Flutter
                methodChannel?.invokeMethod("debugLog", "SMS received from: $sender")
                methodChannel?.invokeMethod("debugLog", "Message: $message")
                methodChannel?.invokeMethod("debugLog", "Timestamp: $timestamp")
                
                methodChannel?.invokeMethod("onSmsReceived", mapOf(
                    "sender" to sender,
                    "message" to message,
                    "timestamp" to timestamp
                ))
                Log.d("SmsReceiver", "Method channel invoked successfully")
            } else {
                Log.e("SmsReceiver", "Flutter engine not found!")
                // Try to send debug log anyway
                methodChannel?.invokeMethod("debugLog", "ERROR: Flutter engine not found!")
            }
        } catch (e: Exception) {
            Log.e("SmsReceiver", "Error sending to Flutter: ${e.message}")
            e.printStackTrace()
            // Try to send error to Flutter
            try {
                methodChannel?.invokeMethod("debugLog", "ERROR: ${e.message}")
            } catch (e2: Exception) {
                Log.e("SmsReceiver", "Failed to send error to Flutter: ${e2.message}")
            }
        }
    }

    private fun sendDebugLogToFlutter(message: String) {
        try {
            val flutterEngine = FlutterEngineCache.getInstance().get("main")
            if (flutterEngine != null) {
                if (methodChannel == null) {
                    methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sms_service")
                }
                methodChannel?.invokeMethod("debugLog", message)
            }
        } catch (e: Exception) {
            Log.e("SmsReceiver", "Error sending debug log: ${e.message}")
        }
    }

    fun testMethodChannel(context: Context) {
        try {
            Log.d("SmsReceiver", "Testing method channel...")
            val flutterEngine = FlutterEngineCache.getInstance().get("main")
            if (flutterEngine != null) {
                methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sms_service")
                methodChannel?.invokeMethod("test", mapOf("test" to "success"))
                Log.d("SmsReceiver", "Test method channel invoked successfully")
            } else {
                Log.e("SmsReceiver", "Flutter engine not found for test!")
            }
        } catch (e: Exception) {
            Log.e("SmsReceiver", "Error testing method channel: ${e.message}")
            e.printStackTrace()
        }
    }
}
