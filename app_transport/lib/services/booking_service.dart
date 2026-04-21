import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';

/// Manages trip bookings in Firebase Realtime Database.
/// Path: bookings/{uid}/{bookingId}
class BookingService extends ChangeNotifier {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  List<Booking> _bookings = [];
  List<Booking> _allBookings = [];
  bool _isLoading = false;
  bool _isAllLoading = false;
  bool _mirrorPathAvailable = true;
  String? _loadedUid;
  bool _loadedAll = false;

  List<Booking> get bookings => List.unmodifiable(_bookings);
  List<Booking> get allBookings => List.unmodifiable(_allBookings);
  bool get isLoading => _isLoading;
  bool get isAllLoading => _isAllLoading;

  Booking _normalizedBooking(String uid, Booking booking) {
    final map = booking.toMap();
    final nowEpoch = DateTime.now().millisecondsSinceEpoch;
    map['userId'] = uid;

    final rawId = (map['id'] as String? ?? '').trim();
    if (rawId.isEmpty) {
      map['id'] = 'BK-$nowEpoch';
    }

    if (((map['createdAtEpoch'] ?? 0) as num).toInt() <= 0) {
      map['createdAtEpoch'] = nowEpoch;
    }

    map['updatedAtEpoch'] = nowEpoch;
    return Booking.fromMap(map);
  }

  List<Booking> _parseBookingsBucket(
    Map<String, dynamic> bucket, {
    required String uid,
    String fallbackUserName = '',
    String fallbackUserEmail = '',
  }) {
    final parsed = <Booking>[];
    for (final entry in bucket.entries) {
      final raw = entry.value;
      if (raw is! Map) continue;

      final map = Map<String, dynamic>.from(raw);
      final keyId = entry.key.trim();
      if ((map['id'] as String? ?? '').trim().isEmpty && keyId.isNotEmpty) {
        map['id'] = keyId;
      }
      if ((map['userId'] as String? ?? '').trim().isEmpty && uid.isNotEmpty) {
        map['userId'] = uid;
      }
      if ((map['userName'] as String? ?? '').trim().isEmpty &&
          fallbackUserName.isNotEmpty) {
        map['userName'] = fallbackUserName;
      }
      if ((map['userEmail'] as String? ?? '').trim().isEmpty &&
          fallbackUserEmail.isNotEmpty) {
        map['userEmail'] = fallbackUserEmail;
      }

      parsed.add(Booking.fromMap(map));
    }
    return parsed;
  }

  Future<List<Booking>> _loadAllBookingsFromUserBuckets() async {
    final usersSnap = await _db
        .ref('users')
        .get()
        .timeout(const Duration(seconds: 10));
    if (!usersSnap.exists || usersSnap.value == null) return const [];

    final usersData = Map<String, dynamic>.from(usersSnap.value as Map);
    final collected = <Booking>[];

    for (final entry in usersData.entries) {
      final uid = entry.key.trim();
      if (uid.isEmpty) continue;

      String fallbackName = '';
      String fallbackEmail = '';
      final rawUser = entry.value;
      if (rawUser is Map) {
        final userMap = Map<String, dynamic>.from(rawUser);
        fallbackName = (userMap['name'] as String? ?? '').trim();
        fallbackEmail = (userMap['email'] as String? ?? '').trim();
      }

      try {
        final bucketSnap = await _db
            .ref('bookings/$uid')
            .get()
            .timeout(const Duration(seconds: 10));
        if (!bucketSnap.exists || bucketSnap.value == null) continue;

        final bucket = Map<String, dynamic>.from(bucketSnap.value as Map);
        collected.addAll(
          _parseBookingsBucket(
            bucket,
            uid: uid,
            fallbackUserName: fallbackName,
            fallbackUserEmail: fallbackEmail,
          ),
        );
      } catch (e) {
        debugPrint('[BookingService] Skipped user bucket $uid: $e');
      }
    }

    collected.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return collected;
  }

  void _mirrorSet(String allKey, Map<String, dynamic> payload) {
    if (!_mirrorPathAvailable) return;

    unawaited(
      _db
          .ref('bookings_all/$allKey')
          .set(payload)
          .timeout(const Duration(seconds: 10))
          .catchError((e) {
            _mirrorPathAvailable = false;
            debugPrint('[BookingService] Mirror write skipped: $e');
          }),
    );
  }

  void _mirrorUpdate(String allKey, Map<String, dynamic> patch, String tag) {
    if (!_mirrorPathAvailable) return;

    unawaited(
      _db
          .ref('bookings_all/$allKey')
          .update(patch)
          .timeout(const Duration(seconds: 10))
          .catchError((e) {
            _mirrorPathAvailable = false;
            debugPrint('[BookingService] Mirror $tag skipped: $e');
          }),
    );
  }

  // ── Load bookings for user ────────────────────────────────────────────────

