import 'package:flutter/material.dart';
import '../database/sqlite_helper.dart';
import '../models/product_model.dart';

class InventoryProvider extends ChangeNotifier {
  List<ProductModel> _products = [];

  List<ProductModel> get products => _products;

  Future<void> loadProducts() async {
    final data = await SQLiteHelper.getProducts();
    _products = data.map((e) => ProductModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addProduct(ProductModel product) async {
    await SQLiteHelper.insertProduct(product.toMap());
    await loadProducts();
  }

  Future<void> updateProduct(ProductModel product) async {
    await SQLiteHelper.updateProduct(product.id!, product.toMap());
    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await SQLiteHelper.deleteProduct(id);
    await loadProducts();
  }
}
