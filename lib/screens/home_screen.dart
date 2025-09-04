import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/sms_service_simple.dart';
import '../services/email_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isEnabled = false;
  bool _isLoading = true;
  Map<String, dynamic>? _smtpConfig;
  int _smsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final isEnabled = await SmsService.isEnabled();
    final smtpConfig = await EmailService.getSmtpConfig();
    final smsCount = await SmsService.getSmsCount();
    
    setState(() {
      _isEnabled = isEnabled;
      _smtpConfig = smtpConfig;
      _smsCount = smsCount;
      _isLoading = false;
    });
  }

  Future<void> _toggleSmsForwarding(bool value) async {
    if (value) {
      // Check if SMTP is configured
      if (_smtpConfig == null) {
        _showSnackBar('Please configure SMTP settings first', isError: true);
        return;
      }
      
      // Check SMS permission
      final status = await Permission.sms.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.sms.request();
        if (result != PermissionStatus.granted) {
          _showSnackBar('SMS permission is required', isError: true);
          return;
        }
      }
    }

    await SmsService.setEnabled(value);
    setState(() {
      _isEnabled = value;
    });
    
    _showSnackBar(
      value ? 'SMS forwarding enabled' : 'SMS forwarding disabled',
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _testEmailConnection() async {
    if (_smtpConfig == null) {
      _showSnackBar('Please configure SMTP settings first', isError: true);
      return;
    }

    _showSnackBar('Testing email connection...');
    
    final success = await EmailService.testConnection();
    _showSnackBar(
      success ? 'Email connection successful!' : 'Email connection failed',
      isError: !success,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forward SMS App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              if (result == true) {
                _loadSettings();
              }
            },
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
                    Row(
                      children: [
                        Icon(
                          Icons.message,
                          color: _isEnabled ? Colors.green : Colors.grey,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SMS Forwarding',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                _isEnabled ? 'Enabled' : 'Disabled',
                                style: TextStyle(
                                  color: _isEnabled ? Colors.green : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isEnabled,
                          onChanged: _toggleSmsForwarding,
                        ),
                      ],
                    ),
                    if (_isEnabled) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'All incoming SMS messages will be forwarded to your email',
                                style: TextStyle(color: Colors.green.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.email,
                          color: _smtpConfig != null ? Colors.blue : Colors.grey,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email Configuration',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                _smtpConfig != null ? 'Configured' : 'Not Configured',
                                style: TextStyle(
                                  color: _smtpConfig != null ? Colors.blue : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_smtpConfig != null)
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _testEmailConnection,
                            tooltip: 'Test Email Connection',
                          ),
                      ],
                    ),
                    if (_smtpConfig != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SMTP Server: ${_smtpConfig!['smtp_host']}:${_smtpConfig!['smtp_port']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('Recipient: ${_smtpConfig!['recipient_email']}'),
                            Text('Sender: ${_smtpConfig!['sender_email']}'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics,
                          color: Colors.green,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SMS Statistics',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                'Messages forwarded: $_smsCount',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadSettings,
                          tooltip: 'Refresh Statistics',
                        ),
                      ],
                    ),
                    if (_smsCount > 0) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'SMS forwarding is working! Check your email for forwarded messages.',
                                style: TextStyle(color: Colors.green.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
                if (result == true) {
                  _loadSettings();
                }
              },
              icon: const Icon(Icons.settings),
              label: const Text('Configure Settings'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            if (_smtpConfig != null)
              OutlinedButton.icon(
                onPressed: _testEmailConnection,
                icon: const Icon(Icons.send),
                label: const Text('Test Email Connection'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
