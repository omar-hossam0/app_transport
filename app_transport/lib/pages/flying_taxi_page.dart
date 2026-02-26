import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_widgets.dart';
import 'trip_detail_page.dart';

// ── Brand colours ────────────────────────────────────────────────────────────
const _kDarkBlue = Color(0xFF4A44AA);
const _kRed = Color(0xFFE02850);

// ── Trip model ───────────────────────────────────────────────────────────────
class FlyingTaxiTrip {
  final String name;
  final int durationMins;
  final int priceUsd;
  final String description;
  final String mapHint;
  final Color cardColor;
  final IconData icon;
  final String imageUrl;

  const FlyingTaxiTrip({
    required this.name,
    required this.durationMins,
    required this.priceUsd,
    required this.description,
    required this.mapHint,
    required this.cardColor,
    required this.icon,
    required this.imageUrl,
  });

  String get durationLabel => '$durationMins mins';
  String get priceLabel => '\$$priceUsd';
}

// ── 10 Cairo Flying-Taxi trips ───────────────────────────────────────────────
const _flyingTrips = <FlyingTaxiTrip>[
  FlyingTaxiTrip(
    name: 'Nile Aerial Tour',
    durationMins: 30,
    priceUsd: 220,
    description:
        'جولة جوية على نهر النيل ورؤية الجسور والمعالم العمرانية الرئيسية في القاهرة من الأعلى.',
    mapHint: 'Flight path along the Nile through central Cairo.',
    cardColor: Color(0xFF187BCD),
    icon: Icons.water_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1572252009286-268acec5ca0a?w=800&q=80',
  ),
  FlyingTaxiTrip(
    name: 'Giza Skyline Flight',
    durationMins: 35,
    priceUsd: 230,
    description:
        'مشاهدة أهرامات الجيزة وأبو الهول من الجو مع التقاط صور بانورامية.',
    mapHint: 'Route passes over the Pyramids area and surroundings.',
    cardColor: Color(0xFFD4A843),
    icon: Icons.landscape_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?w=800&q=80',
  ),
  FlyingTaxiTrip(
    name: 'Cairo Downtown Highlights',
    durationMins: 25,
    priceUsd: 200,
    description:
        'استكشاف قلب القاهرة، تشمل مناطق وسط المدينة والأحياء التاريخية من السماء.',
    mapHint: 'Path over Tahrir Square, the Nile and historic mosques.',
    cardColor: Color(0xFF4A44AA),
    icon: Icons.location_city_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1539768942893-daf53e448371?w=800&q=80',
  ),
  FlyingTaxiTrip(
    name: 'Evening Cairo Lights',
    durationMins: 30,
    priceUsd: 220,
    description: 'جولة مسائية لمشاهدة أضواء القاهرة والمعالم مضاءة من الجو.',
    mapHint: 'Route covers historic temples and the corniche.',
    cardColor: Color(0xFF1A1A40),
    icon: Icons.nights_stay_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1553913861-c0fddf2619ee?w=800&q=80',
  ),
  FlyingTaxiTrip(
    name: 'Pyramids & Museum Loop',
    durationMins: 40,
    priceUsd: 250,
    description:
        'رحلة طويلة تشمل الأهرامات والمتحف المصري الكبير من الجو، مع تعليق صوتي عن المعالم.',
    mapHint: 'Circular: Airport → Pyramids → Grand Museum → Return.',
    cardColor: Color(0xFFE02850),
    icon: Icons.museum_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1503177119275-0aa32b3a9368?w=800&q=80',
  ),
  FlyingTaxiTrip(
    name: 'River Nile Sunset',
    durationMins: 30,
    priceUsd: 220,
    description:
        'مشاهدة غروب الشمس على نهر النيل من الأعلى مع إطلالة على الجسور والفلل.',
    mapHint: 'Along the Nile from Cairo to Fustat.',
    cardColor: Color(0xFFE87832),
    icon: Icons.wb_twilight_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1548919973-5cef591cdbc9?w=800&q=80',
  ),
  FlyingTaxiTrip(
    name: 'Ancient Landmarks Tour',
    durationMins: 35,
    priceUsd: 230,
    description:
        'استكشاف المعالم القديمة في القاهرة، بما في ذلك المساجد والمقابر القديمة.',
    mapHint: 'Covers Pyramids area and ancient archaeological sites.',
    cardColor: Color(0xFF8B6F47),
    icon: Icons.account_balance_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1555993539-1732f7b1446e?w=800&q=80',
  ),
  FlyingTaxiTrip(
    name: 'Cairo Panorama Quick Flight',
    durationMins: 20,
    priceUsd: 180,
    description:
        'جولة سريعة للمبتدئين أو المسافرين ذوي الوقت القصير، رؤية بانورامية عامة للقاهرة.',
    mapHint: 'Short route covering main landmarks only.',
    cardColor: Color(0xFF5BC0EB),
    icon: Icons.panorama_photosphere_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1591604129853-b71f29e3b39e?w=800&q=80',
  ),
  FlyingTaxiTrip(
    name: 'Historic Cairo Skyline',
    durationMins: 30,
    priceUsd: 220,
    description:
        'التعرف على القاهرة القديمة والمعالم التاريخية من الجو، مع صوت AI يشرح المعالم.',
    mapHint: 'Path over old quarters and heritage districts.',
    cardColor: Color(0xFF0D7377),
    icon: Icons.mosque_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1572252009286-268acec5ca0a?w=800&q=80',
  ),
  FlyingTaxiTrip(
    name: 'Night Sky Flight',
    durationMins: 30,
    priceUsd: 220,
    description:
        'جولة ليلية لمشاهدة النجوم وأضواء المدينة من الطائرة، تجربة فريدة وهادئة.',
    mapHint: 'Route over well-lit areas from above.',
    cardColor: Color(0xFF1C1C3B),
    icon: Icons.dark_mode_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=800&q=80',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
class FlyingTaxiPage extends StatefulWidget {
  const FlyingTaxiPage({super.key});

  @override
  State<FlyingTaxiPage> createState() => _FlyingTaxiPageState();
}

class _FlyingTaxiPageState extends State<FlyingTaxiPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Animation<double> _fade(int i) {
    final start = (i * 0.06).clamp(0.0, 0.7);
    final end = (start + 0.4).clamp(0.0, 1.0);
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _slide(int i) {
    final start = (i * 0.06).clamp(0.0, 0.7);
    final end = (start + 0.4).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  void _openDetail(FlyingTaxiTrip trip) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 550),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, anim, secAnim) => TripDetailPage(trip: trip),
        transitionsBuilder: (context, anim, secAnim, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF0F6FC), // Light blue tint
                Color(0xFFFFFDF7), // Cream white
                Color(0xFFFFFFFF), // Pure white
                Color(0xFFF8FBFF), // Very light blue
              ],
              stops: [0.0, 0.35, 0.65, 1.0],
            ),
          ),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── App bar ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(22, topPad + 14, 22, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Flying Taxi',
                          style: roboto(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.flight_rounded,
                        color: _kDarkBlue,
                        size: 26,
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // ── Subtitle ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Text(
                    'Departing & returning to Cairo International Airport',
                    style: roboto(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── Grid ─────────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final trip = _flyingTrips[i];
                    return FadeTransition(
                      opacity: _fade(i),
                      child: SlideTransition(
                        position: _slide(i),
                        child: _FlyingTripCard(
                          trip: trip,
                          onTap: () => _openDetail(trip),
                        ),
                      ),
                    );
                  }, childCount: _flyingTrips.length),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Individual trip card (matches reference image style)
// ═════════════════════════════════════════════════════════════════════════════
class _FlyingTripCard extends StatelessWidget {
  final FlyingTaxiTrip trip;
  final VoidCallback onTap;
  const _FlyingTripCard({required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image area ───────────────────────────────────────────
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Real image from network
                  Image.network(
                    trip.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              trip.cardColor,
                              trip.cardColor.withValues(alpha: 0.6),
                            ],
                            begin: Alignment.bottomLeft,
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
                              trip.cardColor,
                              trip.cardColor.withValues(alpha: 0.6),
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            trip.icon,
                            color: Colors.white.withValues(alpha: 0.30),
                            size: 52,
                          ),
                        ),
                      );
                    },
                  ),
                  // bottom gradient
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.50),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // heart icon
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        color: _kRed,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Info area ────────────────────────────────────────────
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      trip.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: roboto(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.flight_takeoff_rounded,
                          size: 12,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            'Cairo International Airport',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: roboto(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Bottom row: price + duration + rating
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money_rounded,
                          size: 14,
                          color: kBlue,
                        ),
                        Text(
                          trip.priceLabel,
                          style: roboto(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: kBlue,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFFFC107),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '4.${trip.durationMins % 7 + 2}',
                          style: roboto(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
