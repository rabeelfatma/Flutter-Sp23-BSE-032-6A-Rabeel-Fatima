import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String sku = '';
  String name = '';
  double price = 0;
  double cost = 0;
  String category = '';
  int stock = 0;

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final product = ProductModel(
        sku: sku,
        name: name,
        price: price,
        cost: cost,
        category: category,
        stock: stock,
      );
      int productId = await SQLiteHelper.insertProduct(product.toMap());

      // Inventory Control: Stock History
      await SQLiteHelper.insertStockHistory({
        'product_id': productId,
        'change': stock,
        'type': 'in',
        'date': DateTime.now().toIso8601String(),
      });

      // Low stock alert
      if (stock <= 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Warning: Low stock (${stock})!')),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'SKU'),
                  validator: (v) => v!.isEmpty ? 'Enter SKU' : null,
                  onSaved: (v) => sku = v!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v!.isEmpty ? 'Enter name' : null,
                  onSaved: (v) => name = v!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => v!.isEmpty ? 'Enter price' : null,
                  onSaved: (v) => price = double.parse(v!),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Cost'),
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => v!.isEmpty ? 'Enter cost' : null,
                  onSaved: (v) => cost = double.parse(v!),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (v) => v!.isEmpty ? 'Enter category' : null,
                  onSaved: (v) => category = v!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Enter stock' : null,
                  onSaved: (v) => stock = int.parse(v!),
                ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: _saveProduct, child: const Text('Save'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
