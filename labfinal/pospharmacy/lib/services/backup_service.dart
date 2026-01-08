import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../database/sqlite_helper.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  /// Manual Backup
  Future<String> backupData() async {
    try {
      final products = await SQLiteHelper.getProducts();
      final sales = await SQLiteHelper.getSales();
      final customers = await SQLiteHelper.getCustomers();

      if (products.isEmpty && sales.isEmpty && customers.isEmpty) {
        return "Nothing to backup";
      }

      final data = {
        "products": products,
        "sales": sales,
        "customers": customers,
      };

      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/backup.json");

      await file.writeAsString(jsonEncode(data));

      await SQLiteHelper.insertBackup({
        "filename": "backup.json",
        "created_at": DateTime.now().toIso8601String(),
      });

      return "Backup completed successfully";
    } catch (e) {
      return "Backup failed: ${e.toString()}";
    }
  }

  /// Restore All Data
  Future<String> restoreData() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/backup.json");

      if (!file.existsSync()) return "No backup file found";

      final content = await file.readAsString();
      final data = jsonDecode(content);

      await SQLiteHelper.clearAllData();

      if (data['products'] != null) await restoreProducts(data['products']);
      if (data['sales'] != null) await restoreSales(data['sales']);
      if (data['customers'] != null) await restoreCustomers(data['customers']);

      return "Restore completed successfully";
    } catch (e) {
      return "Restore failed: ${e.toString()}";
    }
  }

  /// Restore from a specific backup file
  Future<String> restoreDataFromBackup(String filename) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/$filename");

      if (!file.existsSync()) return "Backup file not found";

      final content = await file.readAsString();
      final data = jsonDecode(content);

      await SQLiteHelper.clearAllData();

      if (data['products'] != null) await restoreProducts(data['products']);
      if (data['sales'] != null) await restoreSales(data['sales']);
      if (data['customers'] != null) await restoreCustomers(data['customers']);

      return "Restore completed successfully";
    } catch (e) {
      return "Restore failed: $e";
    }
  }

  Future<void> restoreProducts(List<dynamic> products) async {
    final productList = products.map((e) => Map<String, dynamic>.from(e)).toList();
    await SQLiteHelper.insertProducts(productList);
  }

  Future<void> restoreSales(List<dynamic> sales) async {
    final saleList = sales.map((e) => Map<String, dynamic>.from(e)).toList();
    await SQLiteHelper.insertSales(saleList);
  }

  Future<void> restoreCustomers(List<dynamic> customers) async {
    final customerList = customers.map((e) => Map<String, dynamic>.from(e)).toList();
    await SQLiteHelper.insertCustomers(customerList);
  }

  Future<String> getBackupFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return "${dir.path}/backup.json";
  }

  /// Auto backup on app startup
  Future<void> autoBackupOnStartup() async {
    final result = await backupData();
    print("[Auto Backup] Status: $result");
  }

  /// Backup history
  Future<List<Map<String, dynamic>>> getBackupHistory() async {
    return await SQLiteHelper.getBackups();
  }
}
