import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../models/product_model.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late String sku;
  late String name;
  late double price;
  late double cost;
  late String category;
  late int stock;

  @override
  void initState() {
    super.initState();
    sku = widget.product.sku;
    name = widget.product.name;
    price = widget.product.price;
    cost = widget.product.cost;
    category = widget.product.category;
    stock = widget.product.stock;
  }

  void _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      int stockDiff = stock - widget.product.stock;
      String type = stockDiff >= 0 ? 'in' : 'out';

      final updated = ProductModel(
        id: widget.product.id,
        sku: sku,
        name: name,
        price: price,
        cost: cost,
        category: category,
        stock: stock,
      );

      await SQLiteHelper.updateProduct(widget.product.id!, updated.toMap());

      // Inventory Control: Stock History
      if (stockDiff != 0) {
        await SQLiteHelper.insertStockHistory({
          'product_id': widget.product.id!,
          'change': stockDiff.abs(),
          'type': type,
          'date': DateTime.now().toIso8601String(),
        });
      }

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
      appBar: AppBar(title: const Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: sku,
                  decoration: const InputDecoration(labelText: 'SKU'),
                  validator: (v) => v!.isEmpty ? 'Enter SKU' : null,
                  onSaved: (v) => sku = v!,
                ),
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v!.isEmpty ? 'Enter name' : null,
                  onSaved: (v) => name = v!,
                ),
                TextFormField(
                  initialValue: price.toString(),
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => v!.isEmpty ? 'Enter price' : null,
                  onSaved: (v) => price = double.parse(v!),
                ),
                TextFormField(
                  initialValue: cost.toString(),
                  decoration: const InputDecoration(labelText: 'Cost'),
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => v!.isEmpty ? 'Enter cost' : null,
                  onSaved: (v) => cost = double.parse(v!),
                ),
                TextFormField(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (v) => v!.isEmpty ? 'Enter category' : null,
                  onSaved: (v) => category = v!,
                ),
                TextFormField(
                  initialValue: stock.toString(),
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Enter stock' : null,
                  onSaved: (v) => stock = int.parse(v!),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: _updateProduct, child: const Text('Update'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
