import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sales upload
  static Future<void> uploadSale(Map<String, dynamic> sale) async {
    await _db.collection('sales').add(sale);
  }

  // Products upload
  static Future<void> uploadProduct(Map<String, dynamic> product) async {
    await _db.collection('products').add(product);
  }

  // Optional: CRUD for products
  static Future<void> addProduct(Map<String, dynamic> data) async {
    await _db.collection('products').add(data);
  }

  static Stream<QuerySnapshot> getProducts() {
    return _db.collection('products').snapshots();
  }

  static Future<void> updateProduct(String docId, Map<String, dynamic> data) async {
    await _db.collection('products').doc(docId).update(data);
  }

  static Future<void> deleteProduct(String docId) async {
    await _db.collection('products').doc(docId).delete();
  }
}
