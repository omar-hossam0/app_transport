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
import 'sign_in_page.dart';
import 'services_page.dart';
import 'places_page.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import '../services/trip_service.dart';
import '../services/notification_service.dart';
import '../services/language_service.dart';
import '../services/ui_translation.dart';
import '../services/smooth_navigation.dart';
import '../models/trip_model.dart';
import '../widgets/trip_image.dart';

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
  _AiSuggestion(
    'Find the best trip for my time',
    'Set hours',
    Icons.schedule_rounded,
    [Color(0xFF4A44AA), Color(0xFF7B6CF6)],
  ),
  _AiSuggestion('3-hour Giza Tour', '3 hrs', Icons.landscape_rounded, [
    Color(0xFF187BCD),
    Color(0xFF5BC0EB),
  ]),
  _AiSuggestion('Flying Taxi over Cairo', '30 min', Icons.flight_rounded, [
    Color(0xFF4A44AA),
    Color(0xFF7B6CF6),
  ]),
  _AiSuggestion('Old Cairo Walking', '1.5 hrs', Icons.directions_walk_rounded, [
    Color(0xFF0D7377),
    Color(0xFF14BFAB),
  ]),
  _AiSuggestion('Short Nile Cruise', '2 hrs', Icons.sailing_rounded, [
    Color(0xFFE02850),
    Color(0xFFFF6B81),
  ]),
  _AiSuggestion('Transit day in Cairo', '5 hrs', Icons.directions_bus_rounded, [
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
  final _pageController = PageController(initialPage: 0);
  final _chatController = ChatBotController();
  final _searchController = TextEditingController();

  String _t(String en, String ar) =>
      context.read<LanguageService>().isArabic ? ar : en;

  String _suggestionTitle(int index) {
    switch (index) {
      case 0:
        return _t(
          'Find the best trip for my time',
          'ابحث عن افضل رحلة حسب وقتي',
        );
      case 1:
        return _t('3-hour Giza Tour', 'جولة الجيزة 3 ساعات');
      case 2:
        return _t('Flying Taxi over Cairo', 'تاكسي طائر فوق القاهرة');
      case 3:
        return _t('Old Cairo Walking', 'جولة مشي في القاهرة القديمة');
      case 4:
        return _t('Short Nile Cruise', 'رحلة نيلية قصيرة');
      default:
        return _t('Transit day in Cairo', 'يوم ترانزيت في القاهرة');
    }
  }

  String _suggestionDuration(int index) {
    switch (index) {
      case 0:
        return _t('Set hours', 'حدد الساعات');
      case 1:
        return _t('3 hrs', '3 ساعات');
      case 2:
        return _t('30 min', '30 دقيقة');
      case 3:
        return _t('1.5 hrs', 'ساعة ونصف');
      case 4:
        return _t('2 hrs', 'ساعتان');
      default:
        return _t('5 hrs', '5 ساعات');
    }
  }

  String _categoryLabel(String englishLabel) {
    switch (englishLabel) {
      case 'Flying Taxi':
        return _t('Flying Taxi', 'التاكسي الطائر');
      case 'Transit Trips':
        return _t('Transit Trips', 'رحلات الترانزيت');
      case 'Services':
        return _t('Services', 'الخدمات');
      case 'Places':
        return _t('Places', 'الاماكن');
      default:
        return englishLabel;
    }
  }

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
    _searchController.dispose();
    _pageController.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  Widget _stagger(int index, Widget child) => FadeTransition(
    opacity: _fadeAnims[index],
    child: SlideTransition(position: _slideAnims[index], child: child),
  );

  void _switchTab(int index) {
    if (index == _navIndex) return;
    setState(() => _navIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _openChatWithMessage(String message) {
    final text = message.trim();
    if (text.isEmpty) return;

    _switchTab(4);
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _chatController.send(text);
    });
  }

  TripModel? _pickTripFromBackend({
    required bool flying,
    List<String> keywords = const [],
  }) {
    final all = context.read<TripService>().activeTrips;
    final byType = all.where((t) => flying ? t.isFlying : t.isTransit).toList();
    if (byType.isEmpty) return null;

    if (keywords.isNotEmpty) {
      for (final trip in byType) {
        final searchable = _normalizeSearchText(
          [
            trip.name,
            trip.shortDescription,
            trip.description,
            trip.routeLabel,
          ].join(' '),
        );
        final hasKeyword = keywords.any(
          (k) => searchable.contains(_normalizeSearchText(k)),
        );
        if (hasKeyword) return trip;
      }
    }

    return byType.first;
  }

  void _onAiSuggestionTap(int index) {
    if (index == 0) {
      final isArabic = context.read<LanguageService>().isArabic;
      _openChatWithMessage(
        isArabic
            ? 'اريد اقتراح رحلة على حسب مدة الترانزيت المتاحة لدي. اسالني اولا عن عدد الساعات ثم اقترح الانسب.'
            : 'I want a trip recommendation based on my layover time. Ask me first how many hours I have, then suggest the best option.',
      );
      return;
    }

    TripModel? trip;
    switch (index) {
      case 1:
        trip = _pickTripFromBackend(
          flying: false,
          keywords: ['giza', 'pyramid', 'pyramids', 'اهرامات', 'جيزه'],
        );
        break;
      case 2:
        trip = _pickTripFromBackend(
          flying: true,
          keywords: ['cairo', 'nile', 'القاهره', 'نيل'],
        );
        break;
      case 3:
        trip = _pickTripFromBackend(
          flying: false,
          keywords: ['old cairo', 'historic', 'خان', 'معز', 'قلعه'],
        );
        break;
      case 4:
        trip = _pickTripFromBackend(
          flying: false,
          keywords: ['nile', 'cruise', 'river', 'نيل'],
        );
        break;
      default:
        trip = _pickTripFromBackend(flying: false);
        break;
    }

    if (trip != null) {
      _openTripDetail(context, trip);
      return;
    }

    _openChatWithMessage(_suggestions[index].title);
  }

  // ── build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    context.watch<LanguageService>();
    final auth = context.watch<AuthService>();
    if (auth.currentUser == null) {
      return const SignInPage();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _navIndex != 0) {
          _switchTab(0);
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          extendBody: true,
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              if (_navIndex != index) {
                setState(() => _navIndex = index);
              }
            },
            children: [
              _buildHomeContent(), // 0
              FlyingTaxiPage(onBack: () => _switchTab(0)), // 1
              TransitTripsPage(onBack: () => _switchTab(0)), // 2
              const MyBookingsPage(), // 3
              ChatBotPage(
                controller: _chatController,
                onBack: () => _switchTab(0),
              ), // 4
              ProfilePage(
                onLogout: () {
                  if (!mounted) return;
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const SignInPage()),
                    (_) => false,
                  );
                },
              ), // 5
              const ServicesPage(), // 6
              const PlacesPage(), // 7
            ],
          ),
          bottomNavigationBar: _buildBottomNav(),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    final topPad = MediaQuery.of(context).padding.top;
    final hasSearchQuery = _searchController.text.trim().isNotEmpty;
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

            if (!hasSearchQuery) ...[
              // ── 2  AI Suggestions ───────────────────────────────
              _stagger(2, _buildAiSuggestions()),
              const SizedBox(height: 24),

              // ── 3  Categories ───────────────────────────────────
              _stagger(3, _buildCategories()),
              const SizedBox(height: 26),

              // ── 4  Popular Trips ────────────────────────────────
              _stagger(4, _buildPopularTrips()),
            ] else ...[
              // While searching, show trips directly and hide AI suggestion cards.
              _buildPopularTrips(),
            ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: SizedBox(
        height: 124,
        child: Row(
          children: [
            // Greeting + title on the left
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Consumer<AuthService>(
                    builder: (context, auth, _) {
                      final name = auth.currentUser?.name ?? 'Traveler';
                      return Text(
                        'Hi, $name',
                        style: roboto(
                          fontSize: 12,
                          color: kLightBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _t("Let's Enjoy\nYour Vacation!", 'استمتع\nبرحلتك!'),
                    style: roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Logo exactly between left content and avatar
            Transform.scale(
              scale: 1.2,
              child: Image.asset(
                'img/logo_new.png',
                width: 138,
                height: 138,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            // Profile avatar on the right
            GestureDetector(
              onTap: () => _switchTab(5),
              child: Consumer<AuthService>(
                builder: (context, auth, _) {
                  final photoUrl = auth.currentUser?.photoUrl ?? '';
                  return Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [kBlue, kLightBlue],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: kBlue.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: photoUrl.isEmpty
                          ? const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 28,
                            )
                          : TripImage(
                              imageUrl: photoUrl,
                              fit: BoxFit.cover,
                              width: 58,
                              height: 58,
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) {
                  setState(() {});
                  FocusScope.of(context).unfocus();
                },
                style: roboto(fontSize: 13),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: _t('Search for trips...', 'ابحث عن الرحلات...'),
                  hintStyle: roboto(fontSize: 13, color: Colors.grey.shade400),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (_searchController.text.trim().isNotEmpty) {
                  _searchController.clear();
                  setState(() {});
                } else {
                  FocusScope.of(context).unfocus();
                }
              },
              child: Container(
                width: 38,
                height: 38,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: kBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  _searchController.text.trim().isNotEmpty
                      ? Icons.close_rounded
                      : Icons.search_rounded,
                  color: kBlue,
                  size: 18,
                ),
              ),
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
    final suggestionCount = _suggestions.length;

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
                _t('AI Suggestions', 'اقتراحات الذكاء الاصطناعي'),
                style: roboto(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 22),
            itemCount: suggestionCount,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final s = _suggestions[i];
              final suggestionTitle = _suggestionTitle(i);
              final suggestionDuration = _suggestionDuration(i);
              return GestureDetector(
                onTap: () => _onAiSuggestionTap(i),
                child: Container(
                  width: 180,
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
                        suggestionTitle,
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
                        suggestionDuration,
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
          final targetIndex = c.label == 'Flying Taxi'
              ? 1
              : c.label == 'Transit Trips'
              ? 2
              : c.label == 'Services'
              ? 6
              : 7;
          return GestureDetector(
            onTap: () => _switchTab(targetIndex),
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
                  _categoryLabel(c.label),
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
    final query = _searchController.text.trim();
    final isSearching = query.isNotEmpty;
    final tripsToShow = isSearching
        ? _filterTrips(tripService.activeTrips, query)
        : _selectPopularTrips(tripService.activeTrips);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              Text(
                isSearching
                    ? _t('Search Results', 'نتائج البحث')
                    : _t('Popular Trips', 'الرحلات الاكثر طلبا'),
                style: roboto(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              if (!isSearching)
                GestureDetector(
                  onTap: () => _openTransitTrips(),
                  child: Text(
                    _t('See All', 'عرض الكل'),
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
        if (isSearching)
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 6, 22, 0),
            child: Text(
              _t('Results for "$query"', 'نتائج البحث عن "$query"'),
              style: roboto(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const SizedBox(height: 16),
        // Grid two-column
        if (tripsToShow.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Text(
              isSearching
                  ? _t(
                      'No trips matched your search',
                      'لا توجد رحلات مطابقة للبحث',
                    )
                  : _t('No trips available yet', 'لا توجد رحلات متاحة حاليا'),
              style: roboto(color: Colors.grey.shade500),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width >= 980
                    ? 4
                    : width >= 700
                    ? 3
                    : width <= 340
                    ? 1
                    : 2;
                final ratio = crossAxisCount == 1 ? 1.22 : 0.78;

                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: ratio,
                  ),
                  itemCount: tripsToShow.length,
                  itemBuilder: (context, i) => _TripCard(trip: tripsToShow[i]),
                );
              },
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
    result.addAll(transit.take(3));
    result.addAll(flying.take(3));
    return result;
  }

  static const Map<String, List<String>> _searchSynonyms = {
    'رحله': ['trip', 'tour', 'travel'],
    'طيران': ['flying', 'flight', 'air'],
    'تاكسي': ['taxi', 'flying'],
    'ترانزيت': ['transit', 'layover', 'transfer'],
    'خدمه': ['service', 'services'],
    'اماكن': ['place', 'places', 'landmark', 'landmarks'],
    'معالم': ['landmark', 'landmarks', 'sightseeing'],
    'اهرامات': ['pyramids', 'giza'],
    'القاهره': ['cairo'],
    'جيزه': ['giza'],
    'نيل': ['nile', 'cruise'],
    'متحف': ['museum'],
  };

  String _normalizeSearchText(String text) {
    var value = text.toLowerCase();

    // Normalize common Arabic letter variants for more forgiving matching.
    const replacements = {
      'أ': 'ا',
      'إ': 'ا',
      'آ': 'ا',
      'ى': 'ي',
      'ة': 'ه',
      'ؤ': 'و',
      'ئ': 'ي',
    };
    replacements.forEach((from, to) {
      value = value.replaceAll(from, to);
    });

    // Remove Arabic diacritics and tatweel.
    value = value.replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '');
    value = value.replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF\s]'), ' ');
    value = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    return value;
  }

  Set<String> _variantsForToken(String token) {
    final variants = <String>{token};

    final direct = _searchSynonyms[token];
    if (direct != null) {
      variants.addAll(direct.map(_normalizeSearchText));
    }

    // Also support reverse matching when user writes English and data/tags are Arabic.
    for (final entry in _searchSynonyms.entries) {
      final normalizedValues = entry.value.map(_normalizeSearchText);
      if (normalizedValues.contains(token)) {
        variants.add(entry.key);
        variants.addAll(normalizedValues);
      }
    }

    return variants.where((v) => v.isNotEmpty).toSet();
  }

  List<Set<String>> _buildSearchGroups(String query) {
    final normalizedQuery = _normalizeSearchText(query);
    if (normalizedQuery.isEmpty) return const [];

    final tokens = normalizedQuery
        .split(' ')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    return tokens.map(_variantsForToken).toList();
  }

  List<TripModel> _filterTrips(List<TripModel> trips, String query) {
    final groups = _buildSearchGroups(query);
    if (groups.isEmpty) return trips;

    return trips.where((trip) {
      final searchableParts = <String>[
        trip.name,
        trip.shortDescription,
        trip.description,
        trip.routeLabel,
        if (trip.isFlying) 'flying flight air taxi طيران تاكسي طائر جوي',
        if (trip.isTransit)
          'transit layover transfer bus ترانزيت انتقال مواصلات',
        ...trip.included,
        ...trip.itinerary.map((stop) => '${stop.title} ${stop.subtitle}'),
      ];

      final normalizedSearchable = _normalizeSearchText(
        searchableParts.join(' '),
      );

      return groups.every(
        (tokenVariants) => tokenVariants.any(
          (variant) => normalizedSearchable.contains(variant),
        ),
      );
    }).toList();
  }

  // ═══════════════════════════════════════════════════════════════════
  //  Bottom nav — frosted glass floating pill
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildBottomNav() {
    final items = [
      (Icons.home_rounded, _t('Home', 'الرئيسية'), -1),
      (Icons.flight_rounded, _t('Flying', 'الطيران'), 1),
      (Icons.directions_bus_rounded, _t('Transit', 'الترانزيت'), 2),
      (Icons.calendar_today_rounded, _t('Bookings', 'الحجوزات'), 3),
      (Icons.smart_toy_rounded, _t('AI Chat', 'محادثة AI'), 4),
      (Icons.person_outline_rounded, _t('Profile', 'البروفايل'), 5),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (i) {
              final active = i == _navIndex;
              final icon = items[i].$1;
              final label = items[i].$2;
              return _NavItem(
                icon: icon,
                label: label,
                active: active,
                showLabel: true,
                onTap: () => _switchTab(i),
              );
            }),
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
  final bool showLabel;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.showLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: active ? kBlue : Colors.grey.shade400),
          const SizedBox(height: 4),
          Text(
            label,
            style: roboto(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: active ? kBlue : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

FlyingTaxiTrip _asFlyingTaxiTrip(TripModel trip) {
  final durationMinutes = trip.durationMinutes > 0 ? trip.durationMinutes : 45;
  final flightMinutes = trip.flightMinutes > 0
      ? trip.flightMinutes
      : (durationMinutes / 3).round().clamp(10, 40);

  return FlyingTaxiTrip(
    id: trip.id,
    name: trip.name,
    durationMinutes: durationMinutes,
    flightMinutes: flightMinutes,
    priceUsd: trip.priceUsd.toInt(),
    description: trip.description.isNotEmpty
        ? trip.description
        : trip.shortDescription,
    mapHint: trip.mapHint.isNotEmpty ? trip.mapHint : trip.routeLabel,
    cardColor: trip.accentColor,
    icon: Icons.flight_rounded,
    imageUrl: trip.imageUrl,
  );
}

TransitTrip _asTransitTrip(TripModel trip) {
  final durationHoursExact = trip.durationMinutes > 0
      ? trip.durationMinutes / 60.0
      : 2.0;
  final itinerary = trip.itinerary
      .map(
        (s) => TransitStop(
          title: s.title,
          subtitle: s.subtitle,
          duration: s.duration,
          icon: s.icon,
          color: s.color,
          imageUrl: s.imageUrl,
        ),
      )
      .toList();

  return TransitTrip(
    id: trip.id,
    name: trip.name,
    shortDescription: trip.shortDescription.isNotEmpty
        ? trip.shortDescription
        : trip.description,
    durationHours: durationHoursExact.ceil(),
    durationHoursExact: durationHoursExact,
    priceUsd: trip.priceUsd.toInt(),
    imageUrl: trip.imageUrl,
    accentColor: trip.accentColor,
    routeLabel: trip.routeLabel,
    itinerary: itinerary,
    included: trip.included,
  );
}

void _openTripDetail(BuildContext context, TripModel trip) {
  if (trip.isFlying) {
    final flyingTrip = _asFlyingTaxiTrip(trip);
    SmoothNavigation.slideRight(
      context,
      (context) => TripDetailPage(trip: flyingTrip),
      routeName: 'trip_detail_flying',
      duration: const Duration(milliseconds: 450),
    );
  } else {
    final transitTrip = _asTransitTrip(trip);
    SmoothNavigation.slideRight(
      context,
      (context) => TransitTripDetailPage(trip: transitTrip),
      routeName: 'trip_detail_transit',
      duration: const Duration(milliseconds: 450),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
//  Trip card widget
// ═════════════════════════════════════════════════════════════════════════════
class _TripCard extends StatelessWidget {
  final TripModel trip;
  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openTripDetail(context, trip),
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
                  TripImage(
                    imageUrl: trip.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_) => Container(
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
                    placeholderBuilder: (_) => Container(
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
                          UiTranslation.display(context, trip.name),
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
                                UiTranslation.display(
                                  context,
                                  trip.locationLabel,
                                ),
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
                                        SnackBar(
                                          content: Text(
                                            'Error: $e',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          backgroundColor: const Color(
                                            0xFFEF4444,
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
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
