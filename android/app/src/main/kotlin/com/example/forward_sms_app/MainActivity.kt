package com.example.forward_sms_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log
import android.content.Intent

class MainActivity: FlutterActivity() {
    private val CHANNEL = "sms_service"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            Log.d("MainActivity", "Method called: ${call.method}")
            
            when (call.method) {
                "test" -> {
                    Log.d("MainActivity", "Test method called successfully")
                    result.success("Test successful")
                }
                "onSmsReceived" -> {
                    Log.d("MainActivity", "SMS received method called")
                    result.success("SMS received")
                }
                "debugLog" -> {
                    Log.d("MainActivity", "Debug log: ${call.arguments}")
                    result.success("Debug log received")
                }
                "checkSmsReceiver" -> {
                    Log.d("MainActivity", "Checking SMS receiver status")
                    // Check if SMS permissions are granted
                    val smsPermission = checkSelfPermission(android.Manifest.permission.RECEIVE_SMS)
                    val readSmsPermission = checkSelfPermission(android.Manifest.permission.READ_SMS)
                    val status = "SMS receiver registered. RECEIVE_SMS: $smsPermission, READ_SMS: $readSmsPermission"
                    Log.d("MainActivity", status)
                    result.success(status)
                }
                "triggerSmsReceiver" -> {
                    Log.d("MainActivity", "Triggering SMS receiver directly")
                    val smsData = call.arguments as Map<String, Any>
                    val smsReceiver = SmsReceiver()
                    smsReceiver.sendSmsToFlutter(this, 
                        smsData["sender"] as String, 
                        smsData["message"] as String, 
                        smsData["timestamp"] as String
                    )
                    result.success("SMS receiver triggered")
                }
                "testBroadcastReceiver" -> {
                    Log.d("MainActivity", "Testing broadcast receiver")
                    val intent = Intent("android.provider.Telephony.SMS_RECEIVED")
                    sendBroadcast(intent)
                    result.success("Broadcast sent")
                }
                "startSmsMonitoring" -> {
                    Log.d("MainActivity", "Starting SMS monitoring service")
                    val serviceIntent = Intent(this, SmsMonitorService::class.java)
                    startService(serviceIntent)
                    result.success("SMS monitoring started")
                }
                "stopSmsMonitoring" -> {
                    Log.d("MainActivity", "Stopping SMS monitoring service")
                    val serviceIntent = Intent(this, SmsMonitorService::class.java)
                    stopService(serviceIntent)
                    result.success("SMS monitoring stopped")
                }
                "checkSmsMonitoring" -> {
                    Log.d("MainActivity", "Checking SMS monitoring status")
                    val isRunning = isServiceRunning(SmsMonitorService::class.java)
                    result.success("SMS monitoring running: $isRunning")
                }
                "triggerSmsCheck" -> {
                    Log.d("MainActivity", "Triggering SMS check manually")
                    val serviceIntent = Intent(this, SmsMonitorService::class.java)
                    serviceIntent.putExtra("action", "check_sms")
                    startService(serviceIntent)
                    result.success("SMS check triggered")
                }
                "testServiceCommunication" -> {
                    Log.d("MainActivity", "Testing service communication")
                    val serviceIntent = Intent(this, SmsMonitorService::class.java)
                    serviceIntent.putExtra("action", "test_communication")
                    startService(serviceIntent)
                    result.success("Service communication test triggered")
                }
                else -> {
                    Log.w("MainActivity", "Unknown method: ${call.method}")
                    result.notImplemented()
                }
            }
        }
        
        Log.d("MainActivity", "Method channel configured successfully")
    }

    private fun isServiceRunning(serviceClass: Class<*>): Boolean {
        val activityManager = getSystemService(ACTIVITY_SERVICE) as android.app.ActivityManager
        val services = activityManager.getRunningServices(Integer.MAX_VALUE)
        
        for (service in services) {
            if (serviceClass.name == service.service.className) {
                return true
            }
        }
        return false
    }
}
