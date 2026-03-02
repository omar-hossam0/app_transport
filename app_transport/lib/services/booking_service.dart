import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';

/// Manages trip bookings in Firebase Realtime Database.
/// Path: bookings/{uid}/{bookingId}
class BookingService extends ChangeNotifier {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _loadedUid;

  List<Booking> get bookings => List.unmodifiable(_bookings);
  bool get isLoading => _isLoading;

  // ── Load bookings for user ────────────────────────────────────────────────

  Future<void> loadBookings(String uid) async {
    if (_loadedUid == uid) return; // already loaded for this user
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

  // ── Save a new booking ────────────────────────────────────────────────────

  Future<void> saveBooking(String uid, Booking booking) async {
    await _db
        .ref('bookings/$uid/${booking.id}')
        .set(booking.toMap())
        .timeout(const Duration(seconds: 10));

    if (_loadedUid == uid) {
      _bookings.insert(0, booking);
      notifyListeners();
    }
  }

  // ── Update booking status ─────────────────────────────────────────────────

  Future<void> updateStatus(
    String uid,
    String bookingId,
    BookingStatus status,
  ) async {
    await _db
        .ref('bookings/$uid/$bookingId/status')
        .set(status.name)
        .timeout(const Duration(seconds: 10));

    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx != -1) {
      _bookings[idx].status = status;
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
    await _db
        .ref('bookings/$uid/$bookingId')
        .update({'userRating': rating, 'userReview': review})
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
    notifyListeners();
  }
}
