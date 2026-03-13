import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/booking_model.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../services/favorites_service.dart';
import 'auth_widgets.dart';
import '../models/trip_model.dart';

// ── Brand colours ────────────────────────────────────────────────────────────
const _kDarkBlue = Color(0xFF4A44AA);
const _kRed = Color(0xFFE02850);

// ─────────────────────────────────────────────────────────────────────────────
class TripDetailPage extends StatefulWidget {
  final TripModel trip;
  const TripDetailPage({super.key, required this.trip});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Animation<double> _fade(double start, double end) =>
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );

  Animation<Offset> _slide(double start, double end) =>
      Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final t = widget.trip;
    final screenH = MediaQuery.of(context).size.height;
    final topPad = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          color: const Color(0xFFE8F4F8),
          child: Stack(
            children: [
              // ── Main scrollable content ──────────────────────────────
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero image area ───────────────────────────────
                    SizedBox(
                      height: screenH * 0.42,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Real image from network
                          Image.network(
                            t.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                          t.accentColor,
                                          t.accentColor.withValues(alpha: 0.55),
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topRight,
                                  ),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                          t.accentColor,
                                          t.accentColor.withValues(alpha: 0.55),
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topRight,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                        Icons.flight_rounded,
                                    color: Colors.white.withValues(alpha: 0.20),
                                    size: 90,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Top gradient for status bar readability
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: topPad + 60,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.40),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Bottom curve overlay
                          Positioned(
                            bottom: -1,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Content area ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Explored badge
                          FadeTransition(
                            opacity: _fade(0.0, 0.3),
                            child: SlideTransition(
                              position: _slide(0.0, 0.3),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [kBlue, kLightBlue],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.flight_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    t.locationLabel,
                                    style: roboto(
                                      fontSize: 13,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Trip name
                          FadeTransition(
                            opacity: _fade(0.08, 0.38),
                            child: SlideTransition(
                              position: _slide(0.08, 0.38),
                                                          FadeTransition(
                                                            opacity: _fade(0.46, 0.76),
                                                            child: SlideTransition(
                                                              position: _slide(0.46, 0.76),
                                                              child: _buildReviewsSection(t),
                                                            ),
                                                          ),
                                                          const SizedBox(height: 30),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Departure info
                          FadeTransition(
                            opacity: _fade(0.12, 0.42),
                            child: SlideTransition(
                              position: _slide(0.12, 0.42),
                              child: Text(
                                t.locationLabel,
                                style: roboto(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              Widget _buildReviewsSection(TripModel t) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Reviews',
                                          style: roboto(fontSize: 18, fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '(0)',
                                          style: roboto(fontSize: 12, color: Colors.grey.shade500),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F7FA),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Text(
                                        'No reviews yet. Be the first to share your experience.',
                                        style: roboto(fontSize: 12, color: Colors.grey.shade600),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Center(
                                      child: TextButton.icon(
                                        onPressed: _showAddReviewDialog,
                                        icon: const Icon(Icons.rate_review_rounded, color: kBlue, size: 20),
                                        label: Text(
                                          'Write a Review',
                                          style: roboto(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: kBlue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                          // Description
                          FadeTransition(
                            opacity: _fade(0.28, 0.58),
                            child: SlideTransition(
                              position: _slide(0.28, 0.58),
                              child: Text(
                                t.description,
                                textDirection: TextDirection.rtl,
                                style: roboto(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  height: 1.7,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),

                          // Route card
                          FadeTransition(
                            opacity: _fade(0.34, 0.64),
                            child: SlideTransition(
                              position: _slide(0.34, 0.64),
                              child: _RouteCard(trip: t),
                            ),
                          ),
                          const SizedBox(height: 26),

                          // Highlights
                          FadeTransition(
                            opacity: _fade(0.40, 0.70),
                            child: SlideTransition(
                              position: _slide(0.40, 0.70),
                              child: _buildHighlights(t),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Reviews Section
                          FadeTransition(
                            opacity: _fade(0.46, 0.76),
                            child: SlideTransition(
                              position: _slide(0.46, 0.76),
                              child: _buildReviewsSection(t),
                            ),
                          ),

                          // Extra space for bottom bar
                          const SizedBox(height: 110),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Top nav buttons ──────────────────────────────────────
              Positioned(
                top: topPad + 10,
                left: 18,
                right: 18,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CircleBtn(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    Row(
                      children: [
                        Consumer2<AuthService, FavoritesService>(
                          builder: (context, auth, favorites, _) {
                            final uid = auth.currentUser?.uid ?? '';
                            final tripId = widget.trip.id;
                            final isFav =
                                uid.isNotEmpty && favorites.isFavorite(tripId);
                            return _CircleBtn(
                              icon: isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              onTap: uid.isEmpty
                                  ? null
                                  : () async {
                                      try {
                                        await favorites.toggleFavorite(
                                          uid,
                                          tripId,
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    },
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        _CircleBtn(icon: Icons.share_rounded, onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Bottom action bar ────────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fade(0.50, 0.85),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      22,
                      16,
                      22,
                      MediaQuery.of(context).padding.bottom + 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, -6),
                        ),
                      ],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Heart button
                        GestureDetector(
                          onTap: () => setState(() => _liked = !_liked),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: _liked
                                  ? _kRed.withValues(alpha: 0.10)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _liked
                                    ? _kRed.withValues(alpha: 0.30)
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Icon(
                              _liked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: _liked ? _kRed : Colors.grey.shade500,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Book button
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showBookingSheet(widget.trip),
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [kBlue, kLightBlue],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: kBlue.withValues(alpha: 0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Book This Flight',
                                  style: roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Booking sheet ──────────────────────────────────────────────────────────────────
  void _showBookingSheet(TripModel trip) {
    DateTime? selectedDate;
    int travelers = 1;
    int paymentIdx = 0;
    const methods = [
      'Visa •••• 4242',
      'Mastercard •••• 7890',
      'Cash on pickup',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
          final dateLabel = selectedDate == null
              ? 'Select a date'
              : '${selectedDate!.day} ${months[selectedDate!.month - 1]} ${selectedDate!.year}';

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Book Flight',
                    style: roboto(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    trip.name,
                    style: roboto(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 22),

                  // ── Date ──
                  Text(
                    'Flight Date',
                    style: roboto(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now().add(
                          const Duration(days: 1),
                        ),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setS(() => selectedDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 17,
                            color: kBlue,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            dateLabel,
                            style: roboto(
                              fontSize: 14,
                              color: selectedDate == null
                                  ? Colors.grey.shade400
                                  : const Color(0xFF1A1A2E),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Travelers ──
                  Text(
                    'Passengers',
                    style: roboto(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _CircleBtn(
                        icon: Icons.remove_rounded,
                        onTap: travelers > 1
                            ? () => setS(() => travelers--)
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '$travelers',
                          style: roboto(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _CircleBtn(
                        icon: Icons.add_rounded,
                        onTap: travelers < 10
                            ? () => setS(() => travelers++)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Total: \$${trip.priceUsd * travelers}',
                        style: roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Payment ──
                  Text(
                    'Payment',
                    style: roboto(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(methods.length, (i) {
                      final sel = paymentIdx == i;
                      return ChoiceChip(
                        label: Text(
                          methods[i],
                          style: roboto(
                            fontSize: 11,
                            color: sel ? kBlue : Colors.grey.shade700,
                          ),
                        ),
                        selected: sel,
                        onSelected: (_) => setS(() => paymentIdx = i),
                        selectedColor: kBlue.withValues(alpha: 0.12),
                        backgroundColor: const Color(0xFFF5F7FA),
                        side: BorderSide(
                          color: sel ? kBlue : Colors.transparent,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // ── Confirm ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: selectedDate == null
                          ? null
                          : () async {
                              Navigator.pop(ctx);
                              await _confirmBooking(
                                trip,
                                selectedDate!,
                                travelers,
                                methods[paymentIdx],
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBlue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        selectedDate == null
                            ? 'Select a date first'
                            : 'Confirm Booking  \$${trip.priceUsd * travelers}',
                        style: roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: selectedDate == null
                              ? Colors.grey.shade400
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmBooking(
    TripModel trip,
    DateTime date,
    int travelers,
    String paymentMethod,
  ) async {
    final auth = context.read<AuthService>();
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please sign in to book a flight.',
            style: roboto(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final user = auth.currentUser!;
    final uid = user.uid;
    final rand = math.Random();
    final bookingId = 'FLY-${rand.nextInt(90000) + 10000}';

    final booking = Booking(
      id: bookingId,
      tripId: trip.id,
      tripType: trip.type.name,
      tripName: trip.name,
      tripImage: trip.imageUrl,
      date: date,
      time: '10:00 AM',
      travelers: travelers,
      pricePerPerson: trip.priceUsd.toDouble(),
      paymentMethod: paymentMethod,
      pickupLocation: trip.locationLabel,
      dropoffLocation: trip.locationLabel,
      routeLabel: trip.mapHint.isNotEmpty ? trip.mapHint : trip.routeLabel,
      accentColor: trip.accentColor,
      userId: uid,
      userEmail: user.email,
      userName: user.name,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await context.read<BookingService>().saveBooking(uid, booking);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Booking submitted! 🎉  Ref: $bookingId',
            style: roboto(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save booking. Check your connection.',
            style: roboto(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildHighlights(TripModel t) {
    final highlights = [
      ('Scenic Views', Icons.visibility_rounded, kBlue),
      ('AI Audio Guide', Icons.headset_mic_rounded, _kDarkBlue),
      ('Photo Spots', Icons.camera_alt_rounded, const Color(0xFFE02850)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip Highlights',
          style: roboto(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Row(
          children: highlights.map((h) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: h.$3.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: h.$3.withValues(alpha: 0.15)),
                ),
                child: Column(
                  children: [
                    Icon(h.$2, color: h.$3, size: 26),
                    const SizedBox(height: 8),
                    Text(
                      h.$1,
                      textAlign: TextAlign.center,
                      style: roboto(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: h.$3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Reviews Section ──────────────────────────────────────────────────────
  Widget _buildReviewsSection(TripModel t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Reviews',
              style: roboto(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 6),
            Text(
              '(0)',
              style: roboto(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'No reviews yet. Be the first to share your experience.',
            style: roboto(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton.icon(
            onPressed: _showAddReviewDialog,
            icon: const Icon(Icons.rate_review_rounded, color: kBlue, size: 20),
            label: Text(
              'Write a Review',
              style: roboto(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Show Add Review Dialog ──────────────────────────────────────────────
  void _showAddReviewDialog() {
    final reviewController = TextEditingController();
    int selectedRating = 5;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Write Your Review',
                style: roboto(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rating',
                    style: roboto(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedRating = index + 1;
                          });
                        },
                        child: Icon(
                          index < selectedRating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: const Color(0xFFFFC107),
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your Comment',
                    style: roboto(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reviewController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Share your experience...',
                      hintStyle: roboto(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: roboto(color: Colors.grey.shade600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Thank you for your review!',
                          style: roboto(color: Colors.white),
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: roboto(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Review Card Widget
// ═════════════════════════════════════════════════════════════════════════════
class _ReviewCard extends StatelessWidget {
  final String name;
  final int rating;
  final String date;
  final String comment;

  const _ReviewCard({
    required this.name,
    required this.rating,
    required this.date,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: kBlue.withValues(alpha: 0.15),
                child: Text(
                  name[0],
                  style: roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kBlue,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: roboto(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: const Color(0xFFFFC107),
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          date,
                          style: roboto(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment,
            style: roboto(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.grey.shade600),
          const SizedBox(width: 5),
          Text(
            label,
            style: roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Route map placeholder card
// ═════════════════════════════════════════════════════════════════════════════
class _RouteCard extends StatelessWidget {
  final TripModel trip;
  const _RouteCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Flight Route',
          style: roboto(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EFF6),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Stack(
            children: [
              // Map grid pattern
              CustomPaint(
                size: const Size(double.infinity, 160),
                painter: _MapGridPainter(),
              ),
              // Route line
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: CustomPaint(
                    size: const Size(double.infinity, 80),
                    painter: _RoutePainter(trip.accentColor),
                  ),
                ),
              ),
              // Start / End markers
              Positioned(
                left: 30,
                top: 45,
                child: _MapMarker(color: kBlue, label: 'CAI'),
              ),
              Positioned(
                right: 30,
                top: 55,
                child: _MapMarker(color: trip.accentColor, label: 'DST'),
              ),
              // Hint text
              Positioned(
                bottom: 10,
                left: 14,
                right: 14,
                child: Text(
                  trip.mapHint.isNotEmpty ? trip.mapHint : trip.routeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: roboto(fontSize: 10, color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapMarker extends StatelessWidget {
  final Color color;
  final String label;
  const _MapMarker({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.flight_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: roboto(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── Map grid painter ─────────────────────────────────────────────────────────
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD5DEED)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Route path painter ───────────────────────────────────────────────────────
class _RoutePainter extends CustomPainter {
  final Color color;
  _RoutePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..cubicTo(
        size.width * 0.3,
        0,
        size.width * 0.7,
        size.height,
        size.width,
        size.height * 0.4,
      );

    // dashed effect (solid for simplicity — looks great)
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);

    // Draw plane icon at mid-point
    final dotPaint = Paint()..color = color;
    final midX = size.width * 0.5;
    final midY = size.height * 0.38;
    canvas.drawCircle(Offset(midX, midY), 5, dotPaint);
    canvas.drawCircle(
      Offset(midX, midY),
      10,
      dotPaint..color = color.withValues(alpha: 0.20),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═════════════════════════════════════════════════════════════════════════════
//  Circle back/share button
// ═════════════════════════════════════════════════════════════════════════════
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF1A1A2E)),
      ),
    );
  }
}
