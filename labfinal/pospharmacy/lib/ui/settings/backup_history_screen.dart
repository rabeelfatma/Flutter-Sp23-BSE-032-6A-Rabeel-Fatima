import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../services/backup_service.dart';
import '../../widgets/primary_button.dart';
import '../../services/notification_service.dart';

class BackupHistoryScreen extends StatefulWidget {
  const BackupHistoryScreen({super.key});

  @override
  State<BackupHistoryScreen> createState() => _BackupHistoryScreenState();
}

class _BackupHistoryScreenState extends State<BackupHistoryScreen> {
  List<Map<String, dynamic>> backups = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBackupHistory();
  }

  Future<void> _loadBackupHistory() async {
    setState(() => isLoading = true);
    backups = await SQLiteHelper.getBackups();
    setState(() => isLoading = false);
  }

  Future<void> _restoreBackup(String fileName) async {
    setState(() => isLoading = true);
    try {
      final result = await BackupService().restoreData();
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
    setState(() => isLoading = false);
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
          ? const Center(child: CircularProgressIndicator())
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
              subtitle: Text("Created At: ${backup['created_at'] ?? ""}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.restore),
                    color: Colors.green,
                    tooltip: "Restore Backup",
                    onPressed: () => _restoreBackup(backup['filename']),
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
