import 'package:flutter/material.dart';
import '../database/sqlite_helper.dart';
import '../models/customer_model.dart';

class CustomerProvider extends ChangeNotifier {
  List<CustomerModel> _customers = [];

  List<CustomerModel> get customers => _customers;

  Future<void> loadCustomers() async {
    final data = await SQLiteHelper.getCustomers();
    _customers = data.map((e) => CustomerModel.fromMap(e)).toList();
    notifyListeners();
  }

  Future<void> addCustomer(CustomerModel customer) async {
    await SQLiteHelper.insertCustomer(customer.toMap());
    await loadCustomers();
  }

  Future<void> deleteCustomer(int id) async {
    await SQLiteHelper.deleteCustomer(id);
    await loadCustomers();
  }
}
