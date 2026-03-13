import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  StreamSubscription<String>? _tokenSub;

  Future<void> registerForUser(String uid) async {
    try {
      await _messaging.requestPermission();
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveToken(uid, token);
      }

      _tokenSub?.cancel();
      _tokenSub = _messaging.onTokenRefresh.listen((token) async {
        await _saveToken(uid, token);
      });
    } catch (e) {
      debugPrint('[NotificationService] Token registration failed: $e');
    }
  }

  Future<void> _saveToken(String uid, String token) async {
    await _db.ref('user_tokens/$uid/$token').set({
      'token': token,
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
      'updatedAtEpoch': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> disposeListener() async {
    await _tokenSub?.cancel();
    _tokenSub = null;
  }
}
