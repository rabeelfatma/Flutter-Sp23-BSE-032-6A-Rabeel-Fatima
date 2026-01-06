import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Initialize notification service (simulated)
  Future<void> init() async {
    debugPrint("🔔 NotificationService initialized (simulated)");
  }

  /// Show notification (simulated using SnackBar)
  void showNotification({
    required BuildContext context,
    required String title,
    required String body,
  }) {
    debugPrint("🔔 NOTIFICATION");
    debugPrint("Title: $title");
    debugPrint("Body: $body");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$title\n$body"),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
