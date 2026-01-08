import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userName;
  String? _uid; // Firestore document ID

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= GETTERS =================
  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get uid => _uid;

  // ================= SETTERS =================
  set userName(String? name) {
    _userName = name;
    notifyListeners();
  }

  // ================= LOGIN =================
  Future<bool> login(String email, String password) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return false;

      final userData = querySnapshot.docs.first.data();
      final docId = querySnapshot.docs.first.id;

      if (userData['password'] != password) return false;

      _isLoggedIn = true;
      _userEmail = email.trim();
      _userName = userData['name'] ?? '';
      _uid = docId;
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Login Error: $e');
      return false;
    }
  }

  // ================= SIGNUP =================
  Future<bool> signup(String name, String email, String password) async {
    try {
      final existingUser = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        return false; // Email already exists
      }

      final docRef = await _firestore.collection('users').add({
        'name': name.trim(),
        'email': email.trim(),
        'password': password, // ⚠️ Hash in production
        'createdAt': FieldValue.serverTimestamp(),
      });

      _isLoggedIn = true;
      _userEmail = email.trim();
      _userName = name.trim();
      _uid = docRef.id;
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Signup Error: $e');
      return false;
    }
  }

  // ================= RESET PASSWORD =================
  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return false;

      final docId = querySnapshot.docs.first.id;
      await _firestore
          .collection('users')
          .doc(docId)
          .update({'password': newPassword});

      return true;
    } catch (e) {
      debugPrint('Reset Password Error: $e');
      return false;
    }
  }

  // ================= UPDATE PROFILE =================
  Future<bool> updateProfile({String? name, String? email}) async {
    if (_uid == null) return false;
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name.trim();
      if (email != null) data['email'] = email.trim();

      if (data.isEmpty) return false;

      await _firestore.collection('users').doc(_uid).update(data);

      if (name != null) _userName = name;
      if (email != null) _userEmail = email;
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Update Profile Error: $e');
      return false;
    }
  }

  // ================= UPDATE PASSWORD =================
  Future<bool> updatePassword(String newPassword) async {
    if (_uid == null) return false;
    try {
      await _firestore.collection('users').doc(_uid).update({'password': newPassword});
      return true;
    } catch (e) {
      debugPrint('Update Password Error: $e');
      return false;
    }
  }

  // ================= LOGOUT =================
  void logout() {
    _isLoggedIn = false;
    _userEmail = null;
    _userName = null;
    _uid = null;
    notifyListeners();
  }
}
