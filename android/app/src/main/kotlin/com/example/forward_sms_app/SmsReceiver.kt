package com.example.forward_sms_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.telephony.SmsMessage
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

class SmsReceiver : BroadcastReceiver() {
    private var methodChannel: MethodChannel? = null

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
            
            for (message in messages) {
                val sender = message.originatingAddress ?: "Unknown"
                val messageBody = message.messageBody ?: ""
                val timestamp = System.currentTimeMillis().toString()
                
                // Send to Flutter
                sendSmsToFlutter(sender, messageBody, timestamp)
            }
        }
    }

    private fun sendSmsToFlutter(sender: String, message: String, timestamp: String) {
        try {
            val flutterEngine = FlutterEngineCache.getInstance().get("main")
            if (flutterEngine != null) {
                methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sms_service")
                methodChannel?.invokeMethod("onSmsReceived", mapOf(
                    "sender" to sender,
                    "message" to message,
                    "timestamp" to timestamp
                ))
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
