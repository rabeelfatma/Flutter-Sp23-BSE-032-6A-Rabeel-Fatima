import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            onTap: () => Navigator.pushNamed(context, '/notification-settings'),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text("Theme"),
            subtitle: const Text("Switch between light and dark mode"),
            onTap: () {
              // TODO: Implement theme toggle
            },
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            text: "Logout",
            onPressed: () {
              // TODO: Add actual logout logic
            },
          ),
        ],
      ),
    );
  }
}
