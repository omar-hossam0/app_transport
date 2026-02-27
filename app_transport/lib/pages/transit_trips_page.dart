import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_widgets.dart';
import 'transit_trip_detail_page.dart';

// ── Brand colours ─────────────────────────────────────────────────────────
const _kDark = Color(0xFF1A1A2E);

// ── Review model ──────────────────────────────────────────────────────────
class Review {
  final String name;
  final int rating;
  final String date;
  final String comment;
  const Review({
    required this.name,
    required this.rating,
    required this.date,
    required this.comment,
  });
}

// ── Trip model ────────────────────────────────────────────────────────────
class TransitTrip {
  final String name;
  final String shortDescription;
  final int durationHours;
  final double durationHoursExact;
  final int priceUsd;
  final String imageUrl;
  final Color accentColor;
  final String routeLabel;
  final List<TransitStop> itinerary;
  final List<String> included;
  final List<Review> reviews;

  const TransitTrip({
    required this.name,
    required this.shortDescription,
    required this.durationHours,
    required this.durationHoursExact,
    required this.priceUsd,
    required this.imageUrl,
    required this.accentColor,
    required this.routeLabel,
    required this.itinerary,
    required this.included,
    this.reviews = const [],
  });

  String get durationLabel =>
      durationHoursExact == durationHoursExact.truncateToDouble()
      ? '${durationHours}h'
      : '${durationHoursExact}h';
  String get priceLabel => '\$$priceUsd';
}

class TransitStop {
  final String title;
  final String subtitle;
  final String duration;
  final IconData icon;
  final Color color;

  const TransitStop({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.icon,
    required this.color,
  });
}

