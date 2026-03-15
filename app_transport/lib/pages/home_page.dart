import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'auth_widgets.dart';
import 'flying_taxi_page.dart';
import 'transit_trips_page.dart';
import 'transit_trip_detail_page.dart';
import 'trip_detail_page.dart';
import 'my_bookings_page.dart';
import 'chatbot_page.dart';
import 'profile_page.dart';
import 'services_page.dart';
import 'places_page.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import '../services/trip_service.dart';
import '../services/notification_service.dart';
import '../models/trip_model.dart';

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

// (popular trips are derived from TripService data)

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

// (trip cards now built dynamically from TripService data)

// ─────────────────────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _navIndex = 0;
  final _chatController = ChatBotController();

  // ── staggered entrance animations ────────────────────────────────
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();

    // Load favorites when first entering home page
    Future.delayed(const Duration(milliseconds: 100), () {
      final auth = Provider.of<AuthService>(context, listen: false);
      final favorites = Provider.of<FavoritesService>(context, listen: false);
      final trips = Provider.of<TripService>(context, listen: false);
      final notifier = Provider.of<NotificationService>(context, listen: false);
      if (auth.currentUser != null) {
        favorites.loadFavorites(auth.currentUser!.uid);
        notifier.registerForUser(auth.currentUser!.uid);
      }
      trips.loadTrips();
    });

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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _navIndex != 0) {
          setState(() => _navIndex = 0);
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: _navIndex,
            children: [
              _buildHomeContent(),       // 0
              const FlyingTaxiPage(),    // 1
              const TransitTripsPage(),  // 2
              const MyBookingsPage(),    // 3
              ChatBotPage(
                controller: _chatController,
                onBack: () => setState(() => _navIndex = 0),
              ), // 4
              ProfilePage(onLogout: () => setState(() => _navIndex = 0)), // 5
              const ServicesPage(),      // 6
              const PlacesPage(),        // 7
            ],
          ),
          bottomNavigationBar: _buildBottomNav(),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
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
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Header
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    final screenW = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo — centred, responsive width, proper contain
          Center(
            child: Image.asset(
              'img/logo_new.png',
              width: screenW * 0.42,
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
                    Consumer<AuthService>(
                      builder: (context, auth, _) {
                        final name = auth.currentUser?.name ?? 'Traveler';
                        return Text(
                          'Hi, $name',
                          style: roboto(
                            fontSize: 14,
                            color: kLightBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
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
                onTap: () => setState(() => _navIndex = 5),
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
              return GestureDetector(
                onTap: () {
                  setState(() => _navIndex = 4);
                  Future.delayed(const Duration(milliseconds: 600), () {
                    _chatController.send(s.title);
                  });
                },
                child: Container(
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

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _categories.map((c) {
          return GestureDetector(
            onTap: c.label == 'Flying Taxi'
                ? () => setState(() => _navIndex = 1)
                : c.label == 'Transit Trips'
                ? () => setState(() => _navIndex = 2)
                : c.label == 'Services'
                ? () => setState(() => _navIndex = 6)
                : () => setState(() => _navIndex = 7),
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
    final tripService = context.watch<TripService>();
    final popular = _selectPopularTrips(tripService.activeTrips);
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
                onTap: () => _openTransitTrips(),
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
        popular.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text(
                  'No trips available yet',
                  style: roboto(color: Colors.grey.shade500),
                ),
              )
            : Padding(
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
                  itemCount: popular.length,
                  itemBuilder: (context, i) => _TripCard(trip: popular[i]),
                ),
              ),
      ],
    );
  }

  List<TripModel> _selectPopularTrips(List<TripModel> trips) {
    if (trips.isEmpty) return [];
    final flying = trips.where((t) => t.isFlying).toList();
    final transit = trips.where((t) => t.isTransit).toList();
    final result = <TripModel>[];
    result.addAll(transit.take(2));
    result.addAll(flying.take(2));
    return result;
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Bottom nav — frosted glass floating pill
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildBottomNav() {
    const items = [
      (Icons.home_rounded, 'Home', -1),
      (Icons.flight_rounded, 'Flying', 1),
      (Icons.directions_bus_rounded, 'Transit', 2),
      (Icons.calendar_today_rounded, 'Bookings', 3),
      (Icons.smart_toy_rounded, 'AI Chat', 4),
      (Icons.person_outline_rounded, 'Profile', 5),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF0D1226).withValues(alpha: 0.58),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.13),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(items.length, (i) {
                    final active = i == _navIndex;
                    final icon = items[i].$1;
                    final label = items[i].$2;
                    return _NavItem(
                      icon: icon,
                      label: label,
                      active: active,
                      onTap: () => setState(() => _navIndex = i),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Nav item — animated label pill
// ═════════════════════════════════════════════════════════════════════════════
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
        height: 44,
        padding: EdgeInsets.symmetric(horizontal: active ? 15 : 10),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [Color(0xFF187BCD), Color(0xFF5BC0EB)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          borderRadius: BorderRadius.circular(22),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFF187BCD).withValues(alpha: 0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: active
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.52),
            ),
            // ── Animated label slide-in ──────────────────────────────
            ClipRect(
              child: AnimatedAlign(
                alignment: Alignment.centerLeft,
                widthFactor: active ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                child: AnimatedOpacity(
                  opacity: active ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 220),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 7),
                    child: Text(
                      label,
                      style: roboto(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Trip card widget
// ═════════════════════════════════════════════════════════════════════════════
class _TripCard extends StatelessWidget {
  final TripModel trip;
  const _TripCard({required this.trip});

  void _open(BuildContext context) {
    if (trip.isFlying) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TripDetailPage(trip: trip),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TransitTripDetailPage(trip: trip),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
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
            // Image area
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    trip.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            trip.accentColor,
                            trip.accentColor.withValues(alpha: 0.65),
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
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                            color: trip.accentColor.withValues(alpha: 0.3),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
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
                                trip.locationLabel,
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
                    child: Consumer2<AuthService, FavoritesService>(
                      builder: (context, auth, favorites, _) {
                        final uid = auth.currentUser?.uid ?? '';
                            final isFav =
                              uid.isNotEmpty && favorites.isFavorite(trip.id);
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: uid.isEmpty
                                ? null
                                : () async {
                                    try {
                                      await favorites.toggleFavorite(
                                        uid,
                                        trip.id,
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  },
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFav
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: _kRed,
                                size: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Info area
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
                      trip.durationLabel,
                      style: roboto(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    const Spacer(),
                    // Price
                    Text(
                      trip.priceLabel,
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
      ),
    );
  }
}
