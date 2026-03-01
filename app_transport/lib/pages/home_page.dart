import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_widgets.dart';
import 'flying_taxi_page.dart';
import 'transit_trips_page.dart';
import 'my_bookings_page.dart';
import 'chatbot_page.dart';
import 'profile_page.dart';

// ── Extra brand colours ──────────────────────────────────────────────────────
const _kDarkBlue = Color(0xFF4A44AA);
const _kRed = Color(0xFFE02850);

// ── Data models ──────────────────────────────────────────────────────────────
class _AiSuggestion {
  final String title;
  final String duration;
  final IconData icon;
  final List<Color> gradient;
  const _AiSuggestion(this.title, this.duration, this.icon, this.gradient);
}

class _Category {
  final String label;
  final IconData icon;
  final Color color;
  const _Category(this.label, this.icon, this.color);
}

class _Trip {
  final String name;
  final String location;
  final String duration;
  final String price;
  final String imageTag; // placeholder colour key
  final Color overlayColor;
  const _Trip(
    this.name,
    this.location,
    this.duration,
    this.price,
    this.imageTag,
    this.overlayColor,
  );
}

// ── Sample data ──────────────────────────────────────────────────────────────
const _suggestions = [
  _AiSuggestion('3-hour Giza Tour', '3 hrs', Icons.landscape_rounded, [
    Color(0xFF187BCD),
    Color(0xFF5BC0EB),
  ]),
  _AiSuggestion('Flying Taxi over Cairo', '30 min', Icons.flight_rounded, [
    Color(0xFF4A44AA),
    Color(0xFF7B6CF6),
  ]),
  _AiSuggestion('Short Nile Cruise', '2 hrs', Icons.sailing_rounded, [
    Color(0xFFE02850),
    Color(0xFFFF6B81),
  ]),
  _AiSuggestion('Old Cairo Walking', '1.5 hrs', Icons.directions_walk_rounded, [
    Color(0xFF0D7377),
    Color(0xFF14BFAB),
  ]),
];

const _categories = [
  _Category('Flying Taxi', Icons.flight_rounded, Color(0xFF4A44AA)),
  _Category('Transit Trips', Icons.directions_bus_rounded, kBlue),
  _Category('Services', Icons.wifi_tethering_rounded, Color(0xFFE02850)),
  _Category('Places', Icons.place_rounded, Color(0xFF5BC0EB)),
];

