import 'sqlite_helper.dart';

class OfflineQueue {
  // Add product to queue for sync
  static Future<void> addProduct(Map<String, dynamic> product) async {
    await SQLiteHelper.insertProduct(product);
  }

  static Future<void> addSale(Map<String, dynamic> sale) async {
    await SQLiteHelper.insertSale(sale);
  }

  static Future<void> addCustomer(Map<String, dynamic> customer) async {
    await SQLiteHelper.insertCustomer(customer);
  }

  // Fetch unsynced data
  static Future<List<Map<String, dynamic>>> getUnsyncedProducts() async {
    return SQLiteHelper.getUnsyncedProducts();
  }

  static Future<List<Map<String, dynamic>>> getUnsyncedSales() async {
    return SQLiteHelper.getUnsyncedSales();
  }

  // Mark synced
  static Future<void> markProductSynced(int id) async {
    await SQLiteHelper.markProductAsSynced(id);
  }

  static Future<void> markSaleSynced(int id) async {
    await SQLiteHelper.markSaleAsSynced(id);
  }
}
