import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================= SALES =================
  static Future<void> uploadSale(Map<String, dynamic> sale) async {
    await _db.collection('sales').add(sale);
  }

  // ================= PRODUCTS =================
  static Future<void> uploadProduct(Map<String, dynamic> product) async {
    await _db.collection('products').add(product);
  }

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

  // ================= USER PROFILE =================
  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  static Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // ================= NOTIFICATION SETTINGS =================
  static Future<void> saveNotificationSettings(String uid, Map<String, dynamic> settings) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('notifications')
        .set(settings);
  }

  static Future<Map<String, dynamic>> getNotificationSettings(String uid) async {
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('notifications')
        .get();
    return doc.data() ?? {};
  }

  // ================= PRODUCTS BATCH UPLOAD (Optional) =================
  static Future<void> uploadProductsBatch(List<Map<String, dynamic>> products) async {
    final batch = _db.batch();
    final collection = _db.collection('products');
    for (var p in products) {
      final doc = collection.doc(p['id'].toString());
      batch.set(doc, p);
    }
    await batch.commit();
  }

  // ================= SALES BATCH UPLOAD (Optional) =================
  static Future<void> uploadSalesBatch(List<Map<String, dynamic>> sales) async {
    final batch = _db.batch();
    final collection = _db.collection('sales');
    for (var s in sales) {
      final doc = collection.doc(s['id'].toString());
      batch.set(doc, s);
    }
    await batch.commit();
  }
}
