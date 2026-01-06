import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// DriveService (SIMULATED)
/// ------------------------
/// University / PDF purpose ke liye
/// Google Drive ki jagah local export use kiya gaya hai
/// (No external dependencies, No errors)

class DriveService {

  /// Simulate "Upload to Drive"
  /// Actually file ko export folder mein copy karta hai
  Future<String> uploadFile(File backupFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/drive_backup');

    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final newFile = File(
      '${exportDir.path}/${backupFile.uri.pathSegments.last}',
    );

    await backupFile.copy(newFile.path);

    return newFile.path;
  }

  /// Check if "Drive backup" exists
  Future<bool> driveBackupExists(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/drive_backup/$fileName');
    return file.exists();
  }
}
