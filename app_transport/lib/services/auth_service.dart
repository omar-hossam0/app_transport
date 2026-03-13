import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

/// Authentication service using Firebase Realtime Database only (no Firebase Auth SDK)
class AuthService extends ChangeNotifier {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  AuthService() {
    _ensureAdminSeed();
    _loadSavedSession();
  }

  // ─────────────────────────────────────────────────
  // Session Persistence
  // ─────────────────────────────────────────────────

  Future<void> _loadSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUid = prefs.getString('logged_in_uid');
      if (savedUid != null && savedUid.isNotEmpty) {
        await _loadUserFromDatabase(savedUid);
      }
    } catch (e) {
      debugPrint('[Auth] Error loading saved session: $e');
    }
  }

  Future<void> _saveSession(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logged_in_uid', uid);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_uid');
  }

  // ─────────────────────────────────────────────────
  // Password Hashing (SHA-256)
  // ─────────────────────────────────────────────────

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // ─────────────────────────────────────────────────
  // Email Key Encoding (Firebase doesn't allow . @ in keys)
  // ─────────────────────────────────────────────────

  String _encodeEmail(String email) {
    return email.toLowerCase().replaceAll('.', ',').replaceAll('@', '_at_');
  }

  // ─────────────────────────────────────────────────
  // Admin Seed (one-time)
  // ─────────────────────────────────────────────────

  Future<void> _ensureAdminSeed() async {
    try {
      final seededSnap = await _database
          .ref('system/admin_seeded')
          .get()
          .timeout(const Duration(seconds: 8));

      if (seededSnap.exists && seededSnap.value == true) return;

      const adminEmail = 'admin@gmail.com';
      const adminPassword = '12345678';
      const adminName = 'Admin';

      final emailKey = _encodeEmail(adminEmail);
      final indexSnap = await _database
          .ref('email_index/$emailKey')
          .get()
          .timeout(const Duration(seconds: 8));

      if (indexSnap.exists && indexSnap.value is Map) {
        final uid = (indexSnap.value as Map)['uid'] as String?;
        if (uid != null && uid.isNotEmpty) {
          await _database
              .ref('users/$uid')
              .update({'isAdmin': true})
              .timeout(const Duration(seconds: 8));
          await _database
              .ref('system/admin_seeded')
              .set(true)
              .timeout(const Duration(seconds: 8));
          return;
        }
      }

      final uid = const Uuid().v4();
      final now = DateTime.now();
      final passwordHash = _hashPassword(adminPassword);

      final adminUser = UserModel(
        uid: uid,
        email: adminEmail,
        name: adminName,
        isAdmin: true,
        createdAt: now,
        lastLogin: now,
      );

      await _database
          .ref('users/$uid')
          .set({...adminUser.toMap(), 'passwordHash': passwordHash})
          .timeout(const Duration(seconds: 8));

      await _database
          .ref('email_index/$emailKey')
          .set({'uid': uid})
          .timeout(const Duration(seconds: 8));

      await _database
          .ref('system/admin_seeded')
          .set(true)
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('[Auth] Admin seed skipped: $e');
    }
  }

  // ─────────────────────────────────────────────────
  // Load User from Database
  // ─────────────────────────────────────────────────

  Future<void> _loadUserFromDatabase(String uid) async {
    try {
      final snapshot = await _database
          .ref('users/$uid')
          .get()
          .timeout(const Duration(seconds: 10));

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        _currentUser = UserModel.fromMap(data);
        notifyListeners();
        debugPrint('[Auth] ✅ Session restored for: ${_currentUser!.email}');
      }
    } catch (e) {
      debugPrint('[Auth] Error loading user: $e');
    }
  }

  // ─────────────────────────────────────────────────
  // Sign Up
  // ─────────────────────────────────────────────────

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String phoneNumber = '',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final trimmedEmail = email.trim().toLowerCase();

      if (trimmedEmail.isEmpty || password.isEmpty || name.isEmpty) {
        _setError('جميع الحقول مطلوبة (All fields are required)');
        return false;
      }
      if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
        _setError('البريد الإلكتروني غير صحيح (Invalid email)');
        return false;
      }
      if (password.length < 6) {
        _setError('كلمة المرور 6 أحرف على الأقل (Password min 6 chars)');
        return false;
      }

      // Check email not already registered
      final emailKey = _encodeEmail(trimmedEmail);
      final existsSnap = await _database
          .ref('email_index/$emailKey')
          .get()
          .timeout(const Duration(seconds: 10));

      if (existsSnap.exists) {
        _setError('البريد الإلكتروني مسجل مسبقاً (Email already in use)');
        return false;
      }

      // Create user
      final uid = const Uuid().v4();
      final now = DateTime.now();
      final passwordHash = _hashPassword(password);

      final newUser = UserModel(
        uid: uid,
        email: trimmedEmail,
        name: name.trim(),
        phoneNumber: phoneNumber.trim(),
        isAdmin: false,
        createdAt: now,
        lastLogin: now,
      );

      await _database
          .ref('users/$uid')
          .set({...newUser.toMap(), 'passwordHash': passwordHash})
          .timeout(const Duration(seconds: 10));

      await _database
          .ref('email_index/$emailKey')
          .set({'uid': uid})
          .timeout(const Duration(seconds: 10));

      await _saveSession(uid);
      _currentUser = newUser;
      _isLoading = false;
      notifyListeners();

      debugPrint('[Auth] ✅ Sign up successful: $trimmedEmail');
      return true;
    } catch (e) {
      _setError('حدث خطأ غير متوقع (Unexpected error): $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────
  // Sign In
  // ─────────────────────────────────────────────────

  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final trimmedEmail = email.trim().toLowerCase();

      if (trimmedEmail.isEmpty || password.isEmpty) {
        _setError('البريد وكلمة المرور مطلوبان (Email and password required)');
        return false;
      }

      // Look up UID by email
      final emailKey = _encodeEmail(trimmedEmail);
      final indexSnap = await _database
          .ref('email_index/$emailKey')
          .get()
          .timeout(const Duration(seconds: 10));

      if (!indexSnap.exists) {
        _setError('البريد الإلكتروني غير مسجل (Email not found)');
        return false;
      }

      final uid = (indexSnap.value as Map)['uid'] as String;

      // Load user data
      final userSnap = await _database
          .ref('users/$uid')
          .get()
          .timeout(const Duration(seconds: 10));

      if (!userSnap.exists) {
        _setError('حساب غير موجود (Account not found)');
        return false;
      }

      final userData = Map<String, dynamic>.from(userSnap.value as Map);
      final storedHash = userData['passwordHash'] as String? ?? '';
      final inputHash = _hashPassword(password);

      if (storedHash != inputHash) {
        _setError('كلمة المرور غير صحيحة (Wrong password)');
        return false;
      }

      // Update last login
      final now = DateTime.now();
      await _database.ref('users/$uid/lastLogin').set(now.toIso8601String());
      userData['lastLogin'] = now.toIso8601String();

      _currentUser = UserModel.fromMap(userData);
      await _saveSession(uid);
      _isLoading = false;
      notifyListeners();

      debugPrint('[Auth] ✅ Sign in successful: $trimmedEmail');
      return true;
    } catch (e) {
      _setError('حدث خطأ أثناء تسجيل الدخول (Sign in error): $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────
  // Sign Out
  // ─────────────────────────────────────────────────

  Future<bool> signOut() async {
    try {
      await _clearSession();
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
      debugPrint('[Auth] 👋 Signed out');
      return true;
    } catch (e) {
      debugPrint('[Auth] Error signing out: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────
  // Update Profile
  // ─────────────────────────────────────────────────

  Future<bool> updateUserProfile({
    required String name,
    String? phoneNumber,
  }) async {
    if (_currentUser == null) return false;

    try {
      final updates = <String, dynamic>{'name': name.trim()};
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber.trim();

      await _database
          .ref('users/${_currentUser!.uid}')
          .update(updates)
          .timeout(const Duration(seconds: 10));

      _currentUser = _currentUser!.copyWith(
        name: name,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
      );
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[Auth] Error updating profile: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
    debugPrint('[Auth] ❌ Error: $message');
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
