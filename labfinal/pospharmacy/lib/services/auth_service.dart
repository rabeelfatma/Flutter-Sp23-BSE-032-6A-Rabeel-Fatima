import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Upload products list to Firestore (for sync)
  Future<void> uploadProducts(List<Map<String, dynamic>> products) async {
    final batch = _firestore.batch();
    final collection = _firestore.collection('products');

    for (var p in products) {
      final doc = collection.doc(p['id'].toString());
      batch.set(doc, p);
    }
    await batch.commit();
  }

  // Upload sales list to Firestore
  Future<void> uploadSales(List<Map<String, dynamic>> sales) async {
    final batch = _firestore.batch();
    final collection = _firestore.collection('sales');

    for (var s in sales) {
      final doc = collection.doc(s['id'].toString());
      batch.set(doc, s);
    }
    await batch.commit();
  }

  // Fetch products (optional)
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final snapshot = await _firestore.collection('products').get();
    return snapshot.docs.map((d) => d.data()).toList();
  }
}
