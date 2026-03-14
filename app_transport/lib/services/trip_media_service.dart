import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class TripMediaService {
  TripMediaService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<UploadTask> uploadCover({required String tripId, required XFile file}) async {
    final ref = _storage.ref('trips/$tripId/cover.jpg');
    final bytes = await file.readAsBytes();
    return ref.putData(bytes);
  }

  Future<UploadTask> uploadGallery({required String tripId, required XFile file}) async {
    final imageId = const Uuid().v4();
    final ref = _storage.ref('trips/$tripId/gallery/$imageId.jpg');
    final bytes = await file.readAsBytes();
    return ref.putData(bytes);
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
