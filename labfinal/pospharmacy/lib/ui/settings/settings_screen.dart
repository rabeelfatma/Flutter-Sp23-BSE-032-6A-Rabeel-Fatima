import 'package:flutter/material.dart';
import 'backup_settings_screen.dart';
import 'restore_screen.dart';
import 'account_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text("Backup Data"),
            onTap: () => Navigator.pushNamed(context, '/backup-settings'),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text("Restore Data"),
            onTap: () => Navigator.pushNamed(context, '/restore-settings'),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text("Account Settings"),
            onTap: () => Navigator.pushNamed(context, '/account'),
          ),
        ],
      ),
    );
  }
}
