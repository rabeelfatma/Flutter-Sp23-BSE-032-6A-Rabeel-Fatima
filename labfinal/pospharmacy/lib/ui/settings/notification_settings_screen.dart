import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';
import '../../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool salesAlerts = true;
  bool lowStockAlerts = true;
  bool newCustomerAlerts = true;

  Future<void> _saveSettings() async {
    // TODO: Save notification settings in SQLite / SharedPreferences

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
              text: "Save",
              onPressed: _saveSettings,
            ),
          ],
        ),
      ),
    );
  }
}
