import '../../database/sqlite_helper.dart';
import '../../services/firestore_service.dart';
import 'internet_checker.dart';

class SyncManager {
  /// Call this when app opens OR internet restores
  static Future<void> syncAll() async {
    final online = await InternetChecker.isOnline();
    if (!online) return;

    await _syncSales();
    await _syncProducts();
  }

  /// Sync offline sales to cloud
  static Future<void> _syncSales() async {
    final db = await SQLiteHelper.database;

    final unsyncedSales = await db.query('sales', where: 'synced = 0');

    for (final sale in unsyncedSales) {
      // Call static method from FirestoreService
      await FirestoreService.uploadSale(sale);

      await db.update(
        'sales',
        {'synced': 1},
        where: 'id = ?',
        whereArgs: [sale['id']],
      );
    }
  }

  /// Sync offline products to cloud
  static Future<void> _syncProducts() async {
    final db = await SQLiteHelper.database;

    final unsyncedProducts = await db.query('products', where: 'synced = 0');

    for (final product in unsyncedProducts) {
      // Call static method from FirestoreService
      await FirestoreService.uploadProduct(product);

      await db.update(
        'products',
        {'synced': 1},
        where: 'id = ?',
        whereArgs: [product['id']],
      );
    }
  }
}
