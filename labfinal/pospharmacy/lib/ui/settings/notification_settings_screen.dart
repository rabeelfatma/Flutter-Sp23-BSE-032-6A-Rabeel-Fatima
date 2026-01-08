import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';
import '../../services/notification_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool salesAlerts = true;
  bool lowStockAlerts = true;
  bool newCustomerAlerts = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Load settings from Firestore
  Future<void> _loadSettings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.userEmail;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && doc.data()?['settings'] != null) {
      final settings = doc.data()!['settings'];
      setState(() {
        salesAlerts = settings['salesAlerts'] ?? true;
        lowStockAlerts = settings['lowStockAlerts'] ?? true;
        newCustomerAlerts = settings['newCustomerAlerts'] ?? true;
      });
    }
  }

  Future<void> _saveSettings() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.userEmail;
    if (uid == null) return;

    setState(() => _loading = true);

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'settings': {
        'salesAlerts': salesAlerts,
        'lowStockAlerts': lowStockAlerts,
        'newCustomerAlerts': newCustomerAlerts,
      }
    }, SetOptions(merge: true));

    setState(() => _loading = false);

    NotificationService().showNotification(
      context: context,
      title: "Settings Saved",
      body: "Your notification settings have been updated",
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notification Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("Sales Alerts"),
              value: salesAlerts,
              onChanged: (v) => setState(() => salesAlerts = v),
            ),
            SwitchListTile(
              title: const Text("Low Stock Alerts"),
              value: lowStockAlerts,
              onChanged: (v) => setState(() => lowStockAlerts = v),
            ),
            SwitchListTile(
              title: const Text("New Customer Alerts"),
              value: newCustomerAlerts,
              onChanged: (v) => setState(() => newCustomerAlerts = v),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: _loading ? "Saving..." : "Save",
              onPressed: _loading ? null : _saveSettings,
            ),
          ],
        ),
      ),
    );
  }
}
