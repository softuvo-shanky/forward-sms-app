import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/sms_service_simple.dart';
import '../services/email_service.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  static const MethodChannel _channel = MethodChannel('sms_service');
  List<String> _debugLogs = [];
  bool _isAutoTesting = false;
  bool _isMonitoringStarted = false;
  Map<String, bool> _testResults = {};

  @override
  void initState() {
    super.initState();
    _setupMethodChannel();
    _startAutoTesting();
  }

  void _setupMethodChannel() {
    _channel.setMethodCallHandler((call) async {
      setState(() {
        _debugLogs.add('📞 Method called: ${call.method}');
      });
      
      if (call.method == 'onSmsReceived') {
        final Map<dynamic, dynamic> smsData = call.arguments;
        setState(() {
          _debugLogs.add('📱 SMS received: ${smsData['sender']} - ${smsData['message']}');
        });
      } else if (call.method == 'debugLog') {
        setState(() {
          _debugLogs.add('🐛 ANDROID: ${call.arguments}');
        });
      }
    });
  }

  Future<void> _startAutoTesting() async {
    if (_isAutoTesting) return;
    
    setState(() {
      _isAutoTesting = true;
      _debugLogs.clear();
      _testResults.clear();
    });

    _addLog('🚀 Starting automatic SMS system diagnostics...');
    
    // Test 1: Check permissions
    await _testPermissions();
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Test 2: Check method channel
    await _testMethodChannel();
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Test 3: Check SMS receiver status
    await _testSmsReceiverStatus();
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Test 4: Start SMS monitoring service
    await _startSmsMonitoring();
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Test 5: Check SMS forwarding status
    await _testSmsForwardingStatus();
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Test 6: Test email functionality
    await _testEmailSending();
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Test 7: Simulate SMS received
    await _simulateSmsReceived();
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Test 8: Get service debug logs
    await _getServiceDebugLogs();
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Test 9: Get SMS from service
    await _getSmsFromService();
    
    _addLog('✅ Automatic diagnostics completed!');
    setState(() {
      _isAutoTesting = false;
    });
  }

  void _addLog(String message) {
      setState(() {
      _debugLogs.add(message);
    });
  }

  void _setTestResult(String testName, bool result) {
    setState(() {
      _testResults[testName] = result;
    });
  }

  Future<void> _testPermissions() async {
    _addLog('🔐 Testing SMS permissions...');
    try {
      final smsStatus = await Permission.sms.status;
      final isGranted = smsStatus == PermissionStatus.granted;
      _setTestResult('SMS Permissions', isGranted);
      _addLog('📱 SMS Permission: ${smsStatus.toString()}');
    } catch (e) {
      _setTestResult('SMS Permissions', false);
      _addLog('❌ Error checking permissions: $e');
    }
  }

  Future<void> _testMethodChannel() async {
    _addLog('📞 Testing method channel communication...');
    try {
      final result = await _channel.invokeMethod('test', {'test': 'Method channel test'});
      _setTestResult('Method Channel', true);
      _addLog('✅ Method channel test successful: $result');
    } catch (e) {
      _setTestResult('Method Channel', false);
      _addLog('❌ Method channel test failed: $e');
    }
  }

  Future<void> _testSmsReceiverStatus() async {
    _addLog('📡 Checking SMS receiver status...');
    try {
      final result = await _channel.invokeMethod('checkSmsReceiver');
      _setTestResult('SMS Receiver', true);
      _addLog('📡 SMS receiver status: $result');
    } catch (e) {
      _setTestResult('SMS Receiver', false);
      _addLog('❌ Error checking SMS receiver: $e');
    }
  }

  Future<void> _startSmsMonitoring() async {
    _addLog('🔄 Starting SMS monitoring service...');
    try {
      await _channel.invokeMethod('startSmsMonitoring');
      _setTestResult('SMS Monitoring', true);
      _isMonitoringStarted = true;
      _addLog('✅ SMS monitoring service started');
      
      // Check if it's actually running
      await Future.delayed(const Duration(milliseconds: 500));
      final status = await _channel.invokeMethod('checkSmsMonitoring');
      _addLog('📊 SMS monitoring status: $status');
    } catch (e) {
      _setTestResult('SMS Monitoring', false);
      _addLog('❌ Error starting SMS monitoring: $e');
    }
  }

  Future<void> _testSmsForwardingStatus() async {
    _addLog('📧 Checking SMS forwarding configuration...');
    try {
      final isEnabled = await SmsService.isEnabled();
      final smtpConfig = await EmailService.getSmtpConfig();
      
      _setTestResult('SMS Forwarding', isEnabled && smtpConfig != null);
      _addLog('📧 SMS Forwarding Enabled: $isEnabled');
      _addLog('📧 SMTP Config: ${smtpConfig != null ? "Configured" : "Not Configured"}');
      
      if (smtpConfig != null) {
        _addLog('📧 SMTP Host: ${smtpConfig['smtp_host']}');
        _addLog('📧 SMTP Port: ${smtpConfig['smtp_port']}');
        _addLog('📧 Recipient: ${smtpConfig['recipient_email']}');
        _addLog('📧 Sender: ${smtpConfig['sender_email']}');
      }
    } catch (e) {
      _setTestResult('SMS Forwarding', false);
      _addLog('❌ Error checking SMS forwarding status: $e');
    }
  }

  Future<void> _testEmailSending() async {
    _addLog('📤 Testing email sending...');
    try {
      await EmailService.sendSmsToEmail(
        'DebugTest',
        'This is an automatic test email from SMS Forwarding App',
        DateTime.now().toIso8601String(),
      );
      _setTestResult('Email Sending', true);
      _addLog('✅ Test email sent successfully!');
    } catch (e) {
      _setTestResult('Email Sending', false);
      _addLog('❌ Error sending test email: $e');
    }
  }

  Future<void> _simulateSmsReceived() async {
    _addLog('📱 Simulating SMS received...');
    try {
      await _channel.invokeMethod('onSmsReceived', {
        'sender': 'AutoTest',
        'message': 'This is an automatic test SMS for debugging',
        'timestamp': DateTime.now().toIso8601String(),
      });
      _setTestResult('SMS Simulation', true);
      _addLog('✅ Simulated SMS sent to processing');
    } catch (e) {
      _setTestResult('SMS Simulation', false);
      _addLog('❌ Error simulating SMS: $e');
    }
  }

  Future<void> _getServiceDebugLogs() async {
    _addLog('📋 Getting service debug logs...');
    try {
      final result = await _channel.invokeMethod('getServiceDebugLogs');
      if (result != null && result.isNotEmpty) {
        final logs = result.split('\n');
        _addLog('📋 Found ${logs.length} service debug logs');
        for (final log in logs.take(5)) { // Show first 5 logs
          _addLog('🔧 SERVICE: $log');
        }
        if (logs.length > 5) {
          _addLog('🔧 ... and ${logs.length - 5} more service logs');
        }
      } else {
        _addLog('📋 No service debug logs found');
      }
    } catch (e) {
      _addLog('❌ Error getting service debug logs: $e');
    }
  }

  Future<void> _getSmsFromService() async {
    _addLog('📱 Getting SMS from service...');
    try {
      final result = await _channel.invokeMethod('getSmsFromService');
      if (result != null && result.isNotEmpty) {
        final smsList = result.split('\n');
        _addLog('📱 Found ${smsList.length} SMS messages from service');
        for (final sms in smsList.take(3)) { // Show first 3 SMS
            try {
              final parts = sms.split('|');
              String sender = 'Unknown';
              String message = '';
              String timestamp = '0';
              
              for (final part in parts) {
                if (part.startsWith('sender=')) {
                  sender = part.split('=')[1];
                } else if (part.startsWith('message=')) {
                  message = part.split('=')[1];
                } else if (part.startsWith('timestamp=')) {
                  timestamp = part.split('=')[1];
                }
              }
              
              final timestampInt = int.tryParse(timestamp) ?? 0;
              final dateTime = DateTime.fromMillisecondsSinceEpoch(timestampInt);
            _addLog('📱 SMS: From $sender - ${message.length > 30 ? message.substring(0, 30) + '...' : message} (${dateTime.toString().substring(0, 19)})');
            } catch (e) {
            _addLog('📱 SMS: Raw data - ${sms.length > 50 ? sms.substring(0, 50) + '...' : sms}');
          }
        }
        if (smsList.length > 3) {
          _addLog('📱 ... and ${smsList.length - 3} more SMS messages');
        }
      } else {
        _addLog('📱 No SMS found from service');
      }
    } catch (e) {
      _addLog('❌ Error getting SMS from service: $e');
    }
  }

  Future<void> _copyLogs() async {
    if (_debugLogs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No logs to copy')),
      );
      return;
    }

    // Create comprehensive log report
    final timestamp = DateTime.now().toIso8601String();
    final report = StringBuffer();
    
    report.writeln('=== SMS FORWARDING APP DIAGNOSTIC REPORT ===');
    report.writeln('Generated: $timestamp');
    report.writeln('App Version: Forward SMS App v1.0');
    report.writeln('');
    
    // Add test results summary
    if (_testResults.isNotEmpty) {
      report.writeln('=== SYSTEM STATUS SUMMARY ===');
      int passedTests = _testResults.values.where((result) => result).length;
      int totalTests = _testResults.length;
      report.writeln('Tests Passed: $passedTests/$totalTests');
      report.writeln('');
      
      for (final entry in _testResults.entries) {
        report.writeln('${entry.value ? "✅" : "❌"} ${entry.key}');
      }
      report.writeln('');
    }
    
    // Add diagnostic logs
    report.writeln('=== DETAILED DIAGNOSTIC LOGS ===');
    for (int i = 0; i < _debugLogs.length; i++) {
      report.writeln('${i + 1}. ${_debugLogs[i]}');
    }
    report.writeln('');
    
    // Add SMS logs if available
    try {
      final smsLogs = await SmsService.getSmsLogs();
      if (smsLogs.isNotEmpty) {
        report.writeln('=== SMS FORWARDING HISTORY ===');
        for (final log in smsLogs.take(10)) { // Last 10 SMS logs
          report.writeln('📱 $log');
        }
        if (smsLogs.length > 10) {
          report.writeln('... and ${smsLogs.length - 10} more SMS logs');
        }
        report.writeln('');
      }
    } catch (e) {
      report.writeln('Error getting SMS logs: $e');
    }
    
    // Add device info
    report.writeln('=== DEVICE INFORMATION ===');
    report.writeln('Platform: Android');
    report.writeln('Flutter Version: ${await _getFlutterVersion()}');
    report.writeln('Report Generated: $timestamp');
    
    await Clipboard.setData(ClipboardData(text: report.toString()));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Comprehensive diagnostic report copied to clipboard!'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<String> _getFlutterVersion() async {
    try {
      // This would normally get the Flutter version, but for now return a placeholder
      return 'Flutter 3.x';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _saveLogsToFile() async {
    if (_debugLogs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No logs to save')),
      );
      return;
    }

    try {
      // Create the same comprehensive report
      final timestamp = DateTime.now().toIso8601String();
      final report = StringBuffer();
      
      report.writeln('=== SMS FORWARDING APP DIAGNOSTIC REPORT ===');
      report.writeln('Generated: $timestamp');
      report.writeln('App Version: Forward SMS App v1.0');
      report.writeln('');
      
      // Add test results summary
      if (_testResults.isNotEmpty) {
        report.writeln('=== SYSTEM STATUS SUMMARY ===');
        int passedTests = _testResults.values.where((result) => result).length;
        int totalTests = _testResults.length;
        report.writeln('Tests Passed: $passedTests/$totalTests');
        report.writeln('');
        
        for (final entry in _testResults.entries) {
          report.writeln('${entry.value ? "✅" : "❌"} ${entry.key}');
        }
        report.writeln('');
      }
      
      // Add diagnostic logs
      report.writeln('=== DETAILED DIAGNOSTIC LOGS ===');
      for (int i = 0; i < _debugLogs.length; i++) {
        report.writeln('${i + 1}. ${_debugLogs[i]}');
      }
      report.writeln('');
      
      // Add SMS logs if available
      try {
        final smsLogs = await SmsService.getSmsLogs();
        if (smsLogs.isNotEmpty) {
          report.writeln('=== SMS FORWARDING HISTORY ===');
          for (final log in smsLogs.take(10)) {
            report.writeln('📱 $log');
          }
          if (smsLogs.length > 10) {
            report.writeln('... and ${smsLogs.length - 10} more SMS logs');
          }
          report.writeln('');
        }
      } catch (e) {
        report.writeln('Error getting SMS logs: $e');
      }
      
      // Add device info
      report.writeln('=== DEVICE INFORMATION ===');
      report.writeln('Platform: Android');
      report.writeln('Flutter Version: ${await _getFlutterVersion()}');
      report.writeln('Report Generated: $timestamp');
      
      // Save to SharedPreferences for now (since file writing requires additional permissions)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('diagnostic_report_${DateTime.now().millisecondsSinceEpoch}', report.toString());
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📁 Diagnostic report saved locally! Use Copy button to share.'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving logs: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearLogs() {
    setState(() {
      _debugLogs.clear();
      _testResults.clear();
    });
  }

  Widget _buildTestResultCard() {
    if (_testResults.isEmpty) {
      return const SizedBox.shrink();
    }

    int passedTests = _testResults.values.where((result) => result).length;
    int totalTests = _testResults.length;
    bool allPassed = passedTests == totalTests;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  allPassed ? Icons.check_circle : Icons.warning,
                  color: allPassed ? Colors.green : Colors.orange,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Status',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '$passedTests/$totalTests tests passed',
                        style: TextStyle(
                          color: allPassed ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._testResults.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    entry.value ? Icons.check : Icons.close,
                    color: entry.value ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        color: entry.value ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS System Diagnostics'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyLogs,
            tooltip: 'Copy Comprehensive Report',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveLogsToFile,
            tooltip: 'Save Logs to File',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearLogs,
            tooltip: 'Clear Logs',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startAutoTesting,
            tooltip: 'Run Tests Again',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isAutoTesting) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(width: 16),
                      Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                            const Text(
                              'Running Diagnostics...',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    Text(
                              'Testing SMS system components automatically',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ],
            _buildTestResultCard(),
            if (_testResults.isNotEmpty) const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Diagnostic Logs',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          if (!_isAutoTesting)
                            ElevatedButton.icon(
                              onPressed: _startAutoTesting,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Run Tests'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _debugLogs.isEmpty
                            ? const Center(
                                child: Text('No diagnostic logs yet. Tap "Run Tests" to start.'),
                              )
                            : ListView.builder(
                                itemCount: _debugLogs.length,
                                itemBuilder: (context, index) {
                                  final log = _debugLogs[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Text(
                                      '${index + 1}. $log',
                                      style: const TextStyle(fontFamily: 'monospace'),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}