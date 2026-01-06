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
          const ListTile(
            leading: Icon(Icons.person),
            title: Text("Profile"),
            subtitle: Text("Edit your profile details"),
          ),
          const ListTile(
            leading: Icon(Icons.lock),
            title: Text("Change Password"),
            subtitle: Text("Update your account password"),
          ),
          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Notifications"),
            subtitle: Text("Manage app notifications"),
          ),
          const ListTile(
            leading: Icon(Icons.color_lens),
            title: Text("Theme"),
            subtitle: Text("Switch between light and dark mode"),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            text: "Logout",
            onPressed: () {
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