const _trips = [
  _Trip(
    'Pyramids of Giza',
    'Cairo, Egypt',
    '8 hours',
    '\$90',
    'giza',
    Color(0xFF2A6FBB),
  ),
  _Trip(
    'Nile River Cruise',
    'Luxor, Egypt',
    '5 hours',
    '\$120',
    'nile',
    Color(0xFF0D7377),
  ),
  _Trip(
    'Khan el-Khalili',
    'Old Cairo',
    '3 hours',
    '\$45',
    'khan',
    Color(0xFF4A44AA),
  ),
  _Trip(
    'Valley of Kings',
    'Luxor, Egypt',
    '6 hours',
    '\$110',
    'valley',
    Color(0xFFE02850),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _navIndex = 0;

  // ── staggered entrance animations ────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // 5 sections, staggered
    const sectionCount = 5;
    _fadeAnims = List.generate(sectionCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(sectionCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  Widget _stagger(int index, Widget child) => FadeTransition(
    opacity: _fadeAnims[index],
    child: SlideTransition(position: _slideAnims[index], child: child),
  );

  // ── build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        extendBody: true,
        body: Container(
          color: const Color(0xFFE8F4F8),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: topPad + 12),

                // ── 0  Header ────────────────────────────────────────
                _stagger(0, _buildHeader()),
                const SizedBox(height: 22),

                // ── 1  Search bar ────────────────────────────────────
                _stagger(1, _buildSearchBar()),
                const SizedBox(height: 22),

                // ── 2  AI Suggestions ───────────────────────────────
                _stagger(2, _buildAiSuggestions()),
                const SizedBox(height: 24),

                // ── 3  Categories ───────────────────────────────────
                _stagger(3, _buildCategories()),
                const SizedBox(height: 26),

                // ── 4  Popular Trips ────────────────────────────────
                _stagger(4, _buildPopularTrips()),
                const SizedBox(height: 96),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Header
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo row
          Center(
            child: Image.asset(
              'img/logo2.png',
              height: 72,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Greeting + title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, Traveler',
                      style: roboto(
                        fontSize: 14,
                        color: kLightBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Let's Enjoy\nYour Vacation!",
                      style: roboto(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              // Profile avatar
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [kBlue, kLightBlue]),
                    boxShadow: [
                      BoxShadow(
                        color: kBlue.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Search bar
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search for trips, landmarks or services...',
                style: roboto(fontSize: 13, color: Colors.grey.shade400),
              ),
            ),
            Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: kBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.tune_rounded, color: kBlue, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  AI Suggestions
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildAiSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              const Icon(Icons.smart_toy_rounded, color: _kDarkBlue, size: 18),
              const SizedBox(width: 6),
              Text(
                'AI Suggestions',
                style: roboto(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 22),
            itemCount: _suggestions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final s = _suggestions[i];
              return Container(
                width: 170,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: s.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: s.gradient.first.withValues(alpha: 0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      s.icon,
                      color: Colors.white.withValues(alpha: 0.85),
                      size: 26,
                    ),
                    const Spacer(),
                    Text(
                      s.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: roboto(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      s.duration,
                      style: roboto(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Categories
  // ═══════════════════════════════════════════════════════════════════
  void _openFlyingTaxi() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, anim, secAnim) => const FlyingTaxiPage(),
        transitionsBuilder: (context, anim, secAnim, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _openTransitTrips() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, anim, secAnim) => const TransitTripsPage(),
        transitionsBuilder: (context, anim, secAnim, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _openMyBookings() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, anim, secAnim) => const MyBookingsPage(),
        transitionsBuilder: (context, anim, secAnim, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _openProfile() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, anim, secAnim) => ProfilePage(
          onLogout: () {
            Navigator.of(context).pop();
          },
        ),
        transitionsBuilder: (context, anim, secAnim, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _categories.map((c) {
          return GestureDetector(
            onTap: c.label == 'Flying Taxi'
                ? _openFlyingTaxi
                : c.label == 'Transit Trips'
                ? _openTransitTrips
                : () {},
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: c.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: c.color.withValues(alpha: 0.18),
                      width: 1,
                    ),
                  ),
                  child: Icon(c.icon, color: c.color, size: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  c.label,
                  style: roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Popular Trips
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildPopularTrips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              Text(
                'Popular Trips',
                style: roboto(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'See All',
                  style: roboto(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Grid two-column
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.78,
            ),
            itemCount: _trips.length,
            itemBuilder: (context, i) => _TripCard(trip: _trips[i]),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Bottom nav
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildBottomNav() {
    // items: (icon, action-index)
    // action-index: -1=setState home, 1=flyingTaxi, 2=transit, 3=bookings, 4=chatbot, 5=profile
    const items = [
      (Icons.home_rounded, -1),
      (Icons.flight_rounded, 1),
      (Icons.directions_bus_rounded, 2),
      (Icons.calendar_today_rounded, 3),
      (Icons.smart_toy_rounded, 4),
      (Icons.person_outline_rounded, 5),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3AADE0), Color(0xFF6BCFF0)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(31),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3AADE0).withValues(alpha: 0.40),
                blurRadius: 22,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (i) {
              final active = i == _navIndex;
              final icon = items[i].$1;
              final action = items[i].$2;

              return GestureDetector(
                onTap: () {
                  if (action == 1) {
                    _openFlyingTaxi();
                  } else if (action == 2) {
                    _openTransitTrips();
                  } else if (action == 3) {
                    _openMyBookings();
                  } else if (action == 4) {
                    openChatBotFullPage(context);
                  } else if (action == 5) {
                    _openProfile();
                  } else {
                    setState(() => _navIndex = i);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white.withValues(alpha: 0.28)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: active
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.60),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  "Search with AI" button (wave shape)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildAiSearchButton() {
    return GestureDetector(
      onTap: () => openChatBotFullPage(context),
      child: SizedBox(
        width: 250,
        height: 68,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Wave / organic blob background
            CustomPaint(
              size: const Size(250, 68),
              painter: const _AiWavePainter(),
            ),
            // Content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.smart_toy_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Search with AI',
                      style: roboto(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // "NEW" badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB800),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB800).withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'NEW',
                    style: roboto(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Wave / organic blob painter for the AI search button
// ═════════════════════════════════════════════════════════════════════════════
class _AiWavePainter extends CustomPainter {
  const _AiWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(0, h * 0.50);
    // Top curve (dome)
    path.cubicTo(w * 0.12, -h * 0.12, w * 0.88, -h * 0.12, w, h * 0.50);
    // Bottom curve
    path.cubicTo(w * 0.88, h * 1.12, w * 0.12, h * 1.12, 0, h * 0.50);
    path.close();

    // Shadow
    final shadowPaint = Paint()
      ..color = const Color(0xFF4A44AA).withValues(alpha: 0.30)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.save();
    canvas.translate(0, 4);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // Gradient fill
    final rect = Rect.fromLTWH(0, 0, w, h);
    final gradient = const LinearGradient(
      colors: [Color(0xFF4A44AA), Color(0xFF187BCD)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═════════════════════════════════════════════════════════════════════════════
//  Trip card widget
// ═════════════════════════════════════════════════════════════════════════════
class _TripCard extends StatelessWidget {
  final _Trip trip;
  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
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
          // Image area placeholder
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        trip.overlayColor,
                        trip.overlayColor.withValues(alpha: 0.65),
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.photo_rounded,
                      color: Colors.white.withValues(alpha: 0.35),
                      size: 40,
                    ),
                  ),
                ),
                // Gradient overlay at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 46,
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
                // Name + location overlay
                Positioned(
                  left: 12,
                  bottom: 8,
                  right: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.place_rounded,
                            color: Colors.white.withValues(alpha: 0.80),
                            size: 12,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              trip.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: roboto(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.80),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Heart icon
                Positioned(
                  top: 8,
                  right: 8,
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
          // Info area
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Duration
                  Icon(
                    Icons.schedule_rounded,
                    size: 13,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trip.duration,
                    style: roboto(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  // Price
                  Text(
                    trip.price,
                    style: roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: kBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
