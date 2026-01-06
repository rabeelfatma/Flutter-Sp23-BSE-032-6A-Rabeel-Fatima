import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../database/sqlite_helper.dart';
import '../../widgets/primary_button.dart';
import '../../services/notification_service.dart';

class BackupSettingsScreen extends StatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  State<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends State<BackupSettingsScreen> {
  bool isBackingUp = false;

  Future<void> _backupData() async {
    setState(() => isBackingUp = true);

    try {
      final products = await SQLiteHelper.getProducts();
      final sales = await SQLiteHelper.getSales();
      final customers = await SQLiteHelper.getCustomers();

      if (products.isEmpty && sales.isEmpty && customers.isEmpty) {
        NotificationService().showNotification(
          context: context,
          title: "Backup",
          body: "Nothing to backup",
        );
        return;
      }

      final data = {
        "products": products,
        "sales": sales,
        "customers": customers,
      };

      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/backup.json");
      await file.writeAsString(jsonEncode(data));

      NotificationService().showNotification(
        context: context,
        title: "Backup Completed",
        body: "Your data has been backed up successfully",
      );
    } catch (e) {
      NotificationService().showNotification(
        context: context,
        title: "Backup Failed",
        body: e.toString(),
      );
    } finally {
      setState(() => isBackingUp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Backup Settings")),
      body: Center(
        child: isBackingUp
            ? const CircularProgressIndicator()
            : PrimaryButton(
          text: "Backup Now",
          onPressed: _backupData,
        ),
      ),
    );
  }
}
