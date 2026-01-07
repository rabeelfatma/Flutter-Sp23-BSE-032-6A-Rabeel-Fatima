import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../widgets/empty_state.dart'; // For empty cart

class CartScreen extends StatefulWidget {
  final Map<int, int> cart; // productId -> quantity
  final List<ProductModel> products;
  final VoidCallback onCheckout; // NEW: callback for checkout

  const CartScreen({
    super.key,
    required this.cart,
    required this.products,
    required this.onCheckout, // required now
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void _removeItem(int productId) {
    setState(() {
      widget.cart.remove(productId);
    });
  }

  void _updateQuantity(int productId, int quantity) {
    if (quantity <= 0) return _removeItem(productId);
    setState(() {
      widget.cart[productId] = quantity;
    });
  }

  double get total {
    double sum = 0;
    widget.cart.forEach((id, qty) {
      final product = widget.products.firstWhere((p) => p.id == id);
      sum += product.price * qty;
    });
    return sum;
  }

  void _checkout() {
    if (widget.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cart is empty! Please add products first."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Call POSScreen's logic for stock update + sales insert
    widget.onCheckout();

    // After checkout, clear cart
    setState(() {
      widget.cart.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Checkout successful!"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context); // go back to POS screen
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cart')),
        body: const EmptyState(
          message: "Cart is empty",
          icon: Icons.shopping_cart_outlined,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...widget.cart.entries.map((e) {
            final product = widget.products.firstWhere((p) => p.id == e.key);
            return ListTile(
              title: Text(product.name),
              subtitle: Text('Price: \$${product.price.toStringAsFixed(2)} | Quantity: ${e.value}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _updateQuantity(e.key, e.value - 1)),
                  IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _updateQuantity(e.key, e.value + 1)),
                  IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeItem(e.key)),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          Text('Total: \$${total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: _checkout,
              child: const Text('Proceed to Checkout')),
        ],
      ),
    );
  }
}
