import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../database/sqlite_helper.dart';

class BackupService {
  // Create JSON backup
  Future<String> backup() async {
    final products = await SQLiteHelper.getProducts();
    final sales = await SQLiteHelper.getSales();
    final customers = await SQLiteHelper.getCustomers();

    final data = {
      'products': products,
      'sales': sales,
      'customers': customers,
    };

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/backup.json');
    await file.writeAsString(jsonEncode(data));
    return file.path;
  }

  // Restore from JSON backup
  Future<void> restore() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/backup.json');

    if (!await file.exists()) return;

    final content = await file.readAsString();
    final data = jsonDecode(content);

    final products = data['products'] as List<dynamic>;
    final sales = data['sales'] as List<dynamic>;
    final customers = data['customers'] as List<dynamic>;

    for (var p in products) {
      await SQLiteHelper.insertProduct(Map<String, dynamic>.from(p));
    }
    for (var s in sales) {
      await SQLiteHelper.insertSale(Map<String, dynamic>.from(s));
    }
    for (var c in customers) {
      await SQLiteHelper.insertCustomer(Map<String, dynamic>.from(c));
    }
  }
}
