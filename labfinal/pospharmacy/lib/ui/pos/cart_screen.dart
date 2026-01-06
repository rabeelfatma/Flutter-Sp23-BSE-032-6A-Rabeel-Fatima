import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import 'checkout_screen.dart';
import '../../widgets/empty_state.dart'; // Added for empty cart

class CartScreen extends StatefulWidget {
  final Map<int, int> cart; // productId -> quantity
  final List<ProductModel> products;

  const CartScreen({super.key, required this.cart, required this.products});

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CheckoutScreen(cart: widget.cart, products: widget.products),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cart')),
        body: EmptyState(
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
            final product =
            widget.products.firstWhere((p) => p.id == e.key);
            return ListTile(
              title: Text(product.name),
              subtitle:
              Text('Price: \$${product.price} | Quantity: ${e.value}'),
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
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: _checkout, child: const Text('Proceed to Checkout'))
        ],
      ),
    );
  }
}
