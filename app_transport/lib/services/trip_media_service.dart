import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class TripMediaService {
  TripMediaService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<UploadTask> uploadCover({
    required String tripId,
    required XFile file,
  }) async {
    final ref = _storage.ref('trips/$tripId/cover.jpg');
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      return ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    }
    return ref.putFile(File(file.path));
  }

  Future<UploadTask> uploadGallery({
    required String tripId,
    required XFile file,
  }) async {
    final imageId = const Uuid().v4();
    final ref = _storage.ref('trips/$tripId/gallery/$imageId.jpg');
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      return ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    }
    return ref.putFile(File(file.path));
  }

  Future<void> deleteByUrl(String url) async {
    if (url.isEmpty) return;
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {
      // Best-effort delete only.
    }
  }
}
