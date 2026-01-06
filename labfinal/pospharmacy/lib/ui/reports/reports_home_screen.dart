import 'package:flutter/material.dart';
import 'daily_report_screen.dart';
import 'monthly_report_screen.dart';
import 'stock_report_screen.dart';
import 'customer_report_screen.dart';

class ReportsHomeScreen extends StatelessWidget {
  const ReportsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.today),
            title: const Text("Daily Sales Report"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DailyReportScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.date_range),
            title: const Text("Monthly Sales Report"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MonthlyReportScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text("Stock Report"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StockReportScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Customer Report"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomerReportScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
