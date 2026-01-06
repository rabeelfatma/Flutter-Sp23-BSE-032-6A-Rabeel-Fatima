import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../database/sqlite_helper.dart';
import '../../widgets/primary_button.dart';
import '../../services/notification_service.dart';

class RestoreScreen extends StatefulWidget {
  const RestoreScreen({super.key});

  @override
  State<RestoreScreen> createState() => _RestoreScreenState();
}

class _RestoreScreenState extends State<RestoreScreen> {
  bool isRestoring = false;

  Future<void> _restoreData() async {
    setState(() => isRestoring = true);

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/backup.json");

      if (!await file.exists()) {
        NotificationService().showNotification(
          context: context,
          title: "Restore",
          body: "No backup found",
        );
        return;
      }

      final content = await file.readAsString();
      final data = jsonDecode(content);

      for (var p in data["products"]) {
        await SQLiteHelper.insertProduct(Map<String, dynamic>.from(p));
      }
      for (var s in data["sales"]) {
        await SQLiteHelper.insertSale(Map<String, dynamic>.from(s));
      }
      for (var c in data["customers"]) {
        await SQLiteHelper.insertCustomer(Map<String, dynamic>.from(c));
      }

      NotificationService().showNotification(
        context: context,
        title: "Restore Successful",
        body: "Your data has been restored successfully",
      );
    } catch (e) {
      NotificationService().showNotification(
        context: context,
        title: "Restore Failed",
        body: e.toString(),
      );
    } finally {
      setState(() => isRestoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Restore Data")),
      body: Center(
        child: isRestoring
            ? const CircularProgressIndicator()
            : PrimaryButton(
          text: "Restore Backup",
          onPressed: _restoreData,
        ),
      ),
    );
  }
}
