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
        Log.d("SmsReceiver", "SMS received!")
        
        if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
            Log.d("SmsReceiver", "Found ${messages.size} messages")
            
            for (message in messages) {
                val sender = message.originatingAddress ?: "Unknown"
                val messageBody = message.messageBody ?: ""
                val timestamp = System.currentTimeMillis().toString()
                
                Log.d("SmsReceiver", "Processing SMS from: $sender")
                Log.d("SmsReceiver", "Message: $messageBody")
                
                // Send to Flutter
                sendSmsToFlutter(context, sender, messageBody, timestamp)
            }
        }
    }

    private fun sendSmsToFlutter(context: Context, sender: String, message: String, timestamp: String) {
        try {
            Log.d("SmsReceiver", "Attempting to send to Flutter...")
            
            // Try to get the Flutter engine
            val flutterEngine = FlutterEngineCache.getInstance().get("main")
            if (flutterEngine != null) {
                Log.d("SmsReceiver", "Flutter engine found, creating method channel")
                methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sms_service")
                methodChannel?.invokeMethod("onSmsReceived", mapOf(
                    "sender" to sender,
                    "message" to message,
                    "timestamp" to timestamp
                ))
                Log.d("SmsReceiver", "Method channel invoked successfully")
            } else {
                Log.e("SmsReceiver", "Flutter engine not found!")
            }
        } catch (e: Exception) {
            Log.e("SmsReceiver", "Error sending to Flutter: ${e.message}")
            e.printStackTrace()
        }
    }
}
