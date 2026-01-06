import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../widgets/empty_state.dart'; // fixed import

class LowStockWidget extends StatefulWidget {
  const LowStockWidget({super.key});

  @override
  State<LowStockWidget> createState() => _LowStockWidgetState();
}

class _LowStockWidgetState extends State<LowStockWidget> {
  List<Map<String, dynamic>> lowStock = [];

  @override
  void initState() {
    super.initState();
    _loadLowStock();
  }

  Future<void> _loadLowStock() async {
    final products = await SQLiteHelper.getProducts();
    setState(() {
      lowStock = products.where((p) => (p['stock'] ?? 0) < 5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (lowStock.isEmpty) {
      return const EmptyState(
        message: "No low stock products",
        icon: Icons.inventory,
      );
    }

    return Card(
      color: Colors.red[100],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Low Stock Products',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...lowStock.map(
                  (p) => Text('${p['name']} - Stock: ${p['stock']}'),
            ),
          ],
        ),
      ),
    );
  }
}
