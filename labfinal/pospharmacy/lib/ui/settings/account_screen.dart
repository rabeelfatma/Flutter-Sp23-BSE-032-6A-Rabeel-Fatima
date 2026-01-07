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
            onTap: () {
              // TODO: Navigate to Profile Edit Screen
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile Screen clicked")));
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            subtitle: const Text("Update your account password"),
            onTap: () {
              // TODO: Navigate to Change Password Screen
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Change Password clicked")));
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            subtitle: const Text("Manage app notifications"),
            onTap: () {
              // TODO: Navigate to Notification Settings
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Notifications clicked")));
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text("Theme"),
            subtitle: const Text("Switch between light and dark mode"),
            onTap: () {
              // TODO: Switch app theme logic
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Theme clicked")));
            },
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            text: "Logout",
            onPressed: () {
              // TODO: Add actual logout logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Logged out (demo)")),
              );
            },
          ),
        ],
      ),
    );
  }
}
