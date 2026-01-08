import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DriveService {
  /// Upload to "Drive" (simulated local folder)
  Future<String> uploadFile(File backupFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/drive_backup');

    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final newFile = File('${exportDir.path}/${backupFile.uri.pathSegments.last}');
    await backupFile.copy(newFile.path);

    return newFile.path;
  }

  /// Check if backup exists in "Drive"
  Future<bool> driveBackupExists(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/drive_backup/$fileName');
    return file.exists();
  }
}
