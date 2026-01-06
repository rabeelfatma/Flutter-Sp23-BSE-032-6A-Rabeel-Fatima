import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../models/product_model.dart';
import '../../services/notification_service.dart'; // 🔔 Notification
import 'cart_screen.dart';
import '../../widgets/empty_state.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  List<ProductModel> products = [];
  Map<int, int> cart = {}; // productId -> quantity

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final list = await SQLiteHelper.getProducts();
    setState(() {
      products = list.map((e) => ProductModel.fromMap(e)).toList();
    });
  }

  void _addToCart(ProductModel product) {
    if (product.id == null) return;

    // 🔔 LOW STOCK NOTIFICATION
    if (product.stock <= 5) {
      NotificationService().showNotification(
        context: context,
        title: "Low Stock Alert",
        body: "${product.name} stock is low",
      );
    }

    setState(() {
      if (cart.containsKey(product.id)) {
        cart[product.id!] = cart[product.id!]! + 1;
      } else {
        cart[product.id!] = 1;
      }
    });
  }

  void _goToCart() {
    if (cart.isEmpty) {
      NotificationService().showNotification(
        context: context,
        title: "Cart Empty",
        body: "Please add products to cart",
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartScreen(cart: cart, products: products),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _goToCart,
          ),
        ],
      ),
      body: products.isEmpty
          ? const EmptyState(
        message: "No products available",
        icon: Icons.inventory_2_outlined,
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: products.length,
        itemBuilder: (_, index) {
          final p = products[index];
          return Card(
            elevation: 4,
            child: InkWell(
              onTap: () => _addToCart(p),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Price: \$${p.price}'),
                    Text('Stock: ${p.stock}'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _addToCart(p),
                      child: const Text('Add to Cart'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