// ── Trip data ─────────────────────────────────────────────────────────────
final _transitTrips = <TransitTrip>[
  TransitTrip(
    name: 'Giza Pyramids, NMEC & Nile Corniche',
    shortDescription:
        'Explore Egypt\'s iconic pyramids, discover ancient history at NMEC, and relax by the Nile — all in one transit experience.',
    durationHours: 8,
    durationHoursExact: 8.0,
    priceUsd: 90,
    imageUrl:
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?w=800&q=80',
    accentColor: const Color(0xFFD4A843),
    routeLabel: 'Airport → Pyramids → NMEC → Nile → Airport',
    included: ['Airport Transfer', 'Tour Guide', 'Entry Tickets', 'Light Meal'],
    itinerary: [
      TransitStop(
        title: 'Pickup – Cairo International Airport',
        subtitle: 'Private car pickup from arrivals hall',
        duration: '30 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
      ),
      TransitStop(
        title: 'Giza Pyramids Plateau',
        subtitle: 'Great Pyramid, Sphinx, panoramic views & free photo time',
        duration: '3 hours',
        icon: Icons.landscape_rounded,
        color: Color(0xFFD4A843),
      ),
      TransitStop(
        title: 'National Museum of Egyptian Civilization',
        subtitle: 'Museum tour + Royal Mummies Hall',
        duration: '1.5 hours',
        icon: Icons.museum_rounded,
        color: Color(0xFFE02850),
      ),
      TransitStop(
        title: 'Nile Corniche – Fustat',
        subtitle: 'Waterfront stroll + light meal by the Nile',
        duration: '1 hour',
        icon: Icons.water_rounded,
        color: Color(0xFF0D7377),
      ),
      TransitStop(
        title: 'Return to Cairo International Airport',
        subtitle: 'Direct drop-off at departures',
        duration: '30 min',
        icon: Icons.flight_takeoff_rounded,
        color: Color(0xFF187BCD),
      ),
    ],
    reviews: [
      Review(
        name: 'Ahmed Mohamed',
        rating: 5,
        date: '2 days ago',
        comment: 'الأهرامات رائعة والمتحف مذهل! رحلة منظمة بشكل ممتاز.',
      ),
      Review(
        name: 'Sarah Johnson',
        rating: 5,
        date: '5 days ago',
        comment:
            'Incredible experience! The guide was knowledgeable. Highly recommend!',
      ),
      Review(
        name: 'Layla Hassan',
        rating: 4,
        date: '1 week ago',
        comment: 'مشهد النيل جميل جداً والطعم كان لذيذ!',
      ),
    ],
  ),
  TransitTrip(
    name: 'Old Cairo & Khan El-Khalili Bazaar',
    shortDescription:
        'Walk through Cairo\'s oldest Christian quarter, visit hanging church, and explore the famous Islamic bazaar.',
    durationHours: 5,
    durationHoursExact: 5.0,
    priceUsd: 65,
    imageUrl:
        'https://images.unsplash.com/photo-1539768942893-daf53e448371?w=800&q=80',
    accentColor: const Color(0xFF4A44AA),
    routeLabel: 'Airport → Old Cairo → Khan El-Khalili → Airport',
    included: ['Airport Transfer', 'Tour Guide', 'Entry Tickets'],
    itinerary: [
      TransitStop(
        title: 'Pickup – Cairo International Airport',
        subtitle: 'Private car from arrivals',
        duration: '25 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
      ),
      TransitStop(
        title: 'Coptic Cairo',
        subtitle: 'Hanging Church, Ben Ezra Synagogue, Coptic Museum',
        duration: '1.5 hours',
        icon: Icons.church_rounded,
        color: Color(0xFF4A44AA),
      ),
      TransitStop(
        title: 'Al-Azhar Mosque & Al-Hussein',
        subtitle: 'Iconic Islamic monuments in the heart of Old Cairo',
        duration: '1 hour',
        icon: Icons.mosque_rounded,
        color: Color(0xFF8B6F47),
      ),
      TransitStop(
        title: 'Khan El-Khalili Bazaar',
        subtitle: 'Shopping, spices, antiques, and Egyptian coffee',
        duration: '1.5 hours',
        icon: Icons.shopping_bag_rounded,
        color: Color(0xFFE87832),
      ),
      TransitStop(
        title: 'Return to Cairo Airport',
        subtitle: 'Direct drop-off',
        duration: '25 min',
        icon: Icons.flight_takeoff_rounded,
        color: Color(0xFF187BCD),
      ),
    ],
    reviews: [
      Review(
        name: 'Fatima Khalil',
        rating: 5,
        date: '1 day ago',
        comment: 'خان الخليلي رائع والكنيسة المعلقة جميلة جداً!',
      ),
      Review(
        name: 'Mike Brown',
        rating: 4,
        date: '4 days ago',
        comment: 'Great bazaar experience and historic churches. Worth it!',
      ),
      Review(
        name: 'Noor Hassan',
        rating: 5,
        date: '1 week ago',
        comment: 'الشارع القديم مليء بالتاريخ والحرف التقليدية!',
      ),
    ],
  ),
  TransitTrip(
    name: 'Cairo Tower & Nile Felucca Cruise',
    shortDescription:
        'Admire Cairo from the top of the iconic Tower, then enjoy a relaxing traditional felucca sailboat on the Nile.',
    durationHours: 4,
    durationHoursExact: 4.0,
    priceUsd: 55,
    imageUrl:
        'https://images.unsplash.com/photo-1572252009286-268acec5ca0a?w=800&q=80',
    accentColor: const Color(0xFF187BCD),
    routeLabel: 'Airport → Cairo Tower → Nile Cruise → Airport',
    included: ['Airport Transfer', 'Felucca Boat', 'Tower Tickets'],
    itinerary: [
      TransitStop(
        title: 'Pickup – Cairo Airport',
        subtitle: 'Private transfer to Zamalek island',
        duration: '30 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
      ),
      TransitStop(
        title: 'Cairo Tower – Gezira',
        subtitle: '187m tall lotus-shaped tower, 360° panoramic views',
        duration: '1 hour',
        icon: Icons.cell_tower_rounded,
        color: Color(0xFF187BCD),
      ),
      TransitStop(
        title: 'Nile Felucca Sailing',
        subtitle: 'Traditional Egyptian sailboat past Rhoda Island',
        duration: '1.5 hours',
        icon: Icons.sailing_rounded,
        color: Color(0xFF5BC0EB),
      ),
      TransitStop(
        title: 'Return to Cairo Airport',
        subtitle: 'Direct drop-off at departures',
        duration: '30 min',
        icon: Icons.flight_takeoff_rounded,
        color: Color(0xFF187BCD),
      ),
    ],
    reviews: [
      Review(
        name: 'Youssef Ahmed',
        rating: 5,
        date: '2 days ago',
        comment: 'برج القاهرة مشهد رائع والفلوكة تجربة رومانسية جداً!',
      ),
      Review(
        name: 'Emma Davis',
        rating: 5,
        date: '1 week ago',
        comment: 'Felucca ride at sunset was magical! Perfect 4-hour trip.',
      ),
      Review(
        name: 'Omar Hassan',
        rating: 4,
        date: '2 weeks ago',
        comment: 'المنظر من البرج خيالي أفضل عند غروب الشمس.',
      ),
    ],
  ),
  TransitTrip(
    name: 'Saladin Citadel & Islamic Cairo',
    shortDescription:
        'Visit the magnificent alabaster mosque of Muhammad Ali, explore the medieval citadel, and walk through historic Islamic streets.',
    durationHours: 5,
    durationHoursExact: 5.0,
    priceUsd: 70,
    imageUrl:
        'https://images.unsplash.com/photo-1553913861-c0fddf2619ee?w=800&q=80',
    accentColor: const Color(0xFFE02850),
    routeLabel: 'Airport → Citadel → Al-Muizz Street → Airport',
    included: ['Airport Transfer', 'Tour Guide', 'Citadel Tickets', 'Tea'],
    itinerary: [
      TransitStop(
        title: 'Pickup – Cairo International Airport',
        subtitle: 'Private car to the citadel',
        duration: '30 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
      ),
      TransitStop(
        title: 'Saladin Citadel',
        subtitle: 'Muhammad Ali Mosque, Military Museum, panoramic views',
        duration: '2 hours',
        icon: Icons.fort_rounded,
        color: Color(0xFFE02850),
      ),
      TransitStop(
        title: 'Al-Muizz Street',
        subtitle: 'Medieval Islamic architecture, bazaars, and food stalls',
        duration: '1.5 hours',
        icon: Icons.storefront_rounded,
        color: Color(0xFF8B6F47),
      ),
      TransitStop(
        title: 'Return to Cairo Airport',
        subtitle: 'Direct drop-off',
        duration: '30 min',
        icon: Icons.flight_takeoff_rounded,
        color: Color(0xFF187BCD),
      ),
    ],
    reviews: [
      Review(
        name: 'Reem Mansour',
        rating: 5,
        date: '3 days ago',
        comment: 'القلعة مجموعة أثرية رهيبة والشارع الإسلامي ممتع جداً!',
      ),
      Review(
        name: 'James Wilson',
        rating: 5,
        date: '1 week ago',
        comment:
            'Al-Muizz Street is fascinating! Great Islamic architecture preserved.',
      ),
      Review(
        name: 'Dina Noor',
        rating: 5,
        date: '2 weeks ago',
        comment: 'جولة تاريخية ممتعة هل تعود لآلاف السنين!',
      ),
    ],
  ),
  TransitTrip(
    name: 'Memphis, Saqqara & Dahshur Pyramids',
    shortDescription:
        'Step 5000 years back in time at the Step Pyramid of Djoser, the Bent Pyramid, and ancient Memphis — Egypt\'s first capital.',
    durationHours: 8,
    durationHoursExact: 8.0,
    priceUsd: 100,
    imageUrl:
        'https://images.unsplash.com/photo-1503177119275-0aa32b3a9368?w=800&q=80',
    accentColor: const Color(0xFF8B6F47),
    routeLabel: 'Airport → Memphis → Saqqara → Dahshur → Airport',
    included: ['Airport Transfer', 'Tour Guide', 'Entry Tickets', 'Lunch'],
    itinerary: [
      TransitStop(
        title: 'Pickup – Cairo International Airport',
        subtitle: 'Private car heading south',
        duration: '40 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
      ),
      TransitStop(
        title: 'Memphis – Egypt\'s First Capital',
        subtitle: 'Statue of Ramesses II, Alabaster Sphinx',
        duration: '1.5 hours',
        icon: Icons.account_balance_rounded,
        color: Color(0xFF8B6F47),
      ),
      TransitStop(
        title: 'Saqqara – Step Pyramid of Djoser',
        subtitle: 'Oldest pyramid in Egypt (2700 BC), ancient necropolis',
        duration: '2 hours',
        icon: Icons.landscape_rounded,
        color: Color(0xFFD4A843),
      ),
      TransitStop(
        title: 'Dahshur – Bent & Red Pyramids',
        subtitle: 'Less-visited pyramids with stunning desert backdrops',
        duration: '1.5 hours',
        icon: Icons.landscape_rounded,
        color: Color(0xFFE87832),
      ),
      TransitStop(
        title: 'Return to Cairo Airport',
        subtitle: 'Drop-off at departures terminal',
        duration: '40 min',
        icon: Icons.flight_takeoff_rounded,
        color: Color(0xFF187BCD),
      ),
    ],
    reviews: [
      Review(
        name: 'Tarek Saeed',
        rating: 5,
        date: '1 day ago',
        comment: 'هرم جوسر مذهل وواد الحيتان موقع فريد وعميق التاريخ!',
      ),
      Review(
        name: 'Patricia Miller',
        rating: 5,
        date: '5 days ago',
        comment:
            'Three pyramids in one day! Memphis was fascinating. Excellent guide!',
      ),
      Review(
        name: 'Aisha Karim',
        rating: 5,
        date: '10 days ago',
        comment: 'تجربة أثرية شاملة تجمع بين ثلاث مواقع مهمة!',
      ),
    ],
  ),
];

