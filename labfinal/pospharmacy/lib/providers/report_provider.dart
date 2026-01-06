import 'package:flutter/material.dart';
import '../database/sqlite_helper.dart';

class ReportProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _sales = [];

  List<Map<String, dynamic>> get sales => _sales;

  double get total => _sales.fold(0, (sum, s) => sum + (s['amount']?.toDouble() ?? 0));

  Future<void> loadDailySales() async {
    final allSales = await SQLiteHelper.getSales();
    final today = DateTime.now();
    _sales = allSales.where((s) {
      final date = DateTime.parse(s['datetime']);
      return date.year == today.year && date.month == today.month && date.day == today.day;
    }).toList();
    notifyListeners();
  }

  Future<void> loadMonthlySales() async {
    final allSales = await SQLiteHelper.getSales();
    final now = DateTime.now();
    _sales = allSales.where((s) {
      final date = DateTime.parse(s['datetime']);
      return date.year == now.year && date.month == now.month;
    }).toList();
    notifyListeners();
  }
}

