import 'dart:io'; // <-- Needed for File
import 'package:flutter/material.dart';
import '../models/backup_model.dart';
import '../services/backup_service.dart';
import '../services/drive_service.dart';

class BackupProvider extends ChangeNotifier {
  final BackupService _backupService = BackupService();
  final DriveService _driveService = DriveService();

  /// Auto backup settings
  bool autoBackupEnabled = false;
  int backupFrequencyDays = 1; // 1 = daily
  String storageType = 'local'; // 'local', 'cloud', 'both'

  /// Progress & Status
  double progress = 0.0;
  String lastMessage = "";

  /// Backup history
  List<BackupModel> backups = [];

  /// Load backup history
  Future<void> loadBackups() async {
    final data = await _backupService.getBackupHistory();
    backups = data.map((e) => BackupModel.fromMap(e)).toList();
    notifyListeners();
  }

  /// Manual backup with progress & cloud
  Future<void> backupNow() async {
    progress = 0.1;
    notifyListeners();

    String message = await _backupService.backupData();
    lastMessage = message;
    progress = 0.6;
    notifyListeners();

    if (storageType == 'cloud' || storageType == 'both') {
      final filePath = await _backupService.getBackupFilePath();
      final file = File(filePath); // <-- Now works
      await _driveService.uploadFile(file);
    }

    progress = 1.0;
    notifyListeners();
    await loadBackups();
  }

  /// Restore backup (local or cloud)
  Future<void> restoreBackup({required String filename, bool fromCloud = false}) async {
    progress = 0.0;
    notifyListeners();

    if (fromCloud) {
      final backupPath = await _backupService.getBackupFilePath();
      final directory = File(backupPath).parent; // <-- Correct usage
      final file = File('${directory.path}/drive_backup/$filename');
      if (!await file.exists()) {
        lastMessage = "Cloud backup not found";
        notifyListeners();
        return;
      }
    }

    progress = 0.3;
    notifyListeners();

    String message = await _backupService.restoreDataFromBackup(filename);
    lastMessage = message;
    progress = 1.0;
    notifyListeners();
  }

  /// Toggle auto backup
  void setAutoBackup(bool value) {
    autoBackupEnabled = value;
    notifyListeners();
  }

  /// Set backup frequency
  void setFrequency(int days) {
    backupFrequencyDays = days;
    notifyListeners();
  }

  /// Set storage type
  void setStorageType(String type) {
    storageType = type;
    notifyListeners();
  }
}
