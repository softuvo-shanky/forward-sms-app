package com.example.forward_sms_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
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
            } else {
                Log.e("SmsMonitorService", "Flutter engine not found")
            }
        } catch (e: Exception) {
            Log.e("SmsMonitorService", "Error setting up method channel: ${e.message}")
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
            
            methodChannel?.invokeMethod("onSmsReceived", mapOf(
                "sender" to sender,
                "message" to message,
                "timestamp" to timestamp
            ))
            
            Log.d("SmsMonitorService", "SMS sent to Flutter successfully")
            sendDebugLogToFlutter("SMS sent to Flutter successfully")
            
        } catch (e: Exception) {
            Log.e("SmsMonitorService", "Error sending SMS to Flutter: ${e.message}")
            sendDebugLogToFlutter("Error sending SMS to Flutter: ${e.message}")
        }
    }

    private fun sendDebugLogToFlutter(message: String) {
        try {
            methodChannel?.invokeMethod("debugLog", "SERVICE: $message")
        } catch (e: Exception) {
            Log.e("SmsMonitorService", "Error sending debug log: ${e.message}")
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