// ═════════════════════════════════════════════════════════════════════════════
//  TransitTripsPage
// ═════════════════════════════════════════════════════════════════════════════
class TransitTripsPage extends StatefulWidget {
  const TransitTripsPage({super.key});

  @override
  State<TransitTripsPage> createState() => _TransitTripsPageState();
}

class _TransitTripsPageState extends State<TransitTripsPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int _filterIndex = 0; // 0=All, 1=Short, 2=Medium, 3=Long
  final _filters = ['All', '≤4h', '4–8h', '8h+'];

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

  List<TransitTrip> get _filtered {
    switch (_filterIndex) {
      case 1:
        return _transitTrips.where((t) => t.durationHours <= 4).toList();
      case 2:
        return _transitTrips
            .where((t) => t.durationHours > 4 && t.durationHours <= 8)
            .toList();
      case 3:
        return _transitTrips.where((t) => t.durationHours > 8).toList();
      default:
        return _transitTrips;
    }
  }

  Animation<double> _fade(int i) {
    final start = (i * 0.10).clamp(0.0, 0.6);
    final end = (start + 0.45).clamp(0.0, 1.0);
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  Animation<Offset> _slide(int i) {
    final start = (i * 0.10).clamp(0.0, 0.6);
    final end = (start + 0.45).clamp(0.0, 1.0);
    return Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
  }

  void _openDetail(TransitTrip trip) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 520),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (c, a, s) => TransitTripDetailPage(trip: trip),
        transitionsBuilder: (c, a, s, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.06, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final trips = _filtered;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          color: const Color(0xFFE8F4F8),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── App bar ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(22, topPad + 14, 22, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F4FF),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: _kDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Transit Trips',
                            style: roboto(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: kBlue.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.flight_land_rounded,
                                  color: kBlue,
                                  size: 14,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Cairo Airport',
                                  style: roboto(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: kBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Trips that start & end at Cairo International Airport',
                        style: roboto(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(_filters.length, (i) {
                            final active = _filterIndex == i;
                            return GestureDetector(
                              onTap: () => setState(() => _filterIndex = i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: active ? kBlue : Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: active
                                        ? kBlue
                                        : Colors.grey.shade200,
                                  ),
                                  boxShadow: active
                                      ? [
                                          BoxShadow(
                                            color: kBlue.withValues(
                                              alpha: 0.28,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Text(
                                  _filters[i],
                                  style: roboto(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: active
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 22)),

              // ── Trip list (timeline style) ───────────────────────────
              trips.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 52,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No trips for this filter',
                              style: roboto(
                                fontSize: 15,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, i) {
                          final trip = trips[i];
                          final isLast = i == trips.length - 1;
                          return FadeTransition(
                            opacity: _fade(i),
                            child: SlideTransition(
                              position: _slide(i),
                              child: _TimelineRow(
                                trip: trip,
                                isLast: isLast,
                                index: i,
                                onTap: () => _openDetail(trip),
                              ),
                            ),
                          );
                        }, childCount: trips.length),
                      ),
                    ),

              // ── AI Suggestion Banner ─────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4A44AA), Color(0xFF7B6CF6)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF4A44AA,
                            ).withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.smart_toy_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Find the best trip for my time',
                                  style: roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'AI-powered layover trip recommendations',
                                  style: roboto(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.78),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
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
}

// ═════════════════════════════════════════════════════════════════════════════
//  Timeline Row Widget
// ═════════════════════════════════════════════════════════════════════════════
class _TimelineRow extends StatelessWidget {
  final TransitTrip trip;
  final bool isLast;
  final int index;
  final VoidCallback onTap;

  const _TimelineRow({
    required this.trip,
    required this.isLast,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Duration badge color
    final durColor = trip.durationHours <= 4
        ? const Color(0xFF0D7377)
        : trip.durationHours <= 8
        ? kBlue
        : const Color(0xFFE02850);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline column ───────────────────────────────────────
          SizedBox(
            width: 52,
            child: Column(
              children: [
                // Duration badge
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: durColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: durColor, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        trip.durationLabel,
                        style: roboto(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: durColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Connecting line
                if (!isLast)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      width: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            durColor.withValues(alpha: 0.5),
                            Colors.grey.shade200,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                if (isLast) const SizedBox(height: 20),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Card ──────────────────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                margin: EdgeInsets.only(bottom: isLast ? 0 : 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Image ───────────────────────────────────────
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          Image.network(
                            trip.imageUrl,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (ctx, child, prog) {
                              if (prog == null) return child;
                              return Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      trip.accentColor,
                                      trip.accentColor.withValues(alpha: 0.5),
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
                              height: 150,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    trip.accentColor,
                                    trip.accentColor.withValues(alpha: 0.6),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.directions_bus_rounded,
                                  color: Colors.white.withValues(alpha: 0.4),
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                          // Gradient overlay
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 60,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.55),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Price badge
                          Positioned(
                            bottom: 10,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                trip.priceLabel,
                                style: roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: kBlue,
                                ),
                              ),
                            ),
                          ),
                          // Rating badge
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFFFC107),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '4.${(trip.priceUsd % 5) + 5}',
                                    style: roboto(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
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

                    // ── Info ────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.name,
                            style: roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            trip.shortDescription,
                            style: roboto(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),

                          // Route row
                          Row(
                            children: [
                              Icon(
                                Icons.route_rounded,
                                size: 13,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  trip.routeLabel,
                                  style: roboto(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Duration + Book button
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: trip.accentColor.withValues(
                                    alpha: 0.10,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 13,
                                      color: trip.accentColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${trip.durationHours} Hours',
                                      style: roboto(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: trip.accentColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: onTap,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF187BCD),
                                        Color(0xFF5BC0EB),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: kBlue.withValues(alpha: 0.30),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'Details',
                                    style: roboto(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
