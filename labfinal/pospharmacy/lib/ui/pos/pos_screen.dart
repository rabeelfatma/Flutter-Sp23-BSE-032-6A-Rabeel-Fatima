import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/sqlite_helper.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/empty_state.dart';
import 'checkout_screen.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  List<ProductModel> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final data = await SQLiteHelper.getProducts();
      setState(() {
        products = data.map((e) => ProductModel.fromMap(e)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products: $e')),
      );
    }
  }

  void _addToCart(ProductModel product) {
    if (product.id == null || product.stock == 0) return;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(product.id!, product.price, product.name, product.stock);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} added to cart')),
    );
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(products: products),
      ),
    ).then((_) => _loadProducts()); // Reload products after checkout
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("POS"),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (cartProvider.itemCount > 0)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${cartProvider.itemCount}',
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: cartProvider.itemCount == 0 ? null : _openCart,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
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
        itemBuilder: (_, i) {
          final p = products[i];
          return Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Price: \$${p.price}"),
                Text("Stock: ${p.stock}"),
                ElevatedButton(
                  onPressed: () => _addToCart(p),
                  child: const Text("Add"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
