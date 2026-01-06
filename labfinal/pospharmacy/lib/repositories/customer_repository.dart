import '../database/sqlite_helper.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  // Get all customers
  Future<List<CustomerModel>> getAllCustomers() async {
    final data = await SQLiteHelper.getCustomers();
    return data.map((e) => CustomerModel.fromMap(e)).toList();
  }

  // Add customer
  Future<void> addCustomer(CustomerModel customer) async {
    await SQLiteHelper.insertCustomer(customer.toMap());
  }

  // Delete customer
  Future<void> deleteCustomer(int id) async {
    await SQLiteHelper.deleteCustomer(id);
  }

  // Get customer sales history
  Future<List<Map<String, dynamic>>> getCustomerHistory(int customerId) async {
    return await SQLiteHelper.getCustomerHistory(customerId);
  }
}
