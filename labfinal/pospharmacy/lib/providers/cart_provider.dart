import 'package:flutter/material.dart';

class CartItem {
  final int productId;
  final String name;
  final double price;
  int quantity;
  final int stock;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.stock,
  });
}

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {}; // productId -> CartItem

  /// Add product to cart
  void addItem(int productId, double price, String name, int stock) {
    if (_items.containsKey(productId)) {
      // Increase quantity if stock allows
      if (_items[productId]!.quantity < stock) {
        _items[productId]!.quantity += 1;
      }
    } else {
      _items[productId] = CartItem(
        productId: productId,
        name: name,
        price: price,
        quantity: 1,
        stock: stock,
      );
    }
    notifyListeners();
  }

  /// Decrease quantity of item
  void decreaseItem(int productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity > 1) {
        _items[productId]!.quantity -= 1;
      } else {
        _items.remove(productId);
      }
      notifyListeners();
    }
  }

  /// Remove item completely
  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  /// Clear cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// All items in cart
  List<CartItem> get items => _items.values.toList();

  /// Total number of items
  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  /// Total price of cart
  double get totalPrice => _items.values.fold(0, (sum, item) => sum + (item.price * item.quantity));

  /// Get raw cart map (productId -> quantity)
  Map<int, int> get cart => _items.map((key, item) => MapEntry(key, item.quantity));
}
