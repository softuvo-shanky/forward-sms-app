import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

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

  void _clearLogs() {
    setState(() {
      _debugLogs.clear();
    });
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
                            onPressed: _clearLogs,
                            child: const Text('Clear Logs'),
                          ),
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
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              setState(() {});
                            },
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
