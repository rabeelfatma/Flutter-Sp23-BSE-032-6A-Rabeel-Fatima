import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/primary_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart'; // <-- Added ThemeProvider import

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context); // <-- Added

    return Scaffold(
      appBar: AppBar(title: const Text("Account Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            subtitle: const Text("Edit your profile details"),
            onTap: () => Navigator.pushNamed(context, '/profile-edit'),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            subtitle: const Text("Update your account password"),
            onTap: () => Navigator.pushNamed(context, '/change-password'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            subtitle: const Text("Manage app notifications"),
            onTap: () =>
                Navigator.pushNamed(context, '/notification-settings'),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text("Theme"),
            subtitle: const Text("Switch between light and dark mode"),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            text: "Logout",
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
