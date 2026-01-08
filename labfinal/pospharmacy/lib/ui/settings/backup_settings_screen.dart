import 'package:flutter/material.dart';
import '../../services/backup_service.dart';
import '../../services/drive_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/primary_button.dart';
import 'dart:io';

class BackupSettingsScreen extends StatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  State<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends State<BackupSettingsScreen> {
  bool isProcessing = false;
  String processingMessage = "";

  bool autoBackupEnabled = false; // New: Auto Backup toggle
  bool cloudBackupEnabled = true; // New: Cloud Backup toggle
  int backupFrequencyHours = 24; // New: Frequency (hours)

  final BackupService _backupService = BackupService();
  final DriveService _driveService = DriveService();

  Future<void> _handleBackup() async {
    setState(() {
      isProcessing = true;
      processingMessage = "Backing up locally...";
    });

    final result = await _backupService.backupData();

    if (cloudBackupEnabled) {
      setState(() => processingMessage = "Uploading to Drive...");
      try {
        final filePath = await _backupService.getBackupFilePath();
        final file = File(filePath);
        final drivePath = await _driveService.uploadFile(file);

        setState(() => processingMessage = "Backup uploaded to Drive at $drivePath");
        NotificationService().showNotification(
          context: context,
          title: "Backup Completed",
          body: "$result\nUploaded to Drive: $drivePath",
        );
      } catch (e) {
        NotificationService().showNotification(
          context: context,
          title: "Drive Backup Failed",
          body: e.toString(),
        );
      }
    } else {
      NotificationService().showNotification(
        context: context,
        title: "Backup Completed",
        body: result,
      );
    }

    setState(() {
      isProcessing = false;
      processingMessage = "";
    });
  }

  Future<void> _handleRestore() async {
    setState(() {
      isProcessing = true;
      processingMessage = "Restoring from local backup...";
    });

    final result = await _backupService.restoreData();

    if (cloudBackupEnabled) {
      setState(() => processingMessage = "Checking Drive backup...");
      try {
        final driveFileName = "backup.json";
        if (await _driveService.driveBackupExists(driveFileName)) {
          await _backupService.restoreDataFromBackup(driveFileName);
          setState(() => processingMessage = "Restored from Drive backup.");
          NotificationService().showNotification(
            context: context,
            title: "Restore Completed",
            body: "$result\nRestored from Drive backup",
          );
        } else {
          NotificationService().showNotification(
            context: context,
            title: "Restore Completed",
            body: result,
          );
        }
      } catch (e) {
        NotificationService().showNotification(
          context: context,
          title: "Restore Failed",
          body: e.toString(),
        );
      }
    } else {
      NotificationService().showNotification(
        context: context,
        title: "Restore Completed",
        body: result,
      );
    }

    setState(() {
      isProcessing = false;
      processingMessage = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Backup Settings")),
      body: Center(
        child: isProcessing
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(processingMessage),
          ],
        )
            : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SwitchListTile(
                title: const Text("Enable Auto Backup"),
                value: autoBackupEnabled,
                onChanged: (val) => setState(() => autoBackupEnabled = val),
              ),
              if (autoBackupEnabled)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Backup Frequency (hours)"),
                    SizedBox(
                      width: 60,
                      child: TextFormField(
                        initialValue: backupFrequencyHours.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          final parsed = int.tryParse(val);
                          if (parsed != null && parsed > 0) {
                            backupFrequencyHours = parsed;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              SwitchListTile(
                title: const Text("Enable Cloud Backup"),
                value: cloudBackupEnabled,
                onChanged: (val) => setState(() => cloudBackupEnabled = val),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: "Backup Now",
                onPressed: _handleBackup,
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: "Restore Backup",
                onPressed: _handleRestore,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
