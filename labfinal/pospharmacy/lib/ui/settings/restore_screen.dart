import 'package:flutter/material.dart';
import 'dart:convert'; // Required for jsonDecode
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../database/sqlite_helper.dart'; // Correct path
import '../../widgets/primary_button.dart';
import '../../services/notification_service.dart';
import '../../services/backup_service.dart';
import '../../services/drive_service.dart';

class RestoreScreen extends StatefulWidget {
  const RestoreScreen({super.key});

  @override
  State<RestoreScreen> createState() => _RestoreScreenState();
}

class _RestoreScreenState extends State<RestoreScreen> {
  bool isRestoring = false;
  String progressMessage = "";

  final BackupService _backupService = BackupService();
  final DriveService _driveService = DriveService();

  Future<void> _restoreData({bool fromDrive = false}) async {
    setState(() {
      isRestoring = true;
      progressMessage = "Starting restore...";
    });

    try {
      String backupFilePath;

      if (fromDrive) {
        final driveFileName = "backup.json";
        final exists = await _driveService.driveBackupExists(driveFileName);
        if (!exists) {
          NotificationService().showNotification(
            context: context,
            title: "Restore Failed",
            body: "No backup found in Drive",
          );
          setState(() => isRestoring = false);
          return;
        }
        backupFilePath = (await _backupService.getBackupFilePath())
            .replaceAll("backup.json", driveFileName); // Simulated path
      } else {
        backupFilePath = await _backupService.getBackupFilePath();
      }

      final backupFile = File(backupFilePath);

      if (!backupFile.existsSync()) {
        NotificationService().showNotification(
          context: context,
          title: "Restore Failed",
          body: "No backup file found",
        );
        setState(() => isRestoring = false);
        return;
      }

      final content = await backupFile.readAsString();
      final data = content.isNotEmpty ? jsonDecode(content) : null;

      if (data == null) throw Exception("Backup file is empty or corrupted");

      // Clear all existing data before restore
      setState(() => progressMessage = "Clearing existing data...");
      await SQLiteHelper.clearAllData();

      // Restore Products
      setState(() => progressMessage = "Restoring Products...");
      if (data['products'] != null) {
        await _backupService.restoreProducts(data['products']);
      }

      // Restore Sales
      setState(() => progressMessage = "Restoring Sales...");
      if (data['sales'] != null) {
        await _backupService.restoreSales(data['sales']);
      }

      // Restore Customers
      setState(() => progressMessage = "Restoring Customers...");
      if (data['customers'] != null) {
        await _backupService.restoreCustomers(data['customers']);
      }

      NotificationService().showNotification(
        context: context,
        title: "Restore Completed",
        body: "All data restored successfully",
      );
    } catch (e) {
      NotificationService().showNotification(
        context: context,
        title: "Restore Failed",
        body: e.toString(),
      );
    } finally {
      setState(() {
        isRestoring = false;
        progressMessage = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Restore Data")),
      body: Center(
        child: isRestoring
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(progressMessage),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PrimaryButton(
              text: "Restore Local Backup",
              onPressed: () => _restoreData(fromDrive: false),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: "Restore Drive Backup",
              onPressed: () => _restoreData(fromDrive: true),
            ),
          ],
        ),
      ),
    );
  }
}
