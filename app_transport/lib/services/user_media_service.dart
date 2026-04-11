import 'dart:io' as io;
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class UserMediaService {
  UserMediaService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance {
    if (kIsWeb) {
      _storage.setMaxUploadRetryTime(const Duration(seconds: 12));
      _storage.setMaxOperationRetryTime(const Duration(seconds: 12));
      _storage.setMaxDownloadRetryTime(const Duration(seconds: 12));
    }
  }

  final FirebaseStorage _storage;

  Future<String> uploadAvatar({
    required String uid,
    required XFile file,
    Uint8List? bytes,
  }) async {
    final ref = _storage.ref('users/$uid/avatar.jpg');
    final metadata = SettableMetadata(contentType: _mimeFromName(file.name));

    if (kIsWeb) {
      final data = bytes;
      if (data == null || data.isEmpty) {
        throw StateError('Web avatar upload requires non-empty bytes');
      }
      await ref.putData(data, metadata);
    } else {
      await ref.putFile(io.File(file.path), metadata);
    }

    return ref.getDownloadURL();
  }

  String _mimeFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}
