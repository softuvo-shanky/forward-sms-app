package com.example.forward_sms_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.SharedPreferences
import android.database.ContentObserver
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.provider.Telephony
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngineCache

class SmsMonitorService : Service() {
    private var methodChannel: MethodChannel? = null
    private var smsObserver: ContentObserver? = null
    private var lastSmsId: Long = -1
    private val NOTIFICATION_ID = 1001
    private val CHANNEL_ID = "sms_monitor_channel"

    override fun onCreate() {
        super.onCreate()
        Log.d("SmsMonitorService", "Service created")
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())
        setupMethodChannel()
        startSmsMonitoring()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("SmsMonitorService", "Service started")
        
        // Check if this is a manual SMS check request
        if (intent?.getStringExtra("action") == "check_sms") {
            Log.d("SmsMonitorService", "Manual SMS check requested")
            sendDebugLogToFlutter("Manual SMS check requested")
            checkForNewSms()
        } else if (intent?.getStringExtra("action") == "test_communication") {
            Log.d("SmsMonitorService", "Service communication test requested")
            sendDebugLogToFlutter("Service communication test - this message should appear in Flutter")
        }
        
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private fun setupMethodChannel() {
        try {
            val flutterEngine = FlutterEngineCache.getInstance().get("main")
            if (flutterEngine != null) {
                methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sms_service")
                Log.d("SmsMonitorService", "Method channel setup successful")
                sendDebugLogToFlutter("Method channel setup successful")
            } else {
                Log.e("SmsMonitorService", "Flutter engine not found")
                // Try to send debug log anyway to test if method channel works
                sendDebugLogToFlutter("ERROR: Flutter engine not found in service")
            }
        } catch (e: Exception) {
            Log.e("SmsMonitorService", "Error setting up method channel: ${e.message}")
            sendDebugLogToFlutter("ERROR: Method channel setup failed: ${e.message}")
        }
    }

    private fun startSmsMonitoring() {
        try {
            Log.d("SmsMonitorService", "Starting SMS monitoring")
            sendDebugLogToFlutter("Starting SMS monitoring...")
            
            // Get the last SMS ID to avoid processing old messages
            lastSmsId = getLastSmsId()
            Log.d("SmsMonitorService", "Last SMS ID: $lastSmsId")
            sendDebugLogToFlutter("Last SMS ID: $lastSmsId")
            
            // Register content observer for SMS changes
            smsObserver = object : ContentObserver(Handler(mainLooper)) {
                override fun onChange(selfChange: Boolean, uri: Uri?) {
                    super.onChange(selfChange, uri)
                    Log.d("SmsMonitorService", "SMS content changed: $uri")
                    sendDebugLogToFlutter("SMS content changed: $uri")
                    checkForNewSms()
                }
            }
            
            // Register observer for SMS content
            contentResolver.registerContentObserver(
                Telephony.Sms.CONTENT_URI,
                true,
                smsObserver!!
            )
            
            Log.d("SmsMonitorService", "SMS monitoring started successfully")
            sendDebugLogToFlutter("SMS monitoring started successfully")
            
            // Test the content observer by checking for SMS immediately
            sendDebugLogToFlutter("Testing SMS detection...")
            checkForNewSms()
            
        } catch (e: Exception) {
            Log.e("SmsMonitorService", "Error starting SMS monitoring: ${e.message}")
            sendDebugLogToFlutter("Error starting SMS monitoring: ${e.message}")
        }
    }

    private fun getLastSmsId(): Long {
        var lastId = -1L
        try {
            val cursor: Cursor? = contentResolver.query(
                Telephony.Sms.CONTENT_URI,
                arrayOf(Telephony.Sms._ID),
                null,
                null,
                "${Telephony.Sms._ID} DESC LIMIT 1"
            )
            
            cursor?.use {
                if (it.moveToFirst()) {
                    lastId = it.getLong(0)
                }
            }
        } catch (e: Exception) {
            Log.e("SmsMonitorService", "Error getting last SMS ID: ${e.message}")
        }
        return lastId
    }

    private fun checkForNewSms() {
        try {
            Log.d("SmsMonitorService", "Checking for new SMS...")
            sendDebugLogToFlutter("Checking for new SMS...")
            
            val cursor: Cursor? = contentResolver.query(
                Telephony.Sms.CONTENT_URI,
                arrayOf(
                    Telephony.Sms._ID,
                    Telephony.Sms.ADDRESS,
                    Telephony.Sms.BODY,
                    Telephony.Sms.DATE
                ),
                "${Telephony.Sms._ID} > ?",
                arrayOf(lastSmsId.toString()),
                "${Telephony.Sms._ID} ASC"
            )
            
            sendDebugLogToFlutter("Query executed, cursor: ${cursor != null}")
            
            cursor?.use {
                val count = it.count
                sendDebugLogToFlutter("Found $count SMS messages")
                
                while (it.moveToNext()) {
                    val id = it.getLong(0)
                    val address = it.getString(1) ?: "Unknown"
                    val body = it.getString(2) ?: ""
                    val date = it.getLong(3)
                    
                    Log.d("SmsMonitorService", "New SMS found - ID: $id, From: $address, Body: $body")
                    sendDebugLogToFlutter("New SMS found - ID: $id, From: $address")
                    
                    // Send to Flutter
                    sendSmsToFlutter(address, body, date.toString())
                    
                    // Update last SMS ID
                    lastSmsId = id
                }
            }
            
            if (cursor == null) {
                sendDebugLogToFlutter("ERROR: Cursor is null!")
            }
            
        } catch (e: Exception) {
            Log.e("SmsMonitorService", "Error checking for new SMS: ${e.message}")
            sendDebugLogToFlutter("Error checking for new SMS: ${e.message}")
        }
    }

