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
  String? _loadedUid;
  bool _loadedAll = false;

  List<Booking> get bookings => List.unmodifiable(_bookings);
  List<Booking> get allBookings => List.unmodifiable(_allBookings);
  bool get isLoading => _isLoading;
  bool get isAllLoading => _isAllLoading;

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
            data.values
                .map(
                  (v) => Booking.fromMap(Map<String, dynamic>.from(v as Map)),
                )
                .toList()
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
      final snap = await _db
          .ref('bookings_all')
          .get()
          .timeout(const Duration(seconds: 10));

      if (snap.exists && snap.value != null) {
        final data = Map<String, dynamic>.from(snap.value as Map);
        _allBookings =
            data.values
                .map(
                  (v) => Booking.fromMap(Map<String, dynamic>.from(v as Map)),
                )
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        _allBookings = [];
      }

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
    final allKey = '${uid}_${booking.id}';
    await _db
        .ref('bookings/$uid/${booking.id}')
        .set(booking.toMap())
        .timeout(const Duration(seconds: 10));

    await _db
        .ref('bookings_all/$allKey')
        .set(booking.toMap())
        .timeout(const Duration(seconds: 10));

    if (_loadedUid == uid) {
      _bookings.insert(0, booking);
      notifyListeners();
    }

    if (_loadedAll) {
      _allBookings.insert(0, booking);
      notifyListeners();
    }
  }

  // ── Update booking status ─────────────────────────────────────────────────

  Future<void> updateStatus(
    String uid,
    String bookingId,
    BookingStatus status,
  ) async {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch;
    await _db
        .ref('bookings/$uid/$bookingId')
        .update({'status': status.name, 'updatedAtEpoch': nowEpoch})
        .timeout(const Duration(seconds: 10));

    final allKey = '${uid}_$bookingId';
    await _db
        .ref('bookings_all/$allKey')
        .update({'status': status.name, 'updatedAtEpoch': nowEpoch})
        .timeout(const Duration(seconds: 10));

    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      _bookings[idx].status = status;
      notifyListeners();
    }

    final allIdx = _allBookings.indexWhere(
      (b) => b.id == bookingId && b.userId == uid,
    );
    if (allIdx != -1) {
      _allBookings[allIdx].status = status;
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
    await _db
        .ref('bookings_all/$allKey')
        .update({
          'userRating': rating,
          'userReview': review,
          'updatedAtEpoch': nowEpoch,
        })
        .timeout(const Duration(seconds: 10));

    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      _bookings[idx].userRating = rating;
      _bookings[idx].userReview = review;
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
