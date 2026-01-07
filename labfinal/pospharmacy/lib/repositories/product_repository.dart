import '../database/sqlite_helper.dart';
import '../models/product_model.dart';

class ProductRepository {
  /// Get all products
  Future<List<ProductModel>> getAllProducts() async {
    final data = await SQLiteHelper.getProducts();
    return data.map((e) => ProductModel.fromMap(e)).toList();
  }

  /// Add product
  Future<void> addProduct(ProductModel product) async {
    await SQLiteHelper.insertProduct(product.toMap());
  }

  /// Update product
  Future<void> updateProduct(ProductModel product) async {
    if (product.id != null) {
      await SQLiteHelper.updateProduct(product.id!, product.toMap());
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

  /// Update stock after sale
  Future<void> updateStock(int productId, int newStock) async {
    await SQLiteHelper.updateProductStock(productId, newStock);
  }
}
