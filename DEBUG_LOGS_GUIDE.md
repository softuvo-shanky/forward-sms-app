# 📋 Debug Logs Guide - How to Share Logs

## ✅ **Yes, logs are saved locally and can be easily shared!**

The app has a comprehensive logging system that saves all diagnostic information locally and allows you to easily copy and share it.

## 🔧 **How to Get and Share Logs:**

### **Step 1: Open Debug Screen**
1. Open the app
2. Tap the **bug icon** (🐛) in the top-right corner of the home screen
3. The debug screen will automatically run all tests

### **Step 2: Copy Comprehensive Report**
1. Wait for all tests to complete (takes ~5 seconds)
2. Tap the **copy icon** (📋) in the top-right corner
3. The app will copy a complete diagnostic report to your clipboard

### **Step 3: Share the Logs**
1. Open any messaging app (WhatsApp, Telegram, Email, etc.)
2. Paste the copied logs (Ctrl+V or long-press → Paste)
3. Send the logs to me for analysis

## 📊 **What's Included in the Report:**

The comprehensive report includes:

### **System Status Summary:**
- ✅/❌ Test results for each component
- Pass/fail count (e.g., "5/7 tests passed")

### **Detailed Diagnostic Logs:**
- SMS permission status
- Method channel communication tests
- SMS receiver registration status
- SMS monitoring service status
- Email configuration and testing
- SMS simulation results
- Service debug logs from Android

### **SMS Forwarding History:**
- Last 10 SMS messages that were processed
- Timestamps and sender information
- Message processing status

### **Device Information:**
- Platform details
- App version
- Report generation timestamp

## 💾 **Log Storage Locations:**

### **1. Debug Screen Logs (In-Memory)**
- **Location**: Debug screen session
- **Content**: All diagnostic test results
- **Access**: Copy button in debug screen

### **2. SMS Logs (SharedPreferences)**
- **Location**: `sms_logs` key in SharedPreferences
- **Content**: SMS forwarding history
- **Retention**: Last 100 SMS entries
- **Format**: `timestamp|sender|message_length`

### **3. Service Debug Logs (Android SharedPreferences)**
- **Location**: `sms_debug_logs` key in Android SharedPreferences
- **Content**: Android service debug information
- **Retention**: Last 50 service logs
- **Format**: Timestamped service logs

## 🚀 **Enhanced Features:**

### **Automatic Testing:**
- Runs all tests automatically when you open debug screen
- No need to click multiple buttons
- Shows real-time progress

### **Comprehensive Report:**
- Includes all diagnostic information in one report
- Formatted for easy reading and analysis
- Includes device and app information

### **Easy Sharing:**
- One-click copy to clipboard
- Formatted for messaging apps
- Includes all necessary context

## 📱 **Example Report Format:**

```
=== SMS FORWARDING APP DIAGNOSTIC REPORT ===
Generated: 2025-01-06T10:30:00.000Z
App Version: Forward SMS App v1.0

=== SYSTEM STATUS SUMMARY ===
Tests Passed: 6/7

✅ SMS Permissions
✅ Method Channel
✅ SMS Receiver
✅ SMS Monitoring
✅ SMS Forwarding
❌ Email Sending
✅ SMS Simulation

=== DETAILED DIAGNOSTIC LOGS ===
1. 🚀 Starting automatic SMS system diagnostics...
2. 🔐 Testing SMS permissions...
3. 📱 SMS Permission: PermissionStatus.granted
4. 📞 Testing method channel communication...
5. ✅ Method channel test successful: Test successful
...

=== SMS FORWARDING HISTORY ===
📱 2025-01-06T10:25:00.000Z|JK-ZOMATO-S|45 chars
📱 2025-01-06T10:20:00.000Z|JM-IDFCFB-S|32 chars
...

=== DEVICE INFORMATION ===
Platform: Android
Flutter Version: Flutter 3.x
Report Generated: 2025-01-06T10:30:00.000Z
```

## 🎯 **When to Share Logs:**

Share logs when:
- SMS forwarding is not working
- You're getting errors
- You want to verify the system is working correctly
- You need help troubleshooting

## 🔄 **How Often to Check:**

- **First time setup**: Run diagnostics after configuring SMTP
- **After changes**: Run diagnostics after changing settings
- **When issues occur**: Run diagnostics when SMS forwarding stops working
- **Regular maintenance**: Run diagnostics weekly to ensure everything is working

## 💡 **Pro Tips:**

1. **Run diagnostics first** before asking for help
2. **Copy the full report** - it contains all the information needed
3. **Share immediately** after running diagnostics for most accurate results
4. **Include context** - mention what you were trying to do when the issue occurred

The logging system is designed to give you and me complete visibility into what's happening with your SMS forwarding system!
