import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AdminService extends ChangeNotifier {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  List<UserModel> _users = [];
  bool _isLoading = false;

  List<UserModel> get users => List.unmodifiable(_users);
  bool get isLoading => _isLoading;

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snap = await _db
          .ref('users')
          .get()
          .timeout(const Duration(seconds: 10));

      if (snap.exists && snap.value != null) {
        final data = Map<String, dynamic>.from(snap.value as Map);
        _users = data.values
            .map((v) => UserModel.fromMap(Map<String, dynamic>.from(v as Map)))
            .toList()
          ..sort((a, b) => a.email.compareTo(b.email));
      } else {
        _users = [];
      }
    } catch (e) {
      debugPrint('[AdminService] Load users error: $e');
      _users = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setAdminRole({required String uid, required bool isAdmin}) async {
    await _db
        .ref('users/$uid/isAdmin')
        .set(isAdmin)
        .timeout(const Duration(seconds: 8));

    final idx = _users.indexWhere((u) => u.uid == uid);
    if (idx != -1) {
      _users[idx] = _users[idx].copyWith(isAdmin: isAdmin);
      notifyListeners();
    }
  }
}