    private fun sendSmsToFlutter(sender: String, message: String, timestamp: String) {
        try {
            Log.d("SmsMonitorService", "Sending SMS to Flutter - From: $sender")
            sendDebugLogToFlutter("Sending SMS to Flutter - From: $sender")
            
            // Try method channel first
            try {
                methodChannel?.invokeMethod("onSmsReceived", mapOf(
                    "sender" to sender,
                    "message" to message,
                    "timestamp" to timestamp
                ))
                Log.d("SmsMonitorService", "SMS sent via method channel")
            } catch (e: Exception) {
                Log.e("SmsMonitorService", "Method channel failed: ${e.message}")
            }
            
            // Also write to shared preferences as backup
            writeSmsToSharedPrefs(sender, message, timestamp)
            
            Log.d("SmsMonitorService", "SMS sent to Flutter successfully")
            sendDebugLogToFlutter("SMS sent to Flutter successfully")
            
        } catch (e: Exception) {
            Log.e("SmsMonitorService", "Error sending SMS to Flutter: ${e.message}")
            sendDebugLogToFlutter("Error sending SMS to Flutter: ${e.message}")
        }
    }

    private fun writeSmsToSharedPrefs(sender: String, message: String, timestamp: String) {
        try {
            val prefs = getSharedPreferences("sms_data", MODE_PRIVATE)
            val smsData = mapOf(
                "sender" to sender,
                "message" to message,
                "timestamp" to timestamp,
                "received_at" to System.currentTimeMillis().toString()
            )
            
            val existingSms = prefs.getStringSet("sms_messages", mutableSetOf()) ?: mutableSetOf()
            val smsJson = smsData.entries.joinToString("|") { "${it.key}=${it.value}" }
            existingSms.add(smsJson)
            
            // Keep only last 20 SMS
            if (existingSms.size > 20) {
                val sortedSms = existingSms.sortedBy { 
                    it.split("|").find { it.startsWith("received_at=") }?.split("=")?.get(1)?.toLongOrNull() ?: 0L 
                }
                val recentSms = sortedSms.takeLast(20).toSet()
                prefs.edit().putStringSet("sms_messages", recentSms).apply()
            } else {
                prefs.edit().putStringSet("sms_messages", existingSms).apply()
            }
            
            Log.d("SmsMonitorService", "SMS written to shared preferences")
            sendDebugLogToFlutter("SMS written to shared preferences")
            
        } catch (e: Exception) {
            Log.e("SmsMonitorService", "Error writing SMS to shared preferences: ${e.message}")
            sendDebugLogToFlutter("Error writing SMS to shared preferences: ${e.message}")
        }
    }

    private fun sendDebugLogToFlutter(message: String) {
        try {
            Log.d("SmsMonitorService", "Attempting to send debug log: $message")
            
            // Try method channel first
            if (methodChannel != null) {
                methodChannel?.invokeMethod("debugLog", "SERVICE: $message")
                Log.d("SmsMonitorService", "Debug log sent via method channel")
            } else {
                Log.e("SmsMonitorService", "Method channel is null, using shared preferences")
            }
            
            // Also write to shared preferences as backup
            writeDebugLogToSharedPrefs("SERVICE: $message")
            
        } catch (e: Exception) {
            Log.e("SmsMonitorService", "Error sending debug log: ${e.message}")
            // Fallback to shared preferences
            writeDebugLogToSharedPrefs("SERVICE ERROR: ${e.message}")
        }
    }

    private fun writeDebugLogToSharedPrefs(message: String) {
        try {
            val prefs = getSharedPreferences("sms_debug_logs", MODE_PRIVATE)
            val existingLogs = prefs.getStringSet("debug_logs", mutableSetOf()) ?: mutableSetOf()
            existingLogs.add("${System.currentTimeMillis()}: $message")
            
            // Keep only last 50 logs
            if (existingLogs.size > 50) {
                val sortedLogs = existingLogs.sortedBy { it.split(":")[0].toLongOrNull() ?: 0L }
                val recentLogs = sortedLogs.takeLast(50).toSet()
                prefs.edit().putStringSet("debug_logs", recentLogs).apply()
            } else {
                prefs.edit().putStringSet("debug_logs", existingLogs).apply()
            }
            
            Log.d("SmsMonitorService", "Debug log written to shared preferences: $message")
        } catch (e: Exception) {
            Log.e("SmsMonitorService", "Error writing to shared preferences: ${e.message}")
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "SMS Monitor Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Monitors incoming SMS messages"
            }
            
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("SMS Monitor Running")
            .setContentText("Monitoring for incoming SMS messages")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d("SmsMonitorService", "Service destroyed")
        
        smsObserver?.let {
            contentResolver.unregisterContentObserver(it)
        }
    }
}