  Future<void> loadBookings(String uid, {bool force = false}) async {
    if (!force && _loadedUid == uid) return; // already loaded for this user
    _loadedUid = uid;
    _isLoading = true;
    notifyListeners();

    try {
      final snap = await _db
          .ref('bookings/$uid')
          .get()
          .timeout(const Duration(seconds: 10));

      if (snap.exists && snap.value != null) {
        final data = Map<String, dynamic>.from(snap.value as Map);
        _bookings =
            _parseBookingsBucket(data, uid: uid)
              ..sort((a, b) => b.date.compareTo(a.date));
      } else {
        _bookings = [];
      }
    } catch (e) {
      debugPrint('[BookingService] Load error: $e');
      _bookings = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Load all bookings for admin ──────────────────────────────────────

  Future<void> loadAllBookings() async {
    if (_loadedAll) return;
    _isAllLoading = true;
    notifyListeners();

    try {
      List<Booking> loaded = const [];

      try {
        final snap = await _db
            .ref('bookings_all')
            .get()
            .timeout(const Duration(seconds: 10));
        if (snap.exists && snap.value != null) {
          final data = Map<String, dynamic>.from(snap.value as Map);
          final parsed = <Booking>[];
          for (final entry in data.entries) {
            final raw = entry.value;
            if (raw is! Map) continue;
            final map = Map<String, dynamic>.from(raw);

            final allKey = entry.key;
            final separator = allKey.indexOf('_');
            final fallbackUid =
                separator > 0 ? allKey.substring(0, separator).trim() : '';
            if ((map['userId'] as String? ?? '').trim().isEmpty &&
                fallbackUid.isNotEmpty) {
              map['userId'] = fallbackUid;
            }

            parsed.add(Booking.fromMap(map));
          }
          parsed.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          loaded = parsed;
        }
      } catch (e) {
        _mirrorPathAvailable = false;
        debugPrint('[BookingService] bookings_all unavailable, fallback: $e');
      }

      if (loaded.isEmpty) {
        loaded = await _loadAllBookingsFromUserBuckets();
      }

      _allBookings = loaded;

      _loadedAll = true;
    } catch (e) {
      debugPrint('[BookingService] Load all error: $e');
      _allBookings = [];
    }

    _isAllLoading = false;
    notifyListeners();
  }

  // ── Save a new booking ────────────────────────────────────────────────────

  Future<void> saveBooking(String uid, Booking booking) async {
    final normalized = _normalizedBooking(uid, booking);
    final allKey = '${uid}_${normalized.id}';

    await _db
        .ref('bookings/$uid/${normalized.id}')
        .set(normalized.toMap())
        .timeout(const Duration(seconds: 10));

    _mirrorSet(allKey, normalized.toMap());

    if (_loadedUid == uid) {
      _bookings.removeWhere((b) => b.id == normalized.id);
      _bookings.insert(0, normalized);
    }

    if (_loadedAll) {
      _allBookings.removeWhere(
        (b) => b.id == normalized.id && b.userId == uid,
      );
      _allBookings.insert(0, normalized);
      _allBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    notifyListeners();
  }

  // ── Update booking status ─────────────────────────────────────────────────

  Future<void> updateStatus(
    String uid,
    String bookingId,
    BookingStatus status,
  ) async {
    if (uid.trim().isEmpty || bookingId.trim().isEmpty) {
      throw ArgumentError('uid and bookingId are required');
    }

    final nowEpoch = DateTime.now().millisecondsSinceEpoch;
    await _db
        .ref('bookings/$uid/$bookingId')
        .update({'status': status.name, 'updatedAtEpoch': nowEpoch})
        .timeout(const Duration(seconds: 10));

    final allKey = '${uid}_$bookingId';
    _mirrorUpdate(
      allKey,
      {'status': status.name, 'updatedAtEpoch': nowEpoch},
      'status update',
    );

    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    var changed = false;
    if (idx != -1) {
      _bookings[idx].status = status;
      changed = true;
    }

    final allIdx = _allBookings.indexWhere(
      (b) => b.id == bookingId && (b.userId == uid || b.userId.isEmpty),
    );
    if (allIdx != -1) {
      _allBookings[allIdx].status = status;
      changed = true;
    }

    if (changed) {
      notifyListeners();
    }
  }

  // ── Submit rating & review ────────────────────────────────────────────────

  Future<void> submitRating(
    String uid,
    String bookingId,
    double rating,
    String review,
  ) async {
    if (uid.trim().isEmpty || bookingId.trim().isEmpty) {
      throw ArgumentError('uid and bookingId are required');
    }

    final nowEpoch = DateTime.now().millisecondsSinceEpoch;
    await _db
        .ref('bookings/$uid/$bookingId')
        .update({
          'userRating': rating,
          'userReview': review,
          'updatedAtEpoch': nowEpoch,
        })
        .timeout(const Duration(seconds: 10));

    final allKey = '${uid}_$bookingId';
    _mirrorUpdate(
      allKey,
      {
        'userRating': rating,
        'userReview': review,
        'updatedAtEpoch': nowEpoch,
      },
      'rating update',
    );

    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    var changed = false;
    if (idx != -1) {
      _bookings[idx].userRating = rating;
      _bookings[idx].userReview = review;
      changed = true;
    }

    final allIdx = _allBookings.indexWhere(
      (b) => b.id == bookingId && (b.userId == uid || b.userId.isEmpty),
    );
    if (allIdx != -1) {
      _allBookings[allIdx].userRating = rating;
      _allBookings[allIdx].userReview = review;
      changed = true;
    }

    if (changed) {
      notifyListeners();
    }
  }

  // ── Clear on sign-out ─────────────────────────────────────────────────────

  void clearBookings() {
    _bookings = [];
    _loadedUid = null;
    _allBookings = [];
    _loadedAll = false;
    notifyListeners();
  }
}
