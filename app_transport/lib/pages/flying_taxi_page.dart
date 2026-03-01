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

// ── 10 Cairo Day Trips (within Cairo – max 5 hours) ─────────────────────────
const _flyingTrips = <FlyingTaxiTrip>[
  // 1 ─ أهرامات الجيزة وأبو الهول
  FlyingTaxiTrip(
    name: 'أهرامات الجيزة وأبو الهول',
    durationHours: 3,
    priceUsd: 85,
    description:
        'رحلة من مطار القاهرة إلى هضبة الأهرامات لمشاهدة الهرم الأكبر خوفو وهرم خفرع ومنقرع وتمثال أبو الهول، مع جولة تصوير بانورامية من المنطقة البانورامية، ثم العودة إلى المطار.',
    mapHint: 'مطار القاهرة → هضبة الأهرامات → أبو الهول → المنطقة البانورامية → المطار',
    cardColor: Color(0xFFD4A843),
    icon: Icons.landscape_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1568322445389-f64ac2515020?w=800&q=80',
    reviews: [
      Review(
        name: 'أحمد محمد',
        rating: 5,
        date: 'من يومين',
        comment: 'رحلة رائعة جداً! الأهرامات كانت مهيبة والمرشد شرح كل حاجة.',
      ),
      Review(
        name: 'Sara Ali',
        rating: 4,
        date: 'من أسبوع',
        comment: 'أبو الهول كان مذهل! بس الشمس كانت حارة شوية.',
      ),
      Review(
        name: 'John Smith',
        rating: 5,
        date: 'من أسبوعين',
        comment: 'Absolutely stunning! The pyramids are even more impressive in person.',
      ),
      Review(
        name: 'فاطمة حسن',
        rating: 5,
        date: 'من ٣ أسابيع',
        comment: 'المنطقة البانورامية كانت أحلى حاجة، صورنا صور جميلة جداً.',
      ),
    ],
  ),

  // 2 ─ المتحف المصري الكبير (GEM)
  FlyingTaxiTrip(
    name: 'المتحف المصري الكبير',
    durationHours: 3,
    priceUsd: 70,
    description:
        'زيارة المتحف المصري الكبير بالرماية، أكبر متحف أثري في العالم، لمشاهدة كنوز توت عنخ آمون والمومياوات الملكية والتماثيل العملاقة لرمسيس الثاني، مع جولة إرشادية متكاملة.',
    mapHint: 'مطار القاهرة → المتحف المصري الكبير → قاعة توت عنخ آمون → المطار',
    cardColor: Color(0xFFB8860B),
    icon: Icons.museum_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1646921305696-8448b037c33a?w=800&q=80',
    reviews: [
      Review(
        name: 'محمد كريم',
        rating: 5,
        date: 'من ٣ أيام',
        comment: 'المتحف تحفة معمارية! كنوز توت عنخ آمون لا مثيل لها.',
      ),
      Review(
        name: 'Emily Brown',
        rating: 5,
        date: 'من ٥ أيام',
        comment: 'The GEM is world-class! Tutankhamun gallery is breathtaking.',
      ),
      Review(
        name: 'نادية عبدالله',
        rating: 4,
        date: 'من أسبوع',
        comment: 'مكان رائع لكن محتاج وقت أكتر عشان تشوف كل حاجة.',
      ),
    ],
  ),

  // 3 ─ برج القاهرة وجزيرة الزمالك
  FlyingTaxiTrip(
    name: 'برج القاهرة والزمالك',
    durationHours: 2,
    priceUsd: 45,
    description:
        'الصعود إلى قمة برج القاهرة (١٨٧ متر) للاستمتاع بمنظر بانورامي ٣٦٠ درجة للقاهرة بأكملها، ثم التجول في شوارع الزمالك الراقية وزيارة متحف الخزف الإسلامي وتناول قهوة في أحد الكافيهات.',
    mapHint: 'مطار القاهرة → برج القاهرة → شوارع الزمالك → كافيه → المطار',
    cardColor: Color(0xFF4A44AA),
    icon: Icons.cell_tower_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1724921910233-002751d0d861?w=800&q=80',
    reviews: [
      Review(
        name: 'ليلى إبراهيم',
        rating: 5,
        date: 'من يوم',
        comment: 'المنظر من فوق البرج خرافي! شوفت القاهرة كلها من فوق.',
      ),
      Review(
        name: 'Thomas Brown',
        rating: 5,
        date: 'من ٣ أيام',
        comment: 'Amazing 360° view of Cairo! Zamalek streets are charming.',
      ),
      Review(
        name: 'سارة عمر',
        rating: 4,
        date: 'من أسبوع',
        comment: 'الزمالك منطقة جميلة جداً والكافيهات فيها مستوى عالي.',
      ),
    ],
  ),

  // 4 ─ خان الخليلي والحسين
  FlyingTaxiTrip(
    name: 'خان الخليلي والحسين',
    durationHours: 3,
    priceUsd: 40,
    description:
        'جولة في أشهر سوق تاريخي في القاهرة، خان الخليلي، للتسوق وشراء الهدايا التذكارية والمشغولات اليدوية، ثم زيارة مسجد الحسين وشارع المعز لدين الله الفاطمي والاستمتاع بالمشروبات في مقهى الفيشاوي التاريخي.',
    mapHint: 'مطار القاهرة → خان الخليلي → مسجد الحسين → شارع المعز → المطار',
    cardColor: Color(0xFFE87832),
    icon: Icons.store_mall_directory_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1710211288826-b7df3ab71588?w=800&q=80',
    reviews: [
      Review(
        name: 'حسن السيد',
        rating: 5,
        date: 'من يومين',
        comment: 'خان الخليلي سوق مذهل! اشتريت هدايا جميلة بأسعار حلوة.',
      ),
      Review(
        name: 'Sophie Laurent',
        rating: 5,
        date: 'من ٣ أيام',
        comment: 'The atmosphere is magical! Love the traditional crafts and El Fishawy café.',
      ),
      Review(
        name: 'زينب أحمد',
        rating: 4,
        date: 'من أسبوع',
        comment: 'شارع المعز بالليل كان مختلف تماماً! الإضاءة والعمارة الإسلامية روعة.',
      ),
      Review(
        name: 'Marco Rossi',
        rating: 5,
        date: 'من أسبوعين',
        comment: 'Best bazaar experience! The old Cairo vibes are priceless.',
      ),
    ],
  ),

  // 5 ─ قلعة صلاح الدين ومسجد محمد علي
  FlyingTaxiTrip(
    name: 'قلعة صلاح الدين',
    durationHours: 3,
    priceUsd: 50,
    description:
        'زيارة قلعة صلاح الدين الأيوبي، أحد أهم معالم القاهرة الإسلامية، ومسجد محمد علي باشا (مسجد المرمر) ذو القباب الفضية، والاستمتاع بإطلالة بانورامية على القاهرة من أعلى القلعة، مع زيارة متحف الشرطة ومتحف المركبات.',
    mapHint: 'مطار القاهرة → قلعة صلاح الدين → مسجد محمد علي → المتاحف → المطار',
    cardColor: Color(0xFF8B4513),
    icon: Icons.castle_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1639332127279-fb933aa20fdc?w=800&q=80',
    reviews: [
      Review(
        name: 'أميرة حسان',
        rating: 5,
        date: 'من يوم',
        comment: 'مسجد محمد علي من جوه تحفة! والمنظر من القلعة لا يوصف.',
      ),
      Review(
        name: 'David Chen',
        rating: 5,
        date: 'من أسبوع',
        comment: 'The Alabaster Mosque is incredible! Best panoramic view of Cairo.',
      ),
      Review(
        name: 'يوسف خليل',
        rating: 4,
        date: 'من أسبوعين',
        comment: 'القلعة مكان تاريخي عظيم. محتاج حذاء مريح عشان المشي كتير.',
      ),
    ],
  ),

  // 6 ─ حديقة الأزهر
  FlyingTaxiTrip(
    name: 'حديقة الأزهر',
    durationHours: 2,
    priceUsd: 35,
    description:
        'الاسترخاء في حديقة الأزهر، واحدة من أجمل حدائق القاهرة، المصممة على الطراز الإسلامي مع النوافير والمسطحات الخضراء، والاستمتاع بإطلالة على القاهرة القديمة وقلعة صلاح الدين، مع تناول الطعام في مطعم الحديقة.',
    mapHint: 'مطار القاهرة → حديقة الأزهر → المطعم البانورامي → المطار',
    cardColor: Color(0xFF2E8B57),
    icon: Icons.park_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1693273647745-10f31ae894bf?w=800&q=80',
    reviews: [
      Review(
        name: 'دينا منصور',
        rating: 5,
        date: 'من يومين',
        comment: 'حديقة الأزهر من أجمل أماكن القاهرة! هادية ومنظمة جداً.',
      ),
      Review(
        name: 'Peter Anderson',
        rating: 4,
        date: 'من ٥ أيام',
        comment: 'Beautiful Islamic garden design. The view of old Cairo is stunning.',
      ),
      Review(
        name: 'مها راجح',
        rating: 5,
        date: 'من أسبوع',
        comment: 'مكان مثالي للعائلات. الأطفال استمتعوا جداً والمطعم أكله لذيذ.',
      ),
    ],
  ),

  // 7 ─ القاهرة القبطية (مصر القديمة)
  FlyingTaxiTrip(
    name: 'القاهرة القبطية',
    durationHours: 3,
    priceUsd: 45,
    description:
        'جولة في منطقة مصر القديمة، زيارة الكنيسة المعلقة (أقدم كنيسة في مصر)، كنيسة أبو سرجة، المعبد اليهودي (معبد بن عزرا)، والمتحف القبطي، والتعرف على تاريخ المسيحية في مصر في أجواء روحانية فريدة.',
    mapHint: 'مطار القاهرة → الكنيسة المعلقة → المتحف القبطي → أبو سرجة → المطار',
    cardColor: Color(0xFF800020),
    icon: Icons.church_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1680053550482-1c47dc7d97ea?w=800&q=80',
    reviews: [
      Review(
        name: 'سميرة فخري',
        rating: 5,
        date: 'من يومين',
        comment: 'الكنيسة المعلقة مكان روحاني جداً! والمتحف القبطي فيه كنوز.',
      ),
      Review(
        name: 'Jessica Taylor',
        rating: 5,
        date: 'من ٣ أيام',
        comment: 'A deeply spiritual place. The Hanging Church architecture is unique.',
      ),
      Review(
        name: 'عمر حسان',
        rating: 4,
        date: 'من أسبوع',
        comment: 'منطقة تاريخية جميلة. كل مبنى فيها ليه قصة مختلفة.',
      ),
    ],
  ),

  // 8 ─ قصر البارون إمبان (هليوبوليس)
  FlyingTaxiTrip(
    name: 'قصر البارون إمبان',
    durationHours: 2,
    priceUsd: 40,
    description:
        'زيارة قصر البارون إمبان في مصر الجديدة (أقرب معلم لمطار القاهرة)، القصر المبني على الطراز الهندي والأوروبي، مع جولة في القاعات المرممة والحدائق، ثم التجول في شوارع هليوبوليس التاريخية وكوربا.',
    mapHint: 'مطار القاهرة → قصر البارون → شوارع هليوبوليس → كوربا → المطار',
    cardColor: Color(0xFF6A0DAD),
    icon: Icons.villa_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1678729991067-d20cca194056?w=800&q=80',
    reviews: [
      Review(
        name: 'نور شوقي',
        rating: 5,
        date: 'من يومين',
        comment: 'قصر البارون بعد الترميم بقى تحفة! قريب جداً من المطار.',
      ),
      Review(
        name: 'Patricia Garcia',
        rating: 5,
        date: 'من ٥ أيام',
        comment: 'The palace is gorgeous! Indian-style architecture in the heart of Cairo.',
      ),
      Review(
        name: 'تامر نبيل',
        rating: 4,
        date: 'من أسبوع',
        comment: 'مكان قريب من المطار ومثالي لو عندك وقت قصير. الترميم اتعمل باحتراف.',
      ),
    ],
  ),

  // 9 ─ كورنيش النيل ورحلة نيلية
  FlyingTaxiTrip(
    name: 'رحلة نيلية وكورنيش النيل',
    durationHours: 4,
    priceUsd: 70,
    description:
        'رحلة مسائية على النيل في مركب نيلي فاخر، الاستمتاع بعشاء مع موسيقى حية وعرض تنورة، مشاهدة أضواء القاهرة الليلية من على النيل، والتجول على كورنيش النيل في المعادي وجاردن سيتي.',
    mapHint: 'مطار القاهرة → كورنيش النيل → مركب نيلي → عشاء وموسيقى → المطار',
    cardColor: Color(0xFF1A1A40),
    icon: Icons.directions_boat_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1761351108323-dc01e88a01aa?w=800&q=80',
    reviews: [
      Review(
        name: 'ياسمين سليمان',
        rating: 5,
        date: 'من ٣ أيام',
        comment: 'الرحلة النيلية بالليل كانت سحرية! الأكل كان لذيذ والموسيقى حلوة.',
      ),
      Review(
        name: 'Michael Schmidt',
        rating: 5,
        date: 'من أسبوع',
        comment: 'Cairo at night from the Nile is magical! Great dinner and live music.',
      ),
      Review(
        name: 'سلمى شاكر',
        rating: 5,
        date: 'من أسبوعين',
        comment: 'أحلى عشاء رومانسي على النيل! التنورة كانت عرض ممتع جداً.',
      ),
    ],
  ),

  // 10 ─ المتحف القومي للحضارة المصرية
  FlyingTaxiTrip(
    name: 'متحف الحضارة المصرية',
    durationHours: 3,
    priceUsd: 55,
    description:
        'زيارة المتحف القومي للحضارة المصرية في الفسطاط، لمشاهدة قاعة المومياوات الملكية (٢٢ مومياء ملكية)، وقاعة النسيج المصري، والقاعة الرئيسية التي تروي تاريخ الحضارة المصرية من عصور ما قبل التاريخ حتى العصر الحديث.',
    mapHint: 'مطار القاهرة → متحف الحضارة → قاعة المومياوات → الفسطاط → المطار',
    cardColor: Color(0xFF187BCD),
    icon: Icons.account_balance_rounded,
    imageUrl:
        'https://images.unsplash.com/photo-1715430503417-b8c856cff735?w=800&q=80',
    reviews: [
      Review(
        name: 'إبراهيم مصطفى',
        rating: 5,
        date: 'من يوم',
        comment: 'قاعة المومياوات الملكية مهيبة! شوفت رمسيس التاني بنفسي.',
      ),
      Review(
        name: 'Lisa Johnson',
        rating: 5,
        date: 'من ٣ أيام',
        comment: 'The Royal Mummies Hall is absolutely incredible! A must-visit.',
      ),
      Review(
        name: 'خالد سعيد',
        rating: 4,
        date: 'من أسبوع',
        comment: 'متحف رائع ومنظم جداً. محتاج وقت كافي عشان تستمتع بكل قاعة.',
      ),
      Review(
        name: 'ريهام نصار',
        rating: 5,
        date: 'من أسبوعين',
        comment: 'أفضل متحف زرته في حياتي! التصميم المعماري نفسه تحفة.',
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
    final mq = MediaQuery.of(context);
    final topPad = mq.padding.top;
    final w = mq.size.width;
    final h = mq.size.height;

    // ── Responsive values tuned for Samsung M31 (411×891 lp) ──
    final hPad = (w * 0.053).clamp(16.0, 28.0);       // ~22 on M31
    final gridSpacing = (w * 0.039).clamp(12.0, 20.0); // ~16 on M31
    final gridMainSpacing = (w * 0.044).clamp(14.0, 22.0); // ~18
    // Taller cards on narrow/tall phones → better for Arabic text
    final aspectRatio = (w / h) < 0.48 ? 0.64 : 0.72;
    final titleFs = (w * 0.053).clamp(18.0, 24.0);     // ~22
    final subtitleFs = (w * 0.031).clamp(11.0, 14.0);   // ~13

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
                  padding: EdgeInsets.fromLTRB(hPad, topPad + 14, hPad, 0),
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
                            fontSize: titleFs,
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
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Text(
                    'رحلات داخل القاهرة – الانطلاق والعودة لمطار القاهرة الدولي',
                    style: roboto(fontSize: subtitleFs, color: Colors.grey.shade500),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ── Grid ─────────────────────────────────────────────────
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: gridMainSpacing,
                    crossAxisSpacing: gridSpacing,
                    childAspectRatio: aspectRatio,
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
    final w = MediaQuery.of(context).size.width;
    // ── Responsive card values for Samsung M31 (~411 lp) ──
    final nameFs = (w * 0.030).clamp(11.0, 15.0);      // ~12.3
    final subFs = (w * 0.024).clamp(9.0, 12.0);        // ~10
    final priceFs = (w * 0.030).clamp(11.0, 15.0);     // ~12.3
    final ratingFs = (w * 0.026).clamp(9.0, 13.0);     // ~10.7
    final cardPadH = (w * 0.028).clamp(8.0, 14.0);     // ~11.5
    final cardPadV = (w * 0.022).clamp(6.0, 12.0);     // ~9
    final cardRadius = (w * 0.048).clamp(14.0, 24.0);  // ~20

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(cardRadius),
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
                  // duration badge
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule_rounded, size: 11, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            trip.durationLabel,
                            style: roboto(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ],
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
                padding: EdgeInsets.symmetric(
                  horizontal: cardPadH,
                  vertical: cardPadV,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      trip.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: roboto(fontSize: nameFs, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.flight_takeoff_rounded,
                          size: 11,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            'مطار القاهرة الدولي',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: roboto(
                              fontSize: subFs,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Bottom row: price + rating
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money_rounded,
                          size: 13,
                          color: kBlue,
                        ),
                        Text(
                          trip.priceLabel,
                          style: roboto(
                            fontSize: priceFs,
                            fontWeight: FontWeight.w800,
                            color: kBlue,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: Color(0xFFFFC107),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '4.${trip.durationHours % 5 + 4}',
                          style: roboto(
                            fontSize: ratingFs,
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
