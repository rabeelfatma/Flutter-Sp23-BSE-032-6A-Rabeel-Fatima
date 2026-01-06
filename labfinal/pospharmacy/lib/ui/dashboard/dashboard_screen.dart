import 'package:flutter/material.dart';
import '../../database/sqlite_helper.dart';
import '../../core/utils/sync_manager.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/sync_indicator.dart';
import 'sales_chart_widget.dart';
import 'low_stock_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalProducts = 0;
  int totalSales = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
    SyncManager.syncAll(); // Sync when dashboard opens
  }

  Future<void> _loadStats() async {
    final products = await SQLiteHelper.getProducts();
    final sales = await SQLiteHelper.getSales();

    setState(() {
      totalProducts = products.length;
      totalSales = sales.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [SyncIndicator()], // stateful widget, remove const
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                StatCard(title: 'Products', count: totalProducts),
                const SizedBox(width: 16),
                StatCard(title: 'Sales', count: totalSales),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: SalesChartWidget()),
            const SizedBox(height: 20),
            LowStockWidget(),
          ],
        ),
      ),
    );
  }
}
