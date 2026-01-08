import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= PRODUCTS =================
  Future<void> uploadProducts(List<Map<String, dynamic>> products) async {
    final batch = _firestore.batch();
    final collection = _firestore.collection('products');

    for (var p in products) {
      final doc = collection.doc(p['id'].toString());
      batch.set(doc, p);
    }
    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final snapshot = await _firestore.collection('products').get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  // ================= SALES =================
  Future<void> uploadSales(List<Map<String, dynamic>> sales) async {
    final batch = _firestore.batch();
    final collection = _firestore.collection('sales');

    for (var s in sales) {
      final doc = collection.doc(s['id'].toString());
      batch.set(doc, s);
    }
    await batch.commit();
  }

  // ================= USER PROFILE =================
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // ================= NOTIFICATION SETTINGS =================
  Future<void> saveNotificationSettings(String uid, Map<String, dynamic> settings) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('notifications')
        .set(settings);
  }

  Future<Map<String, dynamic>> getNotificationSettings(String uid) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('notifications')
        .get();
    return doc.data() ?? {};
  }
}
