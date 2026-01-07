import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../widgets/empty_state.dart';

class CartScreen extends StatefulWidget {
  final Map<int, int> cart;
  final List<ProductModel> products;
  final VoidCallback onCheckout;

  const CartScreen({
    super.key,
    required this.cart,
    required this.products,
    required this.onCheckout,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void _removeItem(int productId) {
    setState(() => widget.cart.remove(productId));
  }

  void _updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      _removeItem(productId);
    } else {
      setState(() => widget.cart[productId] = quantity);
    }
  }

  double get total {
    double sum = 0;
    widget.cart.forEach((id, qty) {
      final product = widget.products.firstWhere((p) => p.id == id);
      sum += product.price * qty;
    });
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cart.isEmpty) {
      return const Scaffold(
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
            final product = widget.products.firstWhere((p) => p.id == e.key);
            return ListTile(
              title: Text(product.name),
              subtitle: Text(
                  'Price: \$${product.price} | Qty: ${e.value}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () =>
                          _updateQuantity(e.key, e.value - 1)),
                  IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () =>
                          _updateQuantity(e.key, e.value + 1)),
                  IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeItem(e.key)),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          Text(
            'Total: \$${total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: widget.onCheckout,
            child: const Text("Proceed to Checkout"),
          ),
        ],
      ),
    );
  }
}
