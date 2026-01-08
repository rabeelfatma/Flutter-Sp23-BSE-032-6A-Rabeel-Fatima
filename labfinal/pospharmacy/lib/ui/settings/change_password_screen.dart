import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/primary_button.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _loading = false;

  void _savePassword() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    bool success = await authProvider.resetPassword(
      authProvider.userEmail ?? "",
      newPasswordController.text.trim(),
    );

    setState(() => _loading = false);

    if (success) {
      NotificationService().showNotification(
        context: context,
        title: "Password Changed",
        body: "Your password has been updated successfully",
      );
      newPasswordController.clear();
      confirmPasswordController.clear();
    } else {
      NotificationService().showNotification(
        context: context,
        title: "Error",
        body: "Failed to update password",
      );
    }
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "New Password",
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Enter new password";
                  if (val.length < 6) return "Password must be at least 6 chars";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return "Confirm password";
                  if (val != newPasswordController.text) return "Passwords do not match";
                  return null;
                },
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: _loading ? "Saving..." : "Save",
                onPressed: _loading ? null : _savePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
