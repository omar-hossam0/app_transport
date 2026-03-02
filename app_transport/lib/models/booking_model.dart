import 'package:flutter/material.dart';

// ── Booking Status ─────────────────────────────────────────────────────────
enum BookingStatus { upcoming, completed, cancelled }

// ── Booking Model ──────────────────────────────────────────────────────────
class Booking {
  final String id;
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
  BookingStatus status;
  double userRating;
  String userReview;

  Booking({
    required this.id,
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
    this.status = BookingStatus.upcoming,
    this.userRating = 0,
    this.userReview = '',
  });

  double get totalPrice => pricePerPerson * travelers;
  String get totalPriceLabel => '\$${totalPrice.toInt()}';
  String get priceLabel => '\$${pricePerPerson.toInt()}';

  // ── Firebase serialisation ─────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
    'id': id,
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
    'accentColorValue': accentColor.value,
    'status': status.name,
    'userRating': userRating,
    'userReview': userReview,
  };

  factory Booking.fromMap(Map<String, dynamic> map) => Booking(
    id: map['id'] as String? ?? '',
    tripName: map['tripName'] as String? ?? '',
    tripImage: map['tripImage'] as String? ?? '',
    date: DateTime.fromMillisecondsSinceEpoch((map['dateEpoch'] as int?) ?? 0),
    time: map['time'] as String? ?? '10:00 AM',
    travelers: (map['travelers'] as int?) ?? 1,
    pricePerPerson: ((map['pricePerPerson'] ?? 0) as num).toDouble(),
    paymentMethod: map['paymentMethod'] as String? ?? '',
    pickupLocation: map['pickupLocation'] as String? ?? '',
    dropoffLocation: map['dropoffLocation'] as String? ?? '',
    routeLabel: map['routeLabel'] as String? ?? '',
    accentColor: Color((map['accentColorValue'] as int?) ?? 0xFF187BCD),
    status: BookingStatus.values.firstWhere(
      (s) => s.name == (map['status'] as String? ?? ''),
      orElse: () => BookingStatus.upcoming,
    ),
    userRating: ((map['userRating'] ?? 0) as num).toDouble(),
    userReview: map['userReview'] as String? ?? '',
  );
}
