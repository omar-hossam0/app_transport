import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../data/default_trips.dart';
import '../models/trip_model.dart';
import 'trip_image_cache_manager.dart';

class TripService extends ChangeNotifier {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final List<TripModel> _trips = [];
  bool _isLoading = false;
  StreamSubscription<DatabaseEvent>? _sub;
  final Set<String> _warmedImageUrls = <String>{};
  Timer? _warmupDebounce;
  late final Map<String, String> _defaultCoverById = {
    for (final trip in defaultTrips)
      if (trip.id.trim().isNotEmpty && trip.imageUrl.trim().isNotEmpty)
        trip.id.trim(): trip.imageUrl.trim(),
  };
  late final Map<String, String> _defaultCoverByName = {
    for (final trip in defaultTrips)
      if (trip.name.trim().isNotEmpty && trip.imageUrl.trim().isNotEmpty)
        _normalizeName(trip.name): trip.imageUrl.trim(),
  };

  List<TripModel> get trips => List.unmodifiable(_trips);
  List<TripModel> get activeTrips =>
      _trips.where((t) => t.isActive && !_isBlockedTripName(t.name)).toList();
  bool get isLoading => _isLoading;

  String _normalizeName(String value) {
    final lower = value.toLowerCase();
    final cleaned = lower.replaceAll(RegExp(r'[^a-z0-9\s\u0600-\u06FF]'), ' ');
    return cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  bool _isBlockedTripName(String nameRaw) {
    final name = _normalizeName(nameRaw);

    final isSunsetDelta =
        name.contains('sunset') &&
        name.contains('nile') &&
        name.contains('delta');

    final isBaronPharaonic =
        (name.contains('baron') && name.contains('pharaonic')) ||
        (name.contains('قصر البارون') && name.contains('القرية الفرعونية'));

    final isOldCairoKhan =
        (name.contains('old cairo') && name.contains('khan el khalili')) ||
        (name.contains('القاهرة القديمة') && name.contains('خان الخليلي'));

    final isPyramidsMuseumExpress =
        (name.contains('pyramids') &&
            name.contains('egyptian museum') &&
            name.contains('express')) ||
        (name.contains('الاهرامات') &&
            name.contains('المتحف المصري') &&
            name.contains('express'));

    return isSunsetDelta ||
        isBaronPharaonic ||
        isOldCairoKhan ||
        isPyramidsMuseumExpress;
  }

  Future<void> loadTrips() async {
    if (_sub != null) return;
    _isLoading = true;
    notifyListeners();

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

  @override
  void dispose() {
    _warmupDebounce?.cancel();
    disposeListener();
    super.dispose();
  }

  void _applySnapshot(DataSnapshot snap) {
    _trips.clear();
    if (snap.exists && snap.value != null) {
      final data = Map<String, dynamic>.from(snap.value as Map);
      var missingRawCoverCount = 0;
      var fallbackAppliedCount = 0;
      for (final entry in data.entries) {
        final raw = entry.value;
        if (raw is! Map) {
          debugPrint(
            '[TripService] Skipping non-map trip payload at key: ${entry.key}',
          );
          continue;
        }
        final map = Map<String, dynamic>.from(raw);
        final rawCover = (map['imageUrl'] as String? ?? '').trim();
        map['id'] = (map['id'] as String?)?.trim().isNotEmpty == true
            ? map['id']
            : entry.key;
        var trip = TripModel.fromMap(map);
        if (rawCover.isEmpty) {
          missingRawCoverCount++;
        }

        if (trip.imageUrl.trim().isEmpty) {
          final fallback = _fallbackCoverUrl(trip);
          if (fallback.isNotEmpty) {
            trip = trip.copyWith(imageUrl: fallback);
            fallbackAppliedCount++;
          }
        }

        if (trip.id.isNotEmpty && !_isBlockedTripName(trip.name)) {
          _trips.add(trip);
        }
      }
      _trips.sort((a, b) => a.name.compareTo(b.name));
      debugPrint(
        '[TripService] Image audit: total=${_trips.length}, '
        'missingRawCover=$missingRawCoverCount, '
        'fallbackApplied=$fallbackAppliedCount',
      );
    }
    _scheduleImageWarmup();
    notifyListeners();
  }

  String _fallbackCoverUrl(TripModel trip) {
    final fromGallery = trip.galleryImageUrls
        .map((url) => url.trim())
        .firstWhere((url) => url.isNotEmpty, orElse: () => '');
    if (fromGallery.isNotEmpty) return fromGallery;

    final byId = _defaultCoverById[trip.id.trim()] ?? '';
    if (byId.isNotEmpty) return byId;

    return _defaultCoverByName[_normalizeName(trip.name)] ?? '';
  }

  void _scheduleImageWarmup() {
    _warmupDebounce?.cancel();
    _warmupDebounce = Timer(const Duration(milliseconds: 250), () {
      unawaited(_warmTripImageCache());
    });
  }

  Future<void> _warmTripImageCache() async {
    final urls = <String>{};

    for (final trip in _trips) {
      final cover = trip.imageUrl.trim();
      if (_isCacheableUrl(cover)) urls.add(cover);

      for (final url in trip.galleryImageUrls) {
        final normalized = url.trim();
        if (_isCacheableUrl(normalized)) urls.add(normalized);
      }

      for (final stop in trip.itinerary) {
        final stopUrl = stop.imageUrl.trim();
        if (_isCacheableUrl(stopUrl)) urls.add(stopUrl);
      }
    }

    final pending = urls
        .where((url) => !_warmedImageUrls.contains(url))
        .take(60)
        .toList();

    if (pending.isEmpty) return;

    final cache = TripImageCacheManager.instance;
    for (final url in pending) {
      try {
        await cache.downloadFile(url, key: url);
        _warmedImageUrls.add(url);
      } catch (e) {
        debugPrint('[TripService] Cache warmup skipped for $url: $e');
      }
    }
  }

  bool _isCacheableUrl(String value) {
    if (value.isEmpty || value.startsWith('data:image')) return false;
    return value.startsWith('http://') || value.startsWith('https://');
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
