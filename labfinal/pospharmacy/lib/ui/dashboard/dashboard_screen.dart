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
    SyncManager.syncAll();
  }

  Future<void> _loadStats() async {
    final products = await SQLiteHelper.getProducts();
    final sales = await SQLiteHelper.getSales();

    if (!mounted) return;
    setState(() {
      totalProducts = products.length;
      totalSales = sales.length;
    });
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: const [
          SyncIndicator(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔹 STATS
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Products',
                    count: totalProducts,
                    color: themeColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    title: 'Sales',
                    count: totalSales,
                    color: themeColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔹 QUICK NAVIGATION
            Card(
              child: Column(
                children: [
                  _menuTile(
                    icon: Icons.point_of_sale,
                    title: 'POS / Billing',
                    route: '/pos',
                  ),
                  _menuTile(
                    icon: Icons.inventory,
                    title: 'Inventory',
                    route: '/inventory',
                  ),
                  _menuTile(
                    icon: Icons.people,
                    title: 'Customers',
                    route: '/customers',
                  ),
                  _menuTile(
                    icon: Icons.receipt_long,
                    title: 'Reports',
                    route: '/reports',
                  ),
                  _menuTile(
                    icon: Icons.settings,
                    title: 'Settings',
                    route: '/settings',
                  ),
                  const Divider(),
                  ListTile(
                    leading:
                    const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: _logout,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔹 SALES CHART
            const SizedBox(
              height: 250,
              child: SalesChartWidget(),
            ),

            const SizedBox(height: 20),

            /// 🔹 LOW STOCK
            const LowStockWidget(),
          ],
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String route,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          onTap: () => Navigator.pushNamed(context, route),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
