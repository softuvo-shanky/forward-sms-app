import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
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
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _setupMethodChannel();
    _checkPermissions();
  }

  void _setupMethodChannel() {
    _channel.setMethodCallHandler((call) async {
      setState(() {
        _debugLogs.add('Method called: ${call.method}');
      });
      
      if (call.method == 'onSmsReceived') {
        final Map<dynamic, dynamic> smsData = call.arguments;
        setState(() {
          _debugLogs.add('SMS received: ${smsData['sender']} - ${smsData['message']}');
        });
      } else if (call.method == 'debugLog') {
        setState(() {
          _debugLogs.add('ANDROID: ${call.arguments}');
        });
      }
    });
  }

  Future<void> _checkPermissions() async {
    final smsStatus = await Permission.sms.status;
    setState(() {
      _debugLogs.add('SMS Permission: ${smsStatus.toString()}');
    });
  }

  Future<void> _testSmsReceiver() async {
    setState(() {
      _debugLogs.add('Testing SMS receiver...');
    });

    try {
      // Test if method channel is working at all
      await _channel.invokeMethod('test', {});
      setState(() {
        _debugLogs.add('Method channel test successful');
      });
    } catch (e) {
      setState(() {
        _debugLogs.add('Method channel test failed: $e');
      });
    }

    try {
      // Simulate an SMS for testing
      await _channel.invokeMethod('onSmsReceived', {
        'sender': 'Test123',
        'message': 'This is a test SMS',
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      setState(() {
        _debugLogs.add('Test SMS sent to receiver');
      });
    } catch (e) {
      setState(() {
        _debugLogs.add('Error testing SMS receiver: $e');
      });
    }
  }

  Future<void> _checkSmsReceiverStatus() async {
    setState(() {
      _debugLogs.add('Checking SMS receiver status...');
    });

    try {
      // Check if we can call the SMS receiver directly
      final result = await _channel.invokeMethod('checkSmsReceiver');
      setState(() {
        _debugLogs.add('SMS receiver status: $result');
      });
    } catch (e) {
      setState(() {
        _debugLogs.add('Error checking SMS receiver: $e');
      });
    }
  }

  Future<void> _testSmsReceiverDirectly() async {
    setState(() {
      _debugLogs.add('Testing SMS receiver directly...');
    });

    try {
      // Try to trigger the SMS receiver directly
      await _channel.invokeMethod('triggerSmsReceiver', {
        'sender': 'DirectTest123',
        'message': 'Direct test SMS',
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      setState(() {
        _debugLogs.add('Direct SMS receiver test sent');
      });
    } catch (e) {
      setState(() {
        _debugLogs.add('Error testing SMS receiver directly: $e');
      });
    }
  }

  Future<void> _testBroadcastReceiver() async {
    setState(() {
      _debugLogs.add('Testing broadcast receiver...');
    });

    try {
      // Test if we can send a broadcast to our receiver
      await _channel.invokeMethod('testBroadcastReceiver');
      setState(() {
        _debugLogs.add('Broadcast test sent');
      });
    } catch (e) {
      setState(() {
        _debugLogs.add('Error testing broadcast receiver: $e');
      });
    }
  }

  Future<void> _startSmsMonitoring() async {
    setState(() {
      _debugLogs.add('Starting SMS monitoring service...');
    });

    try {
      await _channel.invokeMethod('startSmsMonitoring');
      setState(() {
        _debugLogs.add('SMS monitoring service started');
      });
    } catch (e) {
      setState(() {
        _debugLogs.add('Error starting SMS monitoring: $e');
      });
    }
  }

  Future<void> _stopSmsMonitoring() async {
    setState(() {
      _debugLogs.add('Stopping SMS monitoring service...');
    });

    try {
      await _channel.invokeMethod('stopSmsMonitoring');
      setState(() {
        _debugLogs.add('SMS monitoring service stopped');
      });
    } catch (e) {
      setState(() {
        _debugLogs.add('Error stopping SMS monitoring: $e');
      });
    }
  }

  Future<void> _checkSmsMonitoring() async {
    setState(() {
      _debugLogs.add('Checking SMS monitoring status...');
    });

    try {
      final result = await _channel.invokeMethod('checkSmsMonitoring');
      setState(() {
        _debugLogs.add('SMS monitoring status: $result');
      });
    } catch (e) {
      setState(() {
        _debugLogs.add('Error checking SMS monitoring: $e');
      });
    }
  }

  Future<void> _triggerSmsCheck() async {
    setState(() {
      _debugLogs.add('Triggering manual SMS check...');
    });

    try {
      await _channel.invokeMethod('triggerSmsCheck');
      setState(() {
        _debugLogs.add('Manual SMS check triggered');
      });
    } catch (e) {
      setState(() {
        _debugLogs.add('Error triggering SMS check: $e');
      });
    }
  }

  Future<void> _checkAllRecentSms() async {
    setState(() {
      _debugLogs.add('Checking all recent SMS...');
    });

    try {
      await _channel.invokeMethod('checkAllRecentSms');
      setState(() {
        _debugLogs.add('All recent SMS check triggered');
      });
    } catch (e) {
      setState(() {
        _debugLogs.add('Error checking all recent SMS: $e');
      });
    }
  }

  Future<void> _checkSmsFromService() async {
    setState(() {
      _debugLogs.add('Checking SMS from service manually...');
    });

    try {
      await SmsService.checkSmsFromService();
      setState(() {
        _debugLogs.add('Manual SMS check from service completed');
      });
    } catch (e) {
      setState(() {
        _debugLogs.add('Error checking SMS from service: $e');
      });
    }
  }

  Future<void> _testServiceCommunication() async {
    setState(() {
      _debugLogs.add('Testing service communication...');
    });

    try {
      await _channel.invokeMethod('testServiceCommunication');
      setState(() {
        _debugLogs.add('Service communication test triggered');
      });
    } catch (e) {
      setState(() {
        _debugLogs.add('Error testing service communication: $e');
      });
    }
  }

  Future<void> _getServiceDebugLogs() async {
    setState(() {
      _debugLogs.add('Getting service debug logs...');
    });

    try {
      final result = await _channel.invokeMethod('getServiceDebugLogs');
      if (result != null && result.isNotEmpty) {
        final logs = result.split('\n');
        setState(() {
          for (final log in logs) {
            _debugLogs.add('SERVICE: $log');
          }
        });
      } else {
        setState(() {
          _debugLogs.add('No service debug logs found');
        });
      }
    } catch (e) {
      setState(() {
        _debugLogs.add('Error getting service debug logs: $e');
      });
    }
  }

  Future<void> _getSmsFromService() async {
    setState(() {
      _debugLogs.add('Getting SMS from service...');
    });

    try {
      final result = await _channel.invokeMethod('getSmsFromService');
      if (result != null && result.isNotEmpty) {
        final smsList = result.split('\n');
        setState(() {
          for (final sms in smsList) {
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
              _debugLogs.add('SMS: From $sender - $message (${dateTime.toString()})');
            } catch (e) {
              _debugLogs.add('SMS: Raw data - $sms');
            }
          }
        });
      } else {
        setState(() {
          _debugLogs.add('No SMS found from service');
        });
      }
    } catch (e) {
      setState(() {
        _debugLogs.add('Error getting SMS from service: $e');
      });
    }
  }

  Future<void> _checkSmsForwardingStatus() async {
    setState(() {
      _debugLogs.add('Checking SMS forwarding status...');
    });

    try {
      final isEnabled = await SmsService.isEnabled();
      final smtpConfig = await EmailService.getSmtpConfig();
      
      setState(() {
        _debugLogs.add('SMS Forwarding Enabled: $isEnabled');
        _debugLogs.add('SMTP Config: ${smtpConfig != null ? "Configured" : "Not Configured"}');
        if (smtpConfig != null) {
          _debugLogs.add('SMTP Host: ${smtpConfig['smtp_host']}');
          _debugLogs.add('SMTP Port: ${smtpConfig['smtp_port']}');
          _debugLogs.add('Recipient: ${smtpConfig['recipient_email']}');
          _debugLogs.add('Sender: ${smtpConfig['sender_email']}');
        }
      });
    } catch (e) {
      setState(() {
        _debugLogs.add('Error checking SMS forwarding status: $e');
      });
    }
  }

  Future<void> _testEmailSending() async {
    setState(() {
      _debugLogs.add('Testing email sending...');
    });

    try {
      await EmailService.sendSmsToEmail(
        'TestSender',
        'This is a test SMS message for debugging',
        DateTime.now().toIso8601String(),
      );
      setState(() {
        _debugLogs.add('Test email sent successfully!');
      });
    } catch (e) {
      setState(() {
        _debugLogs.add('Error sending test email: $e');
      });
    }
  }

  Future<void> _simulateSmsReceived() async {
    setState(() {
      _debugLogs.add('Simulating SMS received...');
    });

    try {
      // Simulate an SMS being received through the method channel
      await _channel.invokeMethod('onSmsReceived', {
        'sender': 'SimulatedSender',
        'message': 'This is a simulated SMS for testing forwarding',
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      setState(() {
        _debugLogs.add('Simulated SMS sent to processing');
      });
      
      // Wait a moment and check if it was processed
      await Future.delayed(const Duration(seconds: 2));
      await _checkSmsLogs();
    } catch (e) {
      setState(() {
        _debugLogs.add('Error simulating SMS: $e');
      });
    }
  }

  Future<void> _testMethodChannelDirectly() async {
    setState(() {
      _debugLogs.add('Testing method channel directly...');
    });

    try {
      // Test if we can call the method channel directly
      await _channel.invokeMethod('onSmsReceived', {
        'sender': 'DirectTest',
        'message': 'Direct method channel test',
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      setState(() {
        _debugLogs.add('Direct method channel call successful');
      });
      
      // Wait and check logs
      await Future.delayed(const Duration(seconds: 2));
      await _checkSmsLogs();
    } catch (e) {
      setState(() {
        _debugLogs.add('Error with direct method channel: $e');
      });
    }
  }

  Future<void> _checkMethodChannelStatus() async {
    setState(() {
      _debugLogs.add('Checking method channel status...');
    });

    try {
      // Test basic method channel communication
      final result = await _channel.invokeMethod('test', {'test': 'Method channel status check'});
      setState(() {
        _debugLogs.add('Method channel test result: $result');
      });
      
      // Test if we can receive method calls
      setState(() {
        _debugLogs.add('Method channel is working - can send calls to Android');
        _debugLogs.add('Now testing if Android can call Flutter...');
      });
      
      // Trigger a test from Android side
      await _channel.invokeMethod('testServiceCommunication');
      
    } catch (e) {
      setState(() {
        _debugLogs.add('Method channel error: $e');
      });
    }
  }

  Future<void> _checkSmsLogs() async {
    setState(() {
      _debugLogs.add('Checking SMS logs...');
    });

    try {
      final logs = await SmsService.getSmsLogs();
      setState(() {
        _debugLogs.add('SMS Logs count: ${logs.length}');
        for (int i = 0; i < logs.length && i < 10; i++) {
          _debugLogs.add('Log ${i + 1}: ${logs[i]}');
        }
        if (logs.length > 10) {
          _debugLogs.add('... and ${logs.length - 10} more logs');
        }
      });
    } catch (e) {
      setState(() {
        _debugLogs.add('Error checking SMS logs: $e');
      });
    }
  }

  void _clearLogs() {
    setState(() {
      _debugLogs.clear();
    });
  }

  Future<void> _copyLogs() async {
    if (_debugLogs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No logs to copy')),
      );
      return;
    }

    final logsText = _debugLogs.asMap().entries
        .map((entry) => '${entry.key + 1}. ${entry.value}')
        .join('\n');
    
    await Clipboard.setData(ClipboardData(text: logsText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Screen'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyLogs,
            tooltip: 'Copy Logs',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearLogs,
            tooltip: 'Clear Logs',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SMS Receiver Debug',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _testSmsReceiver,
                            child: const Text('Test SMS Receiver'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _checkSmsReceiverStatus,
                            child: const Text('Check Status'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _testSmsReceiverDirectly,
                            child: const Text('Direct Test'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _testBroadcastReceiver,
                            child: const Text('Broadcast Test'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _startSmsMonitoring,
                            child: const Text('Start Monitoring'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _stopSmsMonitoring,
                            child: const Text('Stop Monitoring'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _checkSmsMonitoring,
                            child: const Text('Check Status'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _triggerSmsCheck,
                            child: const Text('Check SMS Now'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _checkAllRecentSms,
                            child: const Text('Check All Recent'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _testServiceCommunication,
                            child: const Text('Test Communication'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _getServiceDebugLogs,
                            child: const Text('Get Service Logs'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(), // Empty space
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _getSmsFromService,
                            child: const Text('Get SMS from Service'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _checkSmsFromService,
                            child: const Text('Check SMS Processing'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _checkSmsForwardingStatus,
                            child: const Text('Check Forwarding Status'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _testEmailSending,
                            child: const Text('Test Email Sending'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _simulateSmsReceived,
                            child: const Text('Simulate SMS Received'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _testMethodChannelDirectly,
                            child: const Text('Test Method Channel'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _checkSmsLogs,
                            child: const Text('Check SMS Logs'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _checkMethodChannelStatus,
                            child: const Text('Check Method Channel'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _clearLogs,
                            child: const Text('Clear Logs'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(), // Empty space
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This will simulate an SMS to test if the receiver is working.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                            'Debug Logs',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: _copyLogs,
                            tooltip: 'Copy All Logs',
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              setState(() {});
                            },
                            tooltip: 'Refresh',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _debugLogs.isEmpty
                            ? const Center(
                                child: Text('No debug logs yet. Send a test SMS or tap "Test SMS Receiver".'),
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
