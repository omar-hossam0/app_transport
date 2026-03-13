import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';

class FavoritesService extends ChangeNotifier {
  final _db = FirebaseDatabase.instance.ref();
  Set<String> _favorites = {};

  Set<String> get favorites => _favorites;

  bool isFavorite(String tripId) => _favorites.contains(tripId);

  /// Load all favorites for a user from Firebase
  Future<void> loadFavorites(String uid) async {
    try {
      final snapshot = await _db.child('favorites/$uid').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map?;
        _favorites = (data?.keys.cast<String>() ?? []).toSet();
      } else {
        _favorites.clear();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  /// Toggle favorite status for a trip
  Future<void> toggleFavorite(String uid, String tripId) async {
    try {
      if (_favorites.contains(tripId)) {
        // Remove from favorites
        await _db.child('favorites/$uid/$tripId').remove();
        _favorites.remove(tripId);
      } else {
        // Add to favorites
        await _db.child('favorites/$uid/$tripId').set({
          'tripId': tripId,
          'addedAt': DateTime.now().millisecondsSinceEpoch,
        });
        _favorites.add(tripId);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      rethrow;
    }
  }

  /// Clear all favorites (on logout)
  void clearFavorites() {
    _favorites.clear();
    notifyListeners();
  }
}
