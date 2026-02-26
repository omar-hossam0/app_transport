import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_widgets.dart';
import 'flying_taxi_page.dart';

// ── Brand colours ────────────────────────────────────────────────────────────
const _kDarkBlue = Color(0xFF4A44AA);
const _kRed = Color(0xFFE02850);

// ─────────────────────────────────────────────────────────────────────────────
class TripDetailPage extends StatefulWidget {
  final FlyingTaxiTrip trip;
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
        backgroundColor: Colors.white,
        body: Stack(
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
                                    t.cardColor,
                                    t.cardColor.withValues(alpha: 0.55),
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
                                    t.cardColor,
                                    t.cardColor.withValues(alpha: 0.55),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topRight,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  t.icon,
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
                                  'Cairo International Airport',
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
                            child: Text(
                              t.name,
                              style: roboto(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
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
                              'Cairo International Airport, Egypt',
                              style: roboto(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Rating row
                        FadeTransition(
                          opacity: _fade(0.16, 0.46),
                          child: SlideTransition(
                            position: _slide(0.16, 0.46),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFFC107),
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '4.${t.durationMins % 7 + 2}',
                                  style: roboto(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${(t.durationMins * 7 + 50)} reviews)',
                                  style: roboto(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Tags row
                        FadeTransition(
                          opacity: _fade(0.22, 0.52),
                          child: SlideTransition(
                            position: _slide(0.22, 0.52),
                            child: Row(
                              children: [
                                _InfoTag(
                                  icon: Icons.schedule_rounded,
                                  label: t.durationLabel,
                                ),
                                const SizedBox(width: 12),
                                _InfoTag(
                                  icon: Icons.attach_money_rounded,
                                  label: t.priceLabel,
                                ),
                                const SizedBox(width: 12),
                                const _InfoTag(
                                  icon: Icons.headset_mic_rounded,
                                  label: 'AI Guide',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),

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
                  _CircleBtn(icon: Icons.share_rounded, onTap: () {}),
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
                    color: Colors.white,
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
                          onTap: () {},
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
    );
  }

  Widget _buildHighlights(FlyingTaxiTrip t) {
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
}

// ═════════════════════════════════════════════════════════════════════════════
//  Info tag chip
// ═════════════════════════════════════════════════════════════════════════════
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
  final FlyingTaxiTrip trip;
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
                    painter: _RoutePainter(trip.cardColor),
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
                child: _MapMarker(color: trip.cardColor, label: 'DST'),
              ),
              // Hint text
              Positioned(
                bottom: 10,
                left: 14,
                right: 14,
                child: Text(
                  trip.mapHint,
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
  final VoidCallback onTap;
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
