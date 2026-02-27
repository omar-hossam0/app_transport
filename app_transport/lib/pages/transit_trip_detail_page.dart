import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_widgets.dart';
import 'transit_trips_page.dart';

// ═════════════════════════════════════════════════════════════════════════════
//  TransitTripDetailPage
// ═════════════════════════════════════════════════════════════════════════════
class TransitTripDetailPage extends StatefulWidget {
  final TransitTrip trip;
  const TransitTripDetailPage({super.key, required this.trip});

  @override
  State<TransitTripDetailPage> createState() => _TransitTripDetailPageState();
}

class _TransitTripDetailPageState extends State<TransitTripDetailPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _favourited = false;

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
                          // Share button
                          Positioned(
                            top: mq.padding.top + 12,
                            right: 18,
                            child: Container(
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
                                    'Cairo International Airport',
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
                                        StatefulBuilder(
                                          builder: (ctx, setS) => GestureDetector(
                                            onTap: () => setState(
                                              () => _favourited = !_favourited,
                                            ),
                                            child: Container(
                                              width: 42,
                                              height: 42,
                                              decoration: BoxDecoration(
                                                color: _favourited
                                                    ? const Color(
                                                        0xFFE02850,
                                                      ).withValues(alpha: 0.12)
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
                                                _favourited
                                                    ? Icons.favorite_rounded
                                                    : Icons
                                                          .favorite_border_rounded,
                                                color: const Color(0xFFE02850),
                                                size: 20,
                                              ),
                                            ),
                                          ),
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
                                          '(${t.durationHours * 10 + 50} reviews)',
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
                                      '${t.durationHours} Hours',
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
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Booking confirmed! 🎉',
                                    style: roboto(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
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
  Widget _buildItinerary(TransitTrip t) {
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

  // ── Route Map ──────────────────────────────────────────────────────────────
  Widget _buildRouteMap(TransitTrip t) {
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
  Widget _buildIncluded(TransitTrip t) {
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
  Widget _buildReviews(TransitTrip t) {
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
              '(${t.reviews.length})',
              style: roboto(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Display reviews from trip data
        ...t.reviews.asMap().entries.map((e) {
          final review = e.value;
          final isFirst = e.key == 0;

          if (isFirst) {
            // Featured review
            return Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kBlue.withValues(alpha: 0.05), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBlue.withValues(alpha: 0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ...List.generate(
                        review.rating,
                        (i) => Icon(
                          Icons.star_rounded,
                          color: const Color(0xFFFFC107),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${review.rating}/5',
                        style: roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '"${review.comment}"',
                    style: roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A2E),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '— ${review.name}  •  ${review.date}',
                    style: roboto(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          } else {
            // Standard review
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ReviewTile(
                name: review.name,
                rating: review.rating,
                date: review.date,
                comment: review.comment,
              ),
            );
          }
        }),
        const SizedBox(height: 16),
        // Write review button
        GestureDetector(
          onTap: _showAddReviewDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: kBlue.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review_rounded, color: kBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Write a Review',
                  style: roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// Info tag chip
// ══════════════════════════════════════════════════════════
class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoTag(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
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

// ══════════════════════════════════════════════════════════
// Review Tile
// ══════════════════════════════════════════════════════════
class _ReviewTile extends StatelessWidget {
  final String name;
  final int rating;
  final String date;
  final String comment;
  const _ReviewTile({
    required this.name,
    required this.rating,
    required this.date,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
                backgroundColor: kBlue.withValues(alpha: 0.14),
                child: Text(
                  name[0],
                  style: roboto(
                    fontSize: 15,
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
                      style: roboto(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < rating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: const Color(0xFFFFC107),
                            size: 13,
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
