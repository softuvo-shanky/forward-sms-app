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
                } else if (intent?.getStringExtra("action") == "check_all_recent_sms") {
                    Log.d("SmsMonitorService", "Check all recent SMS requested")
                    sendDebugLogToFlutter("Check all recent SMS requested")
                    checkAllRecentSms()
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
            // Try to get Flutter engine from cache
            val flutterEngine = FlutterEngineCache.getInstance().get("main")
            if (flutterEngine != null) {
                methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sms_service")
                Log.d("SmsMonitorService", "Method channel setup successful")
                sendDebugLogToFlutter("Method channel setup successful")
            } else {
                Log.w("SmsMonitorService", "Flutter engine not found in cache, will retry later")
                sendDebugLogToFlutter("WARNING: Flutter engine not found in cache, will retry when SMS received")
                // Don't treat this as an error - the service can still work
                // The method channel will be set up when SMS are actually received
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
                    
                    // First, let's check what's the latest SMS ID in the database
                    val latestSmsId = getLatestSmsId()
                    sendDebugLogToFlutter("Latest SMS ID in database: $latestSmsId")
                    sendDebugLogToFlutter("Last processed SMS ID: $lastSmsId")
                    
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
                        sendDebugLogToFlutter("Found $count new SMS messages")
                        
                        if (count == 0) {
                            // No new SMS, but let's check if there are any recent SMS
                            sendDebugLogToFlutter("No new SMS found. Checking recent SMS...")
                            checkRecentSms()
                        } else {
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
                    }
                    
                    if (cursor == null) {
                        sendDebugLogToFlutter("ERROR: Cursor is null!")
                    }
                    
                } catch (e: Exception) {
                    Log.e("SmsMonitorService", "Error checking for new SMS: ${e.message}")
                    sendDebugLogToFlutter("Error checking for new SMS: ${e.message}")
                }
            }
            
            private fun getLatestSmsId(): Long {
                var latestId = -1L
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
                            latestId = it.getLong(0)
                        }
                    }
                } catch (e: Exception) {
                    Log.e("SmsMonitorService", "Error getting latest SMS ID: ${e.message}")
                }
                return latestId
            }
            
            private fun checkRecentSms() {
                try {
                    sendDebugLogToFlutter("Checking recent SMS (last 5)...")
                    
                    val cursor: Cursor? = contentResolver.query(
                        Telephony.Sms.CONTENT_URI,
                        arrayOf(
                            Telephony.Sms._ID,
                            Telephony.Sms.ADDRESS,
                            Telephony.Sms.BODY,
                            Telephony.Sms.DATE
                        ),
                        null,
                        null,
                        "${Telephony.Sms._ID} DESC LIMIT 5"
                    )
                    
                    cursor?.use {
                        val count = it.count
                        sendDebugLogToFlutter("Found $count recent SMS messages")
                        
                        while (it.moveToNext()) {
                            val id = it.getLong(0)
                            val address = it.getString(1) ?: "Unknown"
                            val body = it.getString(2) ?: ""
                            val date = it.getLong(3)
                            
                            sendDebugLogToFlutter("Recent SMS - ID: $id, From: $address, Body: ${body.take(20)}...")
                        }
                    }
                } catch (e: Exception) {
                    Log.e("SmsMonitorService", "Error checking recent SMS: ${e.message}")
                    sendDebugLogToFlutter("Error checking recent SMS: ${e.message}")
                }
            }
            
            private fun checkAllRecentSms() {
                try {
                    sendDebugLogToFlutter("Checking all recent SMS (last 10)...")
                    
                    val cursor: Cursor? = contentResolver.query(
                        Telephony.Sms.CONTENT_URI,
                        arrayOf(
                            Telephony.Sms._ID,
                            Telephony.Sms.ADDRESS,
                            Telephony.Sms.BODY,
                            Telephony.Sms.DATE
                        ),
                        null,
                        null,
                        "${Telephony.Sms._ID} DESC LIMIT 10"
                    )
                    
                    cursor?.use {
                        val count = it.count
                        sendDebugLogToFlutter("Found $count recent SMS messages")
                        
                        while (it.moveToNext()) {
                            val id = it.getLong(0)
                            val address = it.getString(1) ?: "Unknown"
                            val body = it.getString(2) ?: ""
                            val date = it.getLong(3)
                            
                            sendDebugLogToFlutter("Recent SMS - ID: $id, From: $address, Body: ${body.take(30)}...")
                            
                            // Send to Flutter as if it's a new SMS
                            sendSmsToFlutter(address, body, date.toString())
                        }
                    }
                } catch (e: Exception) {
                    Log.e("SmsMonitorService", "Error checking all recent SMS: ${e.message}")
                    sendDebugLogToFlutter("Error checking all recent SMS: ${e.message}")
                }
            }

                private fun sendSmsToFlutter(sender: String, message: String, timestamp: String) {
                try {
                    Log.d("SmsMonitorService", "=== SMS PROCESSING START ===")
                    Log.d("SmsMonitorService", "Sending SMS to Flutter - From: $sender")
                    Log.d("SmsMonitorService", "Message length: ${message.length}")
                    Log.d("SmsMonitorService", "Timestamp: $timestamp")
                    sendDebugLogToFlutter("=== SMS PROCESSING START ===")
                    sendDebugLogToFlutter("Sending SMS to Flutter - From: $sender")
                    sendDebugLogToFlutter("Message length: ${message.length}")
                    sendDebugLogToFlutter("Timestamp: $timestamp")
                    
                    // Try to setup method channel if not already done
                    if (methodChannel == null) {
                        Log.d("SmsMonitorService", "Method channel is null, attempting setup...")
                        sendDebugLogToFlutter("Method channel is null, attempting setup...")
                        try {
                            val flutterEngine = FlutterEngineCache.getInstance().get("main")
                            if (flutterEngine != null) {
                                methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sms_service")
                                Log.d("SmsMonitorService", "Method channel setup successful on retry")
                                sendDebugLogToFlutter("Method channel setup successful on retry")
                            } else {
                                Log.w("SmsMonitorService", "Flutter engine still not available")
                                sendDebugLogToFlutter("Flutter engine still not available")
                            }
                        } catch (e: Exception) {
                            Log.w("SmsMonitorService", "Could not setup method channel on retry: ${e.message}")
                            sendDebugLogToFlutter("Could not setup method channel on retry: ${e.message}")
                        }
                    } else {
                        Log.d("SmsMonitorService", "Method channel already exists")
                        sendDebugLogToFlutter("Method channel already exists")
                    }
                    
                    // Try method channel first
                    Log.d("SmsMonitorService", "Attempting to send via method channel...")
                    sendDebugLogToFlutter("Attempting to send via method channel...")
                    try {
                        methodChannel?.invokeMethod("onSmsReceived", mapOf(
                            "sender" to sender,
                            "message" to message,
                            "timestamp" to timestamp
                        ))
                        Log.d("SmsMonitorService", "✅ SMS sent via method channel successfully")
                        sendDebugLogToFlutter("✅ SMS sent via method channel successfully")
                    } catch (e: Exception) {
                        Log.e("SmsMonitorService", "❌ Method channel failed: ${e.message}")
                        sendDebugLogToFlutter("❌ Method channel failed: ${e.message}")
                        e.printStackTrace()
                    }
                    
                    // Always write to shared preferences as backup
                    Log.d("SmsMonitorService", "Writing SMS to shared preferences...")
                    sendDebugLogToFlutter("Writing SMS to shared preferences...")
                    writeSmsToSharedPrefs(sender, message, timestamp)
                    
                    Log.d("SmsMonitorService", "✅ SMS processing completed")
                    sendDebugLogToFlutter("✅ SMS processing completed")
                    
                } catch (e: Exception) {
                    Log.e("SmsMonitorService", "❌ Error sending SMS to Flutter: ${e.message}")
                    sendDebugLogToFlutter("❌ Error sending SMS to Flutter: ${e.message}")
                    e.printStackTrace()
                }
            }

    private fun writeSmsToSharedPrefs(sender: String, message: String, timestamp: String) {
        try {
            Log.d("SmsMonitorService", "=== WRITING SMS TO SHARED PREFERENCES ===")
            sendDebugLogToFlutter("=== WRITING SMS TO SHARED PREFERENCES ===")
            
            val prefs = getSharedPreferences("sms_data", MODE_PRIVATE)
            val receivedAt = System.currentTimeMillis().toString()
            val smsData = mapOf(
                "sender" to sender,
                "message" to message,
                "timestamp" to timestamp,
                "received_at" to receivedAt
            )
            
            Log.d("SmsMonitorService", "SMS Data: $smsData")
            sendDebugLogToFlutter("SMS Data: $smsData")
            
            val existingSms = prefs.getStringSet("sms_messages", mutableSetOf()) ?: mutableSetOf()
            Log.d("SmsMonitorService", "Existing SMS count: ${existingSms.size}")
            sendDebugLogToFlutter("Existing SMS count: ${existingSms.size}")
            
            val smsJson = smsData.entries.joinToString("|") { "${it.key}=${it.value}" }
            Log.d("SmsMonitorService", "SMS JSON: $smsJson")
            sendDebugLogToFlutter("SMS JSON: $smsJson")
            
            existingSms.add(smsJson)
            Log.d("SmsMonitorService", "Added SMS to set, new count: ${existingSms.size}")
            sendDebugLogToFlutter("Added SMS to set, new count: ${existingSms.size}")
            
            // Keep only last 20 SMS
            val finalSmsSet = if (existingSms.size > 20) {
                val sortedSms = existingSms.sortedBy { 
                    it.split("|").find { it.startsWith("received_at=") }?.split("=")?.get(1)?.toLongOrNull() ?: 0L 
                }
                val trimmed = sortedSms.takeLast(20).toSet()
                Log.d("SmsMonitorService", "Trimmed SMS set to 20, final count: ${trimmed.size}")
                sendDebugLogToFlutter("Trimmed SMS set to 20, final count: ${trimmed.size}")
                trimmed
            } else {
                Log.d("SmsMonitorService", "SMS set size OK, keeping all ${existingSms.size}")
                sendDebugLogToFlutter("SMS set size OK, keeping all ${existingSms.size}")
                existingSms
            }
            
            // Store as JSON string for Flutter compatibility
            val smsList = finalSmsSet.toList()
            val jsonString = smsList.joinToString("|||")
            Log.d("SmsMonitorService", "Final JSON string length: ${jsonString.length}")
            sendDebugLogToFlutter("Final JSON string length: ${jsonString.length}")
            
            prefs.edit().putString("sms_messages_json", jsonString).apply()
            
            Log.d("SmsMonitorService", "✅ SMS written to shared preferences successfully")
            sendDebugLogToFlutter("✅ SMS written to shared preferences successfully")
            
        } catch (e: Exception) {
            Log.e("SmsMonitorService", "❌ Error writing SMS to shared preferences: ${e.message}")
            sendDebugLogToFlutter("❌ Error writing SMS to shared preferences: ${e.message}")
            e.printStackTrace()
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
