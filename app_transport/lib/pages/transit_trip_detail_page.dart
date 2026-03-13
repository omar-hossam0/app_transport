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

// ═════════════════════════════════════════════════════════════════════════════
//  TransitTripDetailPage
// ═════════════════════════════════════════════════════════════════════════════
class TransitTripDetailPage extends StatefulWidget {
  final TripModel trip;
  const TransitTripDetailPage({super.key, required this.trip});

  @override
  State<TransitTripDetailPage> createState() => _TransitTripDetailPageState();
}

class _TransitTripDetailPageState extends State<TransitTripDetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Booking sheet ─────────────────────────────────────────────────────────

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
                  // Handle bar
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
                    'Book Trip',
                    style: roboto(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    trip.name,
                    style: roboto(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 22),

                  // ── Date ──────────────────────────────────────────────
                  Text(
                    'Travel Date',
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

                  // ── Travelers ─────────────────────────────────────────
                  Text(
                    'Travelers',
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

                  // ── Payment ───────────────────────────────────────────
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

                  // ── Confirm ─────────────────────────────────────────
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
            'Please sign in to book a trip.',
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
    final bookingId = 'TRP-${rand.nextInt(90000) + 10000}';

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

  Animation<double> _fade(double start, double end) =>
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );

  Animation<Offset> _slide(double start, double end) =>
      Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );

  void _showAddReviewDialog() {
    final reviewCtrl = TextEditingController();
    int star = 5;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setS) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Write Your Review',
            style: roboto(fontWeight: FontWeight.w700),
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
                children: List.generate(
                  5,
                  (i) => GestureDetector(
                    onTap: () => setS(() => star = i + 1),
                    child: Icon(
                      i < star ? Icons.star_rounded : Icons.star_border_rounded,
                      color: const Color(0xFFFFC107),
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Comment',
                style: roboto(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reviewCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Share your experience…',
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
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: roboto(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
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
              child: Text('Submit', style: roboto(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trip;
    final mq = MediaQuery.of(context);
    final heroH = mq.size.height * 0.40;
    final bottomPad = mq.padding.bottom;

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
              // ── Main scrollable ──────────────────────────────────────
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero image ─────────────────────────────────────
                    SizedBox(
                      height: heroH,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            t.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (ctx, child, prog) {
                              if (prog == null) return child;
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      t.accentColor,
                                      t.accentColor.withValues(alpha: 0.5),
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (c, e, s) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    t.accentColor,
                                    t.accentColor.withValues(alpha: 0.6),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.directions_bus_rounded,
                                  color: Colors.white.withValues(alpha: 0.3),
                                  size: 64,
                                ),
                              ),
                            ),
                          ),
                          // Bottom gradient
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: heroH * 0.55,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Color(0xCC000000),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Back button
                          Positioned(
                            top: mq.padding.top + 12,
                            left: 18,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.40),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          // Heart + Share buttons
                          Positioned(
                            top: mq.padding.top + 12,
                            right: 18,
                            child: Row(
                              children: [
                                Consumer2<AuthService, FavoritesService>(
                                  builder: (context, auth, favorites, _) {
                                    final uid = auth.currentUser?.uid ?? '';
                                    final tripId = widget.trip.id;
                                    final isFav =
                                        uid.isNotEmpty &&
                                        favorites.isFavorite(tripId);
                                    return Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: uid.isEmpty
                                            ? null
                                            : () async {
                                                try {
                                                  await favorites
                                                      .toggleFavorite(
                                                        uid,
                                                        tripId,
                                                      );
                                                } catch (e) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Error: $e',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                        borderRadius: BorderRadius.circular(21),
                                        child: Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.40,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isFav
                                                ? Icons.favorite_rounded
                                                : Icons.favorite_border_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.40),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.share_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Airport badge
                          Positioned(
                            bottom: 16,
                            left: 18,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.30),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.flight_rounded,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    t.locationLabel,
                                    style: roboto(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── White card body ────────────────────────────────
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5F8FC),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(26),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Trip name + rating row
                            FadeTransition(
                              opacity: _fade(0.05, 0.35),
                              child: SlideTransition(
                                position: _slide(0.05, 0.35),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            t.name,
                                            style: roboto(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              height: 1.25,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Consumer2<
                                          AuthService,
                                          FavoritesService
                                        >(
                                          builder: (ctx, auth, favorites, _) {
                                            final uid =
                                                auth.currentUser?.uid ?? '';
                                            final tripId = t.id;
                                            final isFav =
                                                uid.isNotEmpty &&
                                                favorites.isFavorite(tripId);
                                            return Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: uid.isEmpty
                                                    ? null
                                                    : () async {
                                                        try {
                                                          await favorites
                                                              .toggleFavorite(
                                                                uid,
                                                                tripId,
                                                              );
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                'Error: $e',
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                borderRadius:
                                                    BorderRadius.circular(21),
                                                child: Container(
                                                  width: 42,
                                                  height: 42,
                                                  decoration: BoxDecoration(
                                                    color: isFav
                                                        ? const Color(
                                                            0xFFE02850,
                                                          ).withValues(
                                                            alpha: 0.12,
                                                          )
                                                        : Colors.white,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withValues(
                                                              alpha: 0.06,
                                                            ),
                                                        blurRadius: 8,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    isFav
                                                        ? Icons.favorite_rounded
                                                        : Icons
                                                              .favorite_border_rounded,
                                                    color: const Color(
                                                      0xFFE02850,
                                                    ),
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          color: Color(0xFFFFC107),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '4.8',
                                          style: roboto(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '/ 5',
                                          style: roboto(
                                            fontSize: 13,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '(${(t.durationMinutes ~/ 10) + 50} reviews)',
                                          style: roboto(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Info tags
                            FadeTransition(
                              opacity: _fade(0.10, 0.40),
                              child: SlideTransition(
                                position: _slide(0.10, 0.40),
                                child: Wrap(
                                  spacing: 10,
                                  runSpacing: 8,
                                  children: [
                                    _InfoTag(
                                      Icons.access_time_rounded,
                                      t.durationLabel,
                                      kBlue,
                                    ),
                                    _InfoTag(
                                      Icons.attach_money_rounded,
                                      '${t.priceLabel} USD',
                                      const Color(0xFF0D7377),
                                    ),
                                    _InfoTag(
                                      Icons.flight_land_rounded,
                                      'Cairo Airport',
                                      const Color(0xFFE87832),
                                    ),
                                    _InfoTag(
                                      Icons.group_rounded,
                                      'Private Tour',
                                      const Color(0xFF4A44AA),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── Itinerary ──────────────────────────────
                            FadeTransition(
                              opacity: _fade(0.15, 0.45),
                              child: SlideTransition(
                                position: _slide(0.15, 0.45),
                                child: _buildItinerary(t),
                              ),
                            ),
                            const SizedBox(height: 24),

                            if (t.galleryImageUrls.isNotEmpty) ...[
                              FadeTransition(
                                opacity: _fade(0.18, 0.48),
                                child: SlideTransition(
                                  position: _slide(0.18, 0.48),
                                  child: _buildTripGallery(t),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // ── Stop Image Carousel ─────────────────────
                            FadeTransition(
                              opacity: _fade(0.20, 0.50),
                              child: SlideTransition(
                                position: _slide(0.20, 0.50),
                                child: _buildStopImageCarousel(t),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── Route Map ──────────────────────────────
                            FadeTransition(
                              opacity: _fade(0.25, 0.55),
                              child: SlideTransition(
                                position: _slide(0.25, 0.55),
                                child: _buildRouteMap(t),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── Included Services ──────────────────────
                            FadeTransition(
                              opacity: _fade(0.32, 0.62),
                              child: SlideTransition(
                                position: _slide(0.32, 0.62),
                                child: _buildIncluded(t),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── Reviews ────────────────────────────────
                            FadeTransition(
                              opacity: _fade(0.40, 0.70),
                              child: SlideTransition(
                                position: _slide(0.40, 0.70),
                                child: _buildReviews(t),
                              ),
                            ),

                            SizedBox(height: bottomPad + 100),
                          ],
                        ),
                      ),
                    ), // closes Transform.translate
                  ],
                ),
              ),

              // ── Pinned bottom bar ────────────────────────────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPad + 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total Price',
                            style: roboto(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.trip.priceLabel,
                            style: roboto(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: kBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showBookingSheet(widget.trip),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF187BCD), Color(0xFF5BC0EB)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: kBlue.withValues(alpha: 0.38),
                                  blurRadius: 16,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Book This Trip',
                                style: roboto(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
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
            ],
          ),
        ),
      ),
    );
  }

  // ── Itinerary ─────────────────────────────────────────────────────────────
  Widget _buildItinerary(TripModel t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Itinerary',
          style: roboto(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...t.itinerary.asMap().entries.map((e) {
          final i = e.key;
          final stop = e.value;
          final isLast = i == t.itinerary.length - 1;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Timeline ────────────────────────────────────────
                SizedBox(
                  width: 44,
                  child: Column(
                    children: [
                      // Number badge
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: stop.color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: i == 0 || isLast
                              ? Icon(stop.icon, color: Colors.white, size: 18)
                              : Text(
                                  '$i',
                                  style: roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 3),
                            width: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  stop.color.withValues(alpha: 0.6),
                                  t.itinerary[i + 1].color.withValues(
                                    alpha: 0.6,
                                  ),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      if (isLast) const SizedBox(height: 16),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // ── Content card ─────────────────────────────────────
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(bottom: isLast ? 0 : 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stop.title,
                                style: roboto(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                stop.subtitle,
                                style: roboto(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: stop.color.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            stop.duration,
                            style: roboto(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: stop.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Stop Image Carousel (GPS-style navigation) ────────────────────────────
  Widget _buildStopImageCarousel(TripModel t) {
    // Filter stops that have images
    final stopsWithImages = t.itinerary
        .where((s) => s.imageUrl.isNotEmpty)
        .toList();
    if (stopsWithImages.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: kBlue.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.photo_library_rounded, size: 17, color: kBlue),
            ),
            const SizedBox(width: 10),
            Text(
              'Gallery',
              style: roboto(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${stopsWithImages.length} stops',
                style: roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 195,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: stopsWithImages.length,
            itemBuilder: (context, index) {
              final stop = stopsWithImages[index];
              final isFirst = index == 0;
              final isLast = index == stopsWithImages.length - 1;
              return Container(
                width: 260,
                margin: EdgeInsets.only(right: isLast ? 0 : 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image
                      Image.network(
                        stop.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, prog) {
                          if (prog == null) return child;
                          return Container(
                            color: stop.color.withValues(alpha: 0.15),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: stop.color,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (c, e, s) => Container(
                          color: stop.color.withValues(alpha: 0.15),
                          child: Center(
                            child: Icon(
                              stop.icon,
                              size: 42,
                              color: stop.color.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),
                      // Bottom gradient
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              stops: const [0.0, 0.55],
                              colors: [
                                Colors.black.withValues(alpha: 0.72),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Stop number badge
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: stop.color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: stop.color.withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: roboto(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Navigation arrows between stops
                      if (!isFirst)
                        Positioned(
                          top: 10,
                          left: 44,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chevron_left_rounded,
                                size: 16,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              Container(
                                width: 16,
                                height: 2,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ],
                          ),
                        ),
                      // Duration badge
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 11,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                stop.duration,
                                style: roboto(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Title + subtitle
                      Positioned(
                        bottom: 10,
                        left: 12,
                        right: 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(stop.icon, size: 14, color: Colors.white),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    stop.title,
                                    style: roboto(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              stop.subtitle,
                              style: roboto(
                                fontSize: 10.5,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Dot indicator
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(stopsWithImages.length, (i) {
              return Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == 0 ? kBlue : Colors.grey.shade300,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTripGallery(TripModel t) {
    final images = t.galleryImageUrls;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: kBlue.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.photo_library_rounded, size: 17, color: kBlue),
            ),
            const SizedBox(width: 10),
            Text(
              'Trip Gallery',
              style: roboto(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${images.length} photos',
                style: roboto(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final url = images[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: 240,
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, prog) {
                      if (prog == null) return child;
                      return Container(
                        color: kBlue.withValues(alpha: 0.12),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: kBlue,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (ctx, err, st) => Container(
                      color: kBlue.withValues(alpha: 0.12),
                      child: Center(
                        child: Icon(
                          Icons.photo_rounded,
                          color: kBlue.withValues(alpha: 0.4),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Route Map ──────────────────────────────────────────────────────────────
  Widget _buildRouteMap(TripModel t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Route Map',
          style: roboto(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Map background grid
                CustomPaint(
                  size: const Size(double.infinity, 160),
                  painter: _MapGridPainter(),
                ),
                // Route path
                CustomPaint(
                  size: const Size(double.infinity, 160),
                  painter: _RoutePathPainter(
                    stops: t.itinerary.length,
                    color: t.accentColor,
                  ),
                ),
                // Stop labels
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: t.itinerary.asMap().entries.map((e) {
                      final stop = e.value;
                      final isFirst = e.key == 0;
                      final isLast = e.key == t.itinerary.length - 1;
                      return Flexible(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: (isFirst || isLast)
                                    ? kBlue
                                    : t.accentColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stop.title.split(' ').first.replaceAll('–', ''),
                              style: roboto(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Included Services ──────────────────────────────────────────────────────
  Widget _buildIncluded(TripModel t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s Included',
          style: roboto(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: t.included.map((item) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D7377).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF0D7377),
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item,
                    style: roboto(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Reviews ────────────────────────────────────────────────────────────────
  Widget _buildReviews(TripModel t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Reviews',
              style: roboto(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Text(
              '(0)',
              style: roboto(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 14),
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
}

// ══════════════════════════════════════════════════════════
// Booking sheet helper
// ══════════════════════════════════════════════════════════
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CircleBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: onTap == null ? Colors.grey.shade100 : const Color(0xFFF0F6FC),
        shape: BoxShape.circle,
        border: Border.all(
          color: onTap == null ? Colors.grey.shade200 : kBlue,
          width: 1.5,
        ),
      ),
      child: Icon(
        icon,
        size: 18,
        color: onTap == null ? Colors.grey.shade400 : kBlue,
      ),
    ),
  );
}

// ══════════════════════════════════════════════════════════
// Map Painters
// ══════════════════════════════════════════════════════════
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8F0F8)
      ..strokeWidth = 1;

    // Background
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF0F6FF),
    );

    // Grid lines
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _RoutePathPainter extends CustomPainter {
  final int stops;
  final Color color;
  _RoutePathPainter({required this.stops, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final spacing = size.width / (stops + 1);
    final points = List.generate(stops, (i) {
      final x = spacing * (i + 1);
      // Wavy path
      final y =
          size.height * 0.42 +
          math.sin((i / (stops - 1)) * math.pi * 1.2) * (size.height * 0.16);
      return Offset(x, y);
    });

    if (points.length < 2) return;

    // Shadow line
    final shadowPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final mid = Offset(
        (points[i - 1].dx + points[i].dx) / 2,
        (points[i - 1].dy + points[i].dy) / 2,
      );
      path.quadraticBezierTo(
        points[i - 1].dx,
        points[i - 1].dy,
        mid.dx,
        mid.dy,
      );
    }
    path.lineTo(points.last.dx, points.last.dy);
    canvas.drawPath(path, shadowPaint);

    // Main line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);

    // Stop dots
    for (int i = 0; i < points.length; i++) {
      final isEndpoint = i == 0 || i == points.length - 1;
      canvas.drawCircle(
        points[i],
        isEndpoint ? 7 : 5,
        Paint()..color = isEndpoint ? kBlue : color,
      );
      canvas.drawCircle(
        points[i],
        isEndpoint ? 4 : 3,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoTag(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
