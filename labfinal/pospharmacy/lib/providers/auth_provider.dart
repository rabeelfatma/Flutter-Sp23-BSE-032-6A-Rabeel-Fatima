import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userName;
  String? _profileImagePath;
  String? _uid;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get profileImagePath => _profileImagePath;
  String? get uid => _uid;

  set userName(String? v) {
    _userName = v;
    notifyListeners();
  }

  // ---------------- LOGIN ----------------
  Future<bool> login(String email, String password) async {
    try {
      final q = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (q.docs.isEmpty) return false;

      final doc = q.docs.first;
      final data = doc.data();

      if (data['password'] != password) return false;

      _isLoggedIn = true;
      _uid = doc.id;
      _userEmail = data['email'];
      _userName = data['name'];
      _profileImagePath = data['profileImage'];

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Login Error: $e");
      return false;
    }
  }

  // ---------------- SIGNUP ----------------
  Future<bool> signup(String name, String email, String password) async {
    try {
      final doc = await _firestore.collection('users').add({
        'name': name,
        'email': email,
        'password': password,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _isLoggedIn = true;
      _uid = doc.id;
      _userName = name;
      _userEmail = email;

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Signup Error: $e");
      return false;
    }
  }

  // ---------------- UPDATE PROFILE ----------------
  Future<bool> updateProfile({
    required String name,
    String? imagePath,
  }) async {
    if (_uid == null) return false;

    try {
      final data = {
        'name': name,
        if (imagePath != null) 'profileImage': imagePath,
      };

      await _firestore.collection('users').doc(_uid).update(data);

      _userName = name;
      _profileImagePath = imagePath;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Update Profile Error: $e");
      return false;
    }
  }

  // ---------------- RESET PASSWORD ----------------
  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      final q = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (q.docs.isEmpty) return false;

      await _firestore
          .collection('users')
          .doc(q.docs.first.id)
          .update({'password': newPassword});

      return true;
    } catch (e) {
      debugPrint("Reset Error: $e");
      return false;
    }
  }

  void logout() {
    _isLoggedIn = false;
    _uid = null;
    _userEmail = null;
    _userName = null;
    _profileImagePath = null;
    notifyListeners();
  }
}
