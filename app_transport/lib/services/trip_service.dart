import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../data/default_trips.dart';
import '../models/trip_model.dart';

class TripService extends ChangeNotifier {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final List<TripModel> _trips = [];
  bool _isLoading = false;
  StreamSubscription<DatabaseEvent>? _sub;

  List<TripModel> get trips => List.unmodifiable(_trips);
  List<TripModel> get activeTrips => _trips.where((t) => t.isActive).toList();
  bool get isLoading => _isLoading;

  Future<void> loadTrips() async {
    if (_sub != null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final keysToRemove = [
        'flying_2', 'flying_4', 'flying_5', 'flying_6',
        'transit_1', 'transit_2', 'transit_3', 'transit_4', 'transit_5', 'transit_6'
      ];
      for (var k in keysToRemove) {
        await _db.ref('trips/$k').remove();
      }
    } catch (_) {}

    await _ensureSeeded();

    try {
      final snap = await _db
          .ref('trips')
          .get()
          .timeout(const Duration(seconds: 10));
      _applySnapshot(snap);

      _sub = _db.ref('trips').onValue.listen((event) {
        _applySnapshot(event.snapshot);
      });
    } catch (e) {
      debugPrint('[TripService] Load error: $e');
      if (_trips.isEmpty) {
        _trips
          ..clear()
          ..addAll(defaultTrips)
          ..sort((a, b) => a.name.compareTo(b.name));
        debugPrint('[TripService] Using local default trips fallback.');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Force reload trips from Firebase (cancels existing subscription first).
  Future<void> reloadTrips() async {
    _sub?.cancel();
    _sub = null;
    await loadTrips();
  }


  Future<String> createTrip(TripModel trip) async {
    final now = DateTime.now();
    final key = trip.id.isNotEmpty ? trip.id : _db.ref('trips').push().key;
    if (key == null) throw Exception('Failed to generate trip id');

    final payload = trip
        .copyWith(id: key, createdAt: now, updatedAt: now)
        .toMap();

    try {
      debugPrint('[TripService] 📝 Creating trip: $key');
      await _db
          .ref('trips/$key')
          .set(payload)
          .timeout(const Duration(seconds: 10));
      debugPrint('[TripService] ✅ Trip created successfully!');
      return key;
    } catch (e) {
      debugPrint('[TripService] ❌ Create trip failed: $e');
      if (e.toString().contains('PERMISSION_DENIED')) {
        throw Exception(
          'PERMISSION_DENIED: Database rules blocking write.\n'
          'Fix: Update Firebase Realtime Database Rules',
        );
      }
      rethrow;
    }
  }

  Future<void> updateTrip(TripModel trip) async {
    final payload = trip.copyWith(updatedAt: DateTime.now()).toMap();
    await _db
        .ref('trips/${trip.id}')
        .update(payload)
        .timeout(const Duration(seconds: 10));
  }

  Future<void> deleteTrip(String tripId) async {
    await _db
        .ref('trips/$tripId')
        .remove()
        .timeout(const Duration(seconds: 10));
  }

  Future<void> setTripActive(String tripId, bool isActive) async {
    await _db
        .ref('trips/$tripId/isActive')
        .set(isActive)
        .timeout(const Duration(seconds: 10));
  }

  void disposeListener() {
    _sub?.cancel();
    _sub = null;
  }

  void _applySnapshot(DataSnapshot snap) {
    _trips.clear();
    if (snap.exists && snap.value != null) {
      final data = Map<String, dynamic>.from(snap.value as Map);
      for (final entry in data.entries) {
        final map = Map<String, dynamic>.from(entry.value as Map);
        final trip = TripModel.fromMap(map);
        if (trip.id.isNotEmpty) {
          _trips.add(trip);
        }
      }
      _trips.sort((a, b) => a.name.compareTo(b.name));
    }
    notifyListeners();
  }

  /// Resets the seed flag and re-seeds all default trips into Firebase.
  /// Use this from the Admin Dashboard when trips have been accidentally deleted.
  Future<void> reseedDefaultTrips() async {
    try {
      // Reset the seed flag so seeding runs again
      await _db
          .ref('system/trips_seeded')
          .set(false)
          .timeout(const Duration(seconds: 8));

      // Write all default trips
      for (final trip in defaultTrips) {
        final id = trip.id.isEmpty ? _db.ref('trips').push().key : trip.id;
        if (id == null) continue;
        await _db
            .ref('trips/$id')
            .set(trip.copyWith(id: id).toMap())
            .timeout(const Duration(seconds: 8));
        debugPrint('[TripService] ✅ Reseeded trip: $id');
      }

      // Mark as seeded again
      await _db
          .ref('system/trips_seeded')
          .set(true)
          .timeout(const Duration(seconds: 8));

      debugPrint('[TripService] 🌱 All default trips restored successfully!');
    } catch (e) {
      debugPrint('[TripService] ❌ Reseed failed: $e');
      rethrow;
    }
  }

  Future<void> _ensureSeeded() async {
    try {
      final seededSnap = await _db
          .ref('system/trips_seeded')
          .get()
          .timeout(const Duration(seconds: 8));

      if (seededSnap.exists && seededSnap.value == true) return;

      final tripsSnap = await _db
          .ref('trips')
          .get()
          .timeout(const Duration(seconds: 8));
      if (tripsSnap.exists && tripsSnap.value != null) {
        await _db
            .ref('system/trips_seeded')
            .set(true)
            .timeout(const Duration(seconds: 8));
        return;
      }

      for (final trip in defaultTrips) {
        final id = trip.id.isEmpty ? _db.ref('trips').push().key : trip.id;
        if (id == null) continue;
        await _db
            .ref('trips/$id')
            .set(trip.copyWith(id: id).toMap())
            .timeout(const Duration(seconds: 8));
      }

      await _db
          .ref('system/trips_seeded')
          .set(true)
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('[TripService] Seed skipped: $e');
    }
  }
}
