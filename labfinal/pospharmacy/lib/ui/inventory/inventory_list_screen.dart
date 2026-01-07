import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../models/product_model.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import 'product_detail_screen.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  List<ProductModel> products = [];

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

  void _goToAddProduct() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
    _loadProducts();
  }

  void _goToEditProduct(ProductModel product) async {
    await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EditProductScreen(product: product)));
    _loadProducts();
  }

  void _goToProductDetail(ProductModel product) {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)));
  }

  void _deleteProduct(ProductModel product) async {
    await SQLiteHelper.deleteProduct(product.id!);
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(onPressed: _goToAddProduct, icon: const Icon(Icons.add))
        ],
      ),
      body: products.isEmpty
          ? const Center(child: Text('No products found'))
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (_, index) {
          final p = products[index];
          return ListTile(
            title: Text(p.name),
            subtitle: Text(
                'Stock: ${p.stock} | Price: \$${p.price} | Category: ${p.category}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _goToEditProduct(p)),
                IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteProduct(p)),
              ],
            ),
            tileColor:
            p.stock <= 5 ? Colors.red.withOpacity(0.1) : null, // low stock highlight
            onTap: () => _goToProductDetail(p),
          );
        },
      ),
    );
  }
}
