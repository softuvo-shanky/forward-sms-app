package com.example.forward_sms_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

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
                else -> {
                    Log.w("MainActivity", "Unknown method: ${call.method}")
                    result.notImplemented()
                }
            }
        }
        
        Log.d("MainActivity", "Method channel configured successfully")
    }
}
