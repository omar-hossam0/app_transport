import 'package:flutter/material.dart';

// ── Booking Status ─────────────────────────────────────────────────────────
enum BookingStatus { pending, accepted, rejected, completed, cancelled }

// ── Booking Model ──────────────────────────────────────────────────────────
class Booking {
  final String id;
  final String tripId;
  final String tripType;
  final String tripName;
  final String tripImage;
  final DateTime date;
  final String time;
  int travelers;
  final double pricePerPerson;
  final String paymentMethod;
  final String pickupLocation;
  final String dropoffLocation;
  final String routeLabel;
  final Color accentColor;
  final String userId;
  final String userEmail;
  final String userName;
  final DateTime createdAt;
  final DateTime updatedAt;
  BookingStatus status;
  double userRating;
  String userReview;

  Booking({
    required this.id,
    this.tripId = '',
    this.tripType = '',
    required this.tripName,
    required this.tripImage,
    required this.date,
    required this.time,
    required this.travelers,
    required this.pricePerPerson,
    required this.paymentMethod,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.routeLabel,
    required this.accentColor,
    this.userId = '',
    this.userEmail = '',
    this.userName = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.status = BookingStatus.pending,
    this.userRating = 0,
    this.userReview = '',
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  double get totalPrice => pricePerPerson * travelers;
  String get totalPriceLabel => '\$${totalPrice.toInt()}';
  String get priceLabel => '\$${pricePerPerson.toInt()}';

  // ── Firebase serialisation ─────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
    'id': id,
    'tripId': tripId,
    'tripType': tripType,
    'tripName': tripName,
    'tripImage': tripImage,
    'dateEpoch': date.millisecondsSinceEpoch,
    'time': time,
    'travelers': travelers,
    'pricePerPerson': pricePerPerson,
    'paymentMethod': paymentMethod,
    'pickupLocation': pickupLocation,
    'dropoffLocation': dropoffLocation,
    'routeLabel': routeLabel,
    'accentColorValue': accentColor.toARGB32(),
    'userId': userId,
    'userEmail': userEmail,
    'userName': userName,
    'createdAtEpoch': createdAt.millisecondsSinceEpoch,
    'updatedAtEpoch': updatedAt.millisecondsSinceEpoch,
    'status': status.name,
    'userRating': userRating,
    'userReview': userReview,
  };

  factory Booking.fromMap(Map<String, dynamic> map) {
    final statusRaw = (map['status'] as String? ?? '').trim();
    final normalized = statusRaw == 'upcoming' ? 'pending' : statusRaw;

    return Booking(
      id: map['id'] as String? ?? '',
      tripId: map['tripId'] as String? ?? '',
      tripType: map['tripType'] as String? ?? '',
      tripName: map['tripName'] as String? ?? '',
      tripImage: map['tripImage'] as String? ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(
        (map['dateEpoch'] as int?) ?? 0,
      ),
      time: map['time'] as String? ?? '10:00 AM',
      travelers: (map['travelers'] as int?) ?? 1,
      pricePerPerson: ((map['pricePerPerson'] ?? 0) as num).toDouble(),
      paymentMethod: map['paymentMethod'] as String? ?? '',
      pickupLocation: map['pickupLocation'] as String? ?? '',
      dropoffLocation: map['dropoffLocation'] as String? ?? '',
      routeLabel: map['routeLabel'] as String? ?? '',
      accentColor: Color(
        ((map['accentColorValue'] ?? 0xFF187BCD) as num).toInt(),
      ),
      userId: map['userId'] as String? ?? '',
      userEmail: map['userEmail'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAtEpoch'] as int?) ?? 0,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['updatedAtEpoch'] as int?) ?? 0,
      ),
      status: BookingStatus.values.firstWhere(
        (s) => s.name == normalized,
        orElse: () => BookingStatus.pending,
      ),
      userRating: ((map['userRating'] ?? 0) as num).toDouble(),
      userReview: map['userReview'] as String? ?? '',
    );
  }
}
