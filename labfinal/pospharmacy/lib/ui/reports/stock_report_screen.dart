import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../widgets/empty_state.dart';

class StockReportScreen extends StatefulWidget {
  const StockReportScreen({super.key});

  @override
  State<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends State<StockReportScreen> {
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final list = await SQLiteHelper.getProducts();
    setState(() {
      products = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stock Report")),
      body: products.isEmpty
          ? EmptyState(message: "No products available", icon: Icons.inventory)
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text("Product")),
            DataColumn(label: Text("Stock")),
            DataColumn(label: Text("Price")),
          ],
          rows: products
              .map((p) => DataRow(cells: [
            DataCell(Text(p['name'])),
            DataCell(Text(p['stock'].toString())),
            DataCell(Text("\$${p['price']}")),
          ]))
              .toList(),
        ),
      ),
    );
  }
}
