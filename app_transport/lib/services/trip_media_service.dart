import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class TripMediaService {
  TripMediaService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance {
    if (kIsWeb) {
      _storage.setMaxUploadRetryTime(const Duration(seconds: 12));
      _storage.setMaxOperationRetryTime(const Duration(seconds: 12));
      _storage.setMaxDownloadRetryTime(const Duration(seconds: 12));
    }
  }

  final FirebaseStorage _storage;

  UploadTask uploadCover({
    required String tripId,
    required XFile file,
    Uint8List? bytes,
  }) {
    final ref = _storage.ref('trips/$tripId/cover.jpg');
    if (kIsWeb) {
      final data = bytes;
      if (data == null || data.isEmpty) {
        throw StateError('Web cover upload requires non-empty bytes');
      }
      return ref.putData(
        data,
        SettableMetadata(contentType: _mimeFromName(file.name)),
      );
    }
    return ref.putFile(io.File(file.path));
  }

  UploadTask uploadGallery({
    required String tripId,
    required XFile file,
    Uint8List? bytes,
  }) {
    final imageId = const Uuid().v4();
    final ref = _storage.ref('trips/$tripId/gallery/$imageId.jpg');
    if (kIsWeb) {
      final data = bytes;
      if (data == null || data.isEmpty) {
        throw StateError('Web gallery upload requires non-empty bytes');
      }
      return ref.putData(
        data,
        SettableMetadata(contentType: _mimeFromName(file.name)),
      );
    }
    return ref.putFile(io.File(file.path));
  }

  Future<void> deleteByUrl(String url) async {
    if (url.isEmpty || url.startsWith('data:image')) return;
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {
      // Best-effort delete only.
    }
  }

  Future<String> processCoverImage(XFile file) async {
    final bytes = await file.readAsBytes();
    return bytesToBase64(bytes, fileName: file.name);
  }

  Future<String> processGalleryImage(XFile file) async {
    final bytes = await file.readAsBytes();
    return bytesToBase64(bytes, fileName: file.name);
  }

  Future<List<String>> processMultipleImages(List<XFile> files) async {
    final results = <String>[];
    for (final file in files) {
      try {
        final bytes = await file.readAsBytes();
        results.add(bytesToBase64(bytes, fileName: file.name));
      } catch (e) {
        debugPrint('[TripMediaService] Skipping image ${file.name}: $e');
      }
    }
    return results;
  }

  String bytesToBase64(Uint8List bytes, {String fileName = 'image.jpg'}) {
    if (bytes.isEmpty) {
      throw StateError('Cannot convert empty bytes to image data URL');
    }
    final mime = _mimeFromName(fileName);
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }

  String _mimeFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }
}
