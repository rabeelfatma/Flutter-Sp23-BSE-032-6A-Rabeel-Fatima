import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../services/backup_service.dart';
import '../../services/drive_service.dart';
import '../../widgets/primary_button.dart';
import '../../services/notification_service.dart';
import 'dart:io';

class BackupHistoryScreen extends StatefulWidget {
  const BackupHistoryScreen({super.key});

  @override
  State<BackupHistoryScreen> createState() => _BackupHistoryScreenState();
}

class _BackupHistoryScreenState extends State<BackupHistoryScreen> {
  List<Map<String, dynamic>> backups = [];
  bool isLoading = false;
  String progressMessage = "";

  @override
  void initState() {
    super.initState();
    _loadBackupHistory();
  }

  Future<void> _loadBackupHistory() async {
    setState(() => isLoading = true);

    // Load local backups
    backups = await SQLiteHelper.getBackups();

    // Load cloud backups (simulate with DriveService folder)
    final drive = DriveService();
    final List<Map<String, dynamic>> cloudBackups = [];
    for (var backup in backups) {
      bool exists = await drive.driveBackupExists(backup['filename']);
      if (exists) {
        cloudBackups.add({
          'id': backup['id'],
          'filename': backup['filename'],
          'created_at': backup['created_at'],
          'cloud': true,
        });
      }
    }

    // Merge local and cloud backups
    backups = backups.map((b) {
      bool isCloud = cloudBackups.any((c) => c['filename'] == b['filename']);
      return {...b, 'cloud': isCloud};
    }).toList();

    setState(() => isLoading = false);
  }

  Future<void> _restoreBackup(String fileName, {bool fromCloud = false}) async {
    setState(() {
      isLoading = true;
      progressMessage = "Starting restore...";
    });

    try {
      final backupService = BackupService();
      String result;

      if (fromCloud) {
        // Simulate cloud restore
        final drive = DriveService();
        final directory = await Directory.systemTemp.createTemp();
        final cloudFilePath = '${directory.path}/$fileName';
        final file = File(cloudFilePath);

        if (!await drive.driveBackupExists(fileName)) {
          throw Exception("Cloud backup not found");
        }

        result = await backupService.restoreDataFromBackup(fileName);
      } else {
        result = await backupService.restoreDataFromBackup(fileName);
      }

      NotificationService().showNotification(
        context: context,
        title: "Restore Status",
        body: result,
      );
    } catch (e) {
      NotificationService().showNotification(
        context: context,
        title: "Restore Failed",
        body: e.toString(),
      );
    }

    setState(() {
      isLoading = false;
      progressMessage = "";
    });

    _loadBackupHistory(); // Refresh history
  }

  Future<void> _deleteBackup(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this backup?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      final db = await SQLiteHelper.database;
      await db.delete('backups', where: 'id = ?', whereArgs: [id]);
      NotificationService().showNotification(
        context: context,
        title: "Backup Deleted",
        body: "Backup deleted successfully.",
      );
      _loadBackupHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Backup History")),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(progressMessage),
          ],
        ),
      )
          : backups.isEmpty
          ? const Center(child: Text("No backups available"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: backups.length,
        itemBuilder: (context, index) {
          final backup = backups[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(backup['filename'] ?? "Unknown"),
              subtitle: Text(
                "Created At: ${backup['created_at'] ?? ""}" +
                    (backup['cloud'] == true ? " (Cloud)" : ""),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.restore),
                    color: Colors.green,
                    tooltip: "Restore Backup",
                    onPressed: () => _restoreBackup(
                      backup['filename'],
                      fromCloud: backup['cloud'] == true,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    tooltip: "Delete Backup",
                    onPressed: () => _deleteBackup(backup['id']),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: PrimaryButton(
        text: "Refresh",
        onPressed: _loadBackupHistory,
      ),
    );
  }
}
