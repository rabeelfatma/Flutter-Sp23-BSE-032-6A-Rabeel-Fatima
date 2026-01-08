import 'dart:async'; // ✅ ADD
import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../widgets/empty_state.dart';

class LowStockWidget extends StatefulWidget {
  final VoidCallback? onUpdate; // optional callback to refresh dashboard

  const LowStockWidget({super.key, this.onUpdate});

  @override
  State<LowStockWidget> createState() => _LowStockWidgetState();
}

class _LowStockWidgetState extends State<LowStockWidget> {
  List<Map<String, dynamic>> lowStock = [];
  Timer? _refreshTimer; // ✅ ADD

  @override
  void initState() {
    super.initState();
    _loadLowStock();

    /// 🔥 AUTO REFRESH (real-time low stock warning)
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 2),
          (_) => _loadLowStock(),
    );
  }

  Future<void> _loadLowStock() async {
    final products = await SQLiteHelper.getProducts();

    if (!mounted) return;

    setState(() {
      lowStock = products.where((p) => (p['stock'] ?? 0) < 5).toList();
    });

    widget.onUpdate?.call(); // 🔹 Trigger dashboard refresh if callback exists
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // ✅ ADD (memory safe)
    super.dispose();
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
