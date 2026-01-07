import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userName;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  String? get userName => _userName;

  // ✅ Setter for userName
  set userName(String? name) {
    _userName = name;
    notifyListeners();
  }

  /// Login using Firestore
  Future<bool> login(String email, String password) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password) // For production: hash passwords
          .get();

      if (query.docs.isNotEmpty) {
        _isLoggedIn = true;
        _userEmail = email;
        _userName = query.docs.first['name'] ?? '';
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Login error: $e");
      return false;
    }
  }

  /// Signup using Firestore
  Future<bool> signup(String name, String email, String password) async {
    try {
      // Check if email already exists
      final existing = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (existing.docs.isNotEmpty) return false;

      await _firestore.collection('users').add({
        'name': name,
        'email': email,
        'password': password, // hash in production
      });

      return true;
    } catch (e) {
      debugPrint("Signup error: $e");
      return false;
    }
  }

  /// Reset Password
  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;
        await _firestore
            .collection('users')
            .doc(docId)
            .update({'password': newPassword});
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Reset password error: $e");
      return false;
    }
  }

  /// Logout
  void logout() {
    _isLoggedIn = false;
    _userEmail = null;
    _userName = null;
    notifyListeners();
  }
}
