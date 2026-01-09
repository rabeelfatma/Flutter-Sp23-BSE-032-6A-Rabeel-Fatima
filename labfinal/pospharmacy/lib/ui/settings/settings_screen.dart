import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// 🌙 THEME TOGGLE
          SwitchListTile(
            secondary: Icon(
              themeProvider.isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            title: const Text("Dark Mode"),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),

          const Divider(),

          /// Manual Backup
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text("Backup Data"),
            onTap: () =>
                Navigator.pushNamed(context, '/backupSettings'), // 🔹 Correct route
          ),

          /// Restore Backup / Restore Data
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text("Restore Data"),
            onTap: () =>
                Navigator.pushNamed(context, '/backupSettings'), // 🔹 Points to BackupSettingsScreen for full restore functionality
          ),

          /// 🔹 Backup History (NEW)
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Backup History"),
            onTap: () =>
                Navigator.pushNamed(context, '/backupHistory'),
          ),

          const Divider(),

          /// Account Settings
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text("Account Settings"),
            onTap: () =>
                Navigator.pushNamed(context, '/account'),
          ),
        ],
      ),
    );
  }
}
