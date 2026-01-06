import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, int> _cart = {}; // productId -> quantity

  Map<int, int> get cart => _cart;

  void addToCart(ProductModel product, [int quantity = 1]) {
    if (_cart.containsKey(product.id)) {
      _cart[product.id!] = _cart[product.id!]! + quantity;
    } else {
      _cart[product.id!] = quantity;
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _cart.remove(productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
    } else {
      _cart[productId] = quantity;
      notifyListeners();
    }
  }

  double total(List<ProductModel> products) {
    double sum = 0;
    _cart.forEach((id, qty) {
      final product = products.firstWhere((p) => p.id == id);
      sum += product.price * qty;
    });
    return sum;
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}
