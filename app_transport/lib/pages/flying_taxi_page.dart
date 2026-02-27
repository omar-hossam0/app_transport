import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_widgets.dart';
import 'trip_detail_page.dart';

// ── Brand colours ────────────────────────────────────────────────────────────
const _kDarkBlue = Color(0xFF4A44AA);
const _kRed = Color(0xFFE02850);

// ── Review model ─────────────────────────────────────────────────────────────
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

// ── Trip model ───────────────────────────────────────────────────────────────
class FlyingTaxiTrip {
  final String name;
  final int durationHours;
  final int priceUsd;
  final String description;
  final String mapHint;
  final Color cardColor;
  final IconData icon;
  final String imageUrl;
  final List<Review> reviews;

  const FlyingTaxiTrip({
    required this.name,
    required this.durationHours,
    required this.priceUsd,
    required this.description,
    required this.mapHint,
    required this.cardColor,
    required this.icon,
    required this.imageUrl,
    this.reviews = const [],
  });

  String get durationLabel => '$durationHours hours';
  String get priceLabel => '\$$priceUsd';
}

// ── 10 Egyptian Day Trips ───────────────────────────────────────────────────
const _flyingTrips = <FlyingTaxiTrip>[
  FlyingTaxiTrip(
    name: 'Giza Pyramids & Museum',
    durationHours: 8,
    priceUsd: 90,
    description:
        'يتجه المسافر إلى منطقة أهرامات الجيزة لزيارة هضبة الأهرامات وأبو الهول والتجول داخل المنطقة وقضاء نحو ثلاث ساعات، ثم الانتقال إلى المتحف القومي للحضارة المصرية للتعرف على تاريخ الحضارة المصرية ومشاهدة قاعة المومياوات الملكية وقضاء نحو ساعة و نصف، يلي ذلك التوجه إلى كورنيش النيل في الفسطاط للاستمتاع بالمشهد العام وتناول وجبة خفيفة قبل العودة إلى مطار القاهرة الدولي.',
    mapHint: 'Airport → Giza Pyramids → NMEC Museum → Nile Corniche → Airport',
    cardColor: Color(0xFFD4A843),
    icon: Icons.landscape_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?w=800&q=80',
    reviews: [
      Review(
        name: 'Ahmed Mohamed',
        rating: 5,
        date: '2 days ago',
        comment: 'رحلة رائعة جداً! المرشد السياحي كان محترف والتنظيم ممتاز.',
      ),
      Review(
        name: 'Sara Ali',
        rating: 4,
        date: '1 week ago',
        comment: 'تجربة جميلة، الأماكن كانت مذهلة لكن الوقت كان ضيق شوية.',
      ),
      Review(
        name: 'John Smith',
        rating: 5,
        date: '2 weeks ago',
        comment:
            'Amazing pyramids! The guide was very knowledgeable. Highly recommended!',
      ),
      Review(
        name: 'Fatima Hassan',
        rating: 5,
        date: '3 weeks ago',
        comment:
            'تجربة لا تُنسى! المتحف القومي كان مذهل والمرشد شرح كل شيء بالتفصيل.',
      ),
    ],
  ),
  FlyingTaxiTrip(
    name: 'Alexandria Mediterranean Tour',
    durationHours: 12,
    priceUsd: 120,
    description:
        'رحلة إلى عروس البحر المتوسط، زيارة مكتبة الإسكندرية الحديثة، قلعة قايتباي على البحر، المسرح الروماني، حدائق المنتزه، والاستمتاع بالكورنيش وتناول المأكولات البحرية الطازجة في أحد المطاعم المطلة على البحر.',
    mapHint:
        'Cairo → Alexandria Library → Citadel → Roman Theater → Montaza → Cairo',
    cardColor: Color(0xFF187BCD),
    icon: Icons.water_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1572252009286-268acec5ca0a?w=800&q=80',
    reviews: [
      Review(
        name: 'Mohamed Karim',
        rating: 5,
        date: '3 days ago',
        comment: 'مدينة جميلة جداً والمكتبة رائعة. الطعم السمك طازجة وشهية!',
      ),
      Review(
        name: 'Lisa Johnson',
        rating: 4,
        date: '5 days ago',
        comment:
            'Beautiful coastal city. The seafood was excellent. Worth the long drive!',
      ),
      Review(
        name: 'Nadia Patel',
        rating: 5,
        date: '1 week ago',
        comment:
            'The Citadel was breathtaking! Great views of the Mediterranean.',
      ),
    ],
  ),
  FlyingTaxiTrip(
    name: 'Luxor Temples & Valley',
    durationHours: 16,
    priceUsd: 250,
    description:
        'رحلة إلى الأقصر، عاصمة مصر القديمة، زيارة معبد الكرنك ومعبد الأقصر على الضفة الشرقية، ثم العبور إلى البر الغربي لاستكشاف وادي الملوك ومعبد حتشبسوت ومعبد الرامسيوم، مع مرشد سياحي متخصص.',
    mapHint: 'Fly to Luxor → Karnak → Luxor Temple → Valley of Kings → Return',
    cardColor: Color(0xFFE02850),
    icon: Icons.account_balance_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1553913861-c0fddf2619ee?w=800&q=80',
    reviews: [
      Review(
        name: 'Amira Hassan',
        rating: 5,
        date: '4 days ago',
        comment:
            'وادي الملوك مذهل! مشاهدة المومياوات والمعابد تجربة روحانية رائعة.',
      ),
      Review(
        name: 'David Chen',
        rating: 5,
        date: '1 week ago',
        comment:
            'The Valley of Kings is mind-blowing! History comes alive here.',
      ),
      Review(
        name: 'Zainab Ahmed',
        rating: 4,
        date: '2 weeks ago',
        comment:
            'معابد الكرنك كانت مذهلة فعلاً. الرحلة متعبة لكن تستحق كل ثانية.',
      ),
      Review(
        name: 'Marco Rossi',
        rating: 5,
        date: '3 weeks ago',
        comment: 'Simply unforgettable! Best trip of my life!',
      ),
    ],
  ),
  FlyingTaxiTrip(
    name: 'Siwa Oasis Adventure',
    durationHours: 20,
    priceUsd: 280,
    description:
        'مغامرة إلى واحة سيوا في الصحراء الغربية، زيارة معبد آمون، قلعة شالي القديمة، عين كليوباترا للاستحمام في المياه الطبيعية، رحلة سفاري في الكثبان الرملية، والاستمتاع بالهدوء والليالي الصحراوية تحت النجوم.',
    mapHint:
        'Cairo → Siwa Oasis → Shali Fortress → Cleopatra Spring → Desert Safari',
    cardColor: Color(0xFFE87832),
    icon: Icons.wb_sunny_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=800&q=80',
    reviews: [
      Review(
        name: 'Hassan El-Sayed',
        rating: 5,
        date: '1 day ago',
        comment: 'واحة سيوا ساحرة! الليال تحت النجوم لا تنسى أبداً.',
      ),
      Review(
        name: 'Emma Wilson',
        rating: 5,
        date: '2 days ago',
        comment:
            'The starry nights in Siwa are magical! A truly unique experience.',
      ),
      Review(
        name: 'Layla Ibrahim',
        rating: 4,
        date: '5 days ago',
        comment: 'جميل جداً لكن الطريق طويل والرمال عندها حرارة شديدة جداً.',
      ),
    ],
  ),
  FlyingTaxiTrip(
    name: 'Aswan & Abu Simbel',
    durationHours: 18,
    priceUsd: 300,
    description:
        'رحلة إلى أسوان والنوبة، زيارة معابد أبو سمبل المهيبة لرمسيس الثاني ونفرتاري، السد العالي، معبد فيلة على جزيرة أجيليكا، المسلة الناقصة، والاستمتاع بجولة بالفلوكة على نهر النيل عند غروب الشمس.',
    mapHint:
        'Fly to Aswan → Abu Simbel → High Dam → Philae Temple → Felucca Ride',
    cardColor: Color(0xFF4A44AA),
    icon: Icons.temple_buddhist_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1503177119275-0aa32b3a9368?w=800&q=80',
    reviews: [
      Review(
        name: 'Samira Fakhri',
        rating: 5,
        date: '2 days ago',
        comment: 'معابد أبو سمبل روعة! والفلوكة جولة رومانسية جداً عند الغروب.',
      ),
      Review(
        name: 'Thomas Brown',
        rating: 5,
        date: '1 week ago',
        comment: 'Abu Simbel is awe-inspiring! The felucca ride was perfect.',
      ),
      Review(
        name: 'Youssef Khalil',
        rating: 5,
        date: '2 weeks ago',
        comment: 'رحلة الفلوكة على النيل عند الغروب كانت أجمل جزء!',
      ),
    ],
  ),
  FlyingTaxiTrip(
    name: 'Red Sea Hurghada Diving',
    durationHours: 10,
    priceUsd: 150,
    description:
        'رحلة إلى البحر الأحمر للغوص والسنوركل، استكشاف الشعاب المرجانية الملونة والأسماك الاستوائية، رحلة بالقارب إلى جزيرة جفتون، الاسترخاء على الشواطئ الرملية البيضاء، وتناول غداء المأكولات البحرية.',
    mapHint: 'Cairo → Hurghada → Giftun Island → Diving Sites → Beach Resort',
    cardColor: Color(0xFF5BC0EB),
    icon: Icons.pool_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800&q=80',
    reviews: [
      Review(
        name: 'Riham Nassar',
        rating: 5,
        date: '1 day ago',
        comment:
            'الشعب المرجانية ملونة للغاية والأسماك رائعة. الشاطئ نظيف جداً.',
      ),
      Review(
        name: 'Sophie Laurent',
        rating: 5,
        date: '3 days ago',
        comment:
            'Best snorkeling experience ever! Crystal clear waters and amazing marine life.',
      ),
      Review(
        name: 'Khalid Saeed',
        rating: 4,
        date: '1 week ago',
        comment: 'Diving في البحر الأحمر لا يقارن بأي مكان آخر!',
      ),
    ],
  ),
  FlyingTaxiTrip(
    name: 'Fayoum Wadi El Rayan',
    durationHours: 7,
    priceUsd: 75,
    description:
        'رحلة قريبة إلى الفيوم، زيارة محمية وادي الريان وشلالاتها الطبيعية، بحيرة قارون، وادي الحيتان (موقع تراث عالمي)، قرية تونس الفنية، والاستمتاع بالمناظر الطبيعية الخلابة وركوب الخيل.',
    mapHint:
        'Cairo → Wadi El Rayan → Lake Qarun → Wadi El Hitan → Tunis Village',
    cardColor: Color(0xFF0D7377),
    icon: Icons.water_drop_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1548919973-5cef591cdbc9?w=800&q=80',
    reviews: [
      Review(
        name: 'Dina Mansour',
        rating: 5,
        date: '2 days ago',
        comment:
            'الشلالات جميلة جداً وقرية تونس كانت رومانسية! رحلة قصيرة لكن ممتعة.',
      ),
      Review(
        name: 'Peter Anderson',
        rating: 4,
        date: '5 days ago',
        comment:
            'Nice waterfalls and beautiful scenery. Wadi El Hitan fossils are fascinating!',
      ),
      Review(
        name: 'Maha Rageh',
        rating: 5,
        date: '1 week ago',
        comment: 'ركوب الخيل في الفيوم تجربة لا تنسى!',
      ),
    ],
  ),
  FlyingTaxiTrip(
    name: 'Dahab Sinai Mountains',
    durationHours: 14,
    priceUsd: 180,
    description:
        'رحلة إلى دهب في سيناء، تسلق جبل موسى لمشاهدة شروق الشمس، زيارة دير سانت كاترين (أقدم دير في العالم)، الغطس في البلو هول، الاسترخاء على شواطئ دهب الهادئة، وتجربة الثقافة البدوية.',
    mapHint: 'Cairo → Dahab → Mount Sinai → St. Catherine → Blue Hole → Beach',
    cardColor: Color(0xFF8B6F47),
    icon: Icons.terrain_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1591604129853-b71f29e3b39e?w=800&q=80',
    reviews: [
      Review(
        name: 'Ibrahim Moustafa',
        rating: 5,
        date: '1 day ago',
        comment: 'شروق الشمس من جبل موسى روعة! والبلو هول غطس مذهل.',
      ),
      Review(
        name: 'Jessica Taylor',
        rating: 5,
        date: '3 days ago',
        comment:
            'Mount Sinai sunrise is absolutely breathtaking. The Blue Hole diving is world-class!',
      ),
      Review(
        name: 'Omar Hassan',
        rating: 4,
        date: '1 week ago',
        comment: 'دير سانت كاترين كان مؤثر جداً. رحلة روحانية وجسدية معاً.',
      ),
    ],
  ),
  FlyingTaxiTrip(
    name: 'White Desert Safari',
    durationHours: 15,
    priceUsd: 200,
    description:
        'مغامرة فريدة إلى الصحراء البيضاء بتشكيلاتها الطباشيرية المذهلة، المرور بالصحراء السوداء والتلال البركانية، زيارة وادي الأجبان، مبيت في الصحراء تحت النجوم، وتجربة الطعام البدوي التقليدي.',
    mapHint: 'Cairo → Bahariya Oasis → Black Desert → White Desert → Camping',
    cardColor: Color(0xFF1A1A40),
    icon: Icons.nights_stay_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=800&q=80',
    reviews: [
      Review(
        name: 'Yasmin Soliman',
        rating: 5,
        date: '3 days ago',
        comment:
            'الصحراء البيضاء مثل كوكب آخر! التشكيلات الصخرية مذهلة والمخيم جميل.',
      ),
      Review(
        name: 'Michael Schmidt',
        rating: 5,
        date: '1 week ago',
        comment:
            'Otherworldly landscapes in the White Desert. Camping under the stars is unforgettable!',
      ),
      Review(
        name: 'Salma Shaker',
        rating: 5,
        date: '2 weeks ago',
        comment: 'رحلة ستجعلك تشعر أنك على المريخ! جمال مختلف تماماً.',
      ),
    ],
  ),
  FlyingTaxiTrip(
    name: 'Sharm El Sheikh Beach',
    durationHours: 9,
    priceUsd: 140,
    description:
        'رحلة استجمام إلى شرم الشيخ، الغطس في خليج نعمة وجزيرة تيران، زيارة محمية رأس محمد الطبيعية، التسوق في السوق القديم، الاستمتاع بالمنتجعات السياحية الفاخرة والشواطئ الذهبية.',
    mapHint: 'Cairo → Sharm → Naama Bay → Ras Mohammed → Tiran Island → Resort',
    cardColor: Color(0xFF1C1C3B),
    icon: Icons.beach_access_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1523482580674-f109c8b2107e?w=800&q=80',
    reviews: [
      Review(
        name: 'Noor Shawky',
        rating: 5,
        date: '2 days ago',
        comment: 'شرم الشيخ روعة! الشواطئ نظيفة والمياه صافية والسوق جميل!',
      ),
      Review(
        name: 'Patricia Garcia',
        rating: 5,
        date: '5 days ago',
        comment:
            'Luxurious resorts and golden beaches. Perfect for relaxation and diving!',
      ),
      Review(
        name: 'Tamer Nabil',
        rating: 4,
        date: '1 week ago',
        comment:
            'رحلة ممتازة للعائلة. الأطفال استمتعوا على الشواطئ والكبار في الغوص!',
      ),
    ],
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
          color: const Color(0xFFE8F4F8),
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
                            color: Colors.white.withValues(alpha: 0.95),
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
          color: Colors.white.withValues(alpha: 0.92),
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
                          '4.${trip.durationHours % 7 + 2}',
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
