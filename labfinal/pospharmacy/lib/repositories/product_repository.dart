import '../database/sqlite_helper.dart';
import '../models/product_model.dart';

class ProductRepository {
  /// Get all products
  Future<List<ProductModel>> getAllProducts() async {
    final data = await SQLiteHelper.getProducts();
    return data.map((e) => ProductModel.fromMap(e)).toList();
  }

  /// Add product with stock history
  Future<void> addProduct(ProductModel product) async {
    // Insert product
    int productId = await SQLiteHelper.insertProduct(product.toMap());

    // Record initial stock in stock history
    if (product.stock > 0) {
      await SQLiteHelper.insertStockHistory({
        'product_id': productId,
        'change': product.stock,
        'type': 'in',
        'date': DateTime.now().toIso8601String(),
      });
    }

    // Optional: Low stock alert can be handled in UI
  }

  /// Update product with stock history tracking
  Future<void> updateProduct(ProductModel product, {int? previousStock}) async {
    if (product.id != null) {
      // Calculate stock difference
      int stockDiff = (product.stock) - (previousStock ?? product.stock);
      String type = stockDiff >= 0 ? 'in' : 'out';

      // Update product in DB
      await SQLiteHelper.updateProduct(product.id!, product.toMap());

      // Record stock change if any
      if (stockDiff != 0) {
        await SQLiteHelper.insertStockHistory({
          'product_id': product.id!,
          'change': stockDiff.abs(),
          'type': type,
          'date': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  /// Delete product
  Future<void> deleteProduct(int id) async {
    await SQLiteHelper.deleteProduct(id);
  }

  /// Get unsynced products
  Future<List<ProductModel>> getUnsyncedProducts() async {
    final data = await SQLiteHelper.getUnsyncedProducts();
    return data.map((e) => ProductModel.fromMap(e)).toList();
  }

  /// Mark as synced
  Future<void> markAsSynced(int id) async {
    await SQLiteHelper.markProductAsSynced(id);
  }

  /// Update stock after sale (with stock history)
  Future<void> updateStock(int productId, int newStock, {int? oldStock}) async {
    int stockDiff = newStock - (oldStock ?? newStock);
    String type = stockDiff >= 0 ? 'in' : 'out';

    // Update product stock
    await SQLiteHelper.updateProductStock(productId, newStock);

    // Record stock history if stock changed
    if (stockDiff != 0) {
      await SQLiteHelper.insertStockHistory({
        'product_id': productId,
        'change': stockDiff.abs(),
        'type': type,
        'date': DateTime.now().toIso8601String(),
      });
    }
  }
}
