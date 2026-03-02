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
  final int durationMinutes;
  final int flightMinutes;
  final int priceUsd;
  final String description;
  final String mapHint;
  final Color cardColor;
  final IconData icon;
  final String imageUrl;
  final List<Review> reviews;

  const FlyingTaxiTrip({
    required this.name,
    required this.durationMinutes,
    required this.flightMinutes,
    required this.priceUsd,
    required this.description,
    required this.mapHint,
    required this.cardColor,
    required this.icon,
    required this.imageUrl,
    this.reviews = const [],
  });

  String get durationLabel {
    if (durationMinutes >= 120) {
      final h = durationMinutes ~/ 60;
      final m = durationMinutes % 60;
      return m == 0 ? '${h}h' : '${h}h ${m}m';
    }
    return '${durationMinutes} min';
  }

  String get flightLabel => '$flightMinutes min flight';
  String get priceLabel => '\$$priceUsd';
}

// ── 8 Flying Taxi Panoramic Trips from Cairo Airport ────────────────────────
const flyingTrips = <FlyingTaxiTrip>[
  // 1 ─ جولة جوية فوق القلعة والنيل (15 دقيقة طيران)
  FlyingTaxiTrip(
    name: 'جولة جوية فوق القلعة والنيل',
    durationMinutes: 70,
    flightMinutes: 15,
    priceUsd: 120,
    description:
        'يتم استقبال العميل داخل المطار ثم الانتقال إلى نقطة الإقلاع. تنطلق الطائرة في جولة جوية بانورامية فوق القلعة الإسلامية بالقاهرة ومشاهدة القلاع والمساجد القديمة من الأعلى، ثم نهر النيل ومناطق كورنيش القاهرة. بعد ذلك يتم الهبوط والعودة إلى منطقة الاستقبال.',
    mapHint:
        'مطار القاهرة → نقطة الإقلاع → القلعة الإسلامية → نهر النيل → كورنيش القاهرة → الهبوط → المطار',
    cardColor: Color(0xFF8B4513),
    icon: Icons.fort_rounded,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Cairo_Citadel_DSCF3411.jpg/1280px-Cairo_Citadel_DSCF3411.jpg',
    reviews: [
      Review(
        name: 'أحمد محمد',
        rating: 5,
        date: 'من يومين',
        comment: 'منظر القلعة من الجو مذهل! تجربة لا تتكرر.',
      ),
      Review(
        name: 'Sarah Johnson',
        rating: 5,
        date: 'من أسبوع',
        comment: 'Flying over the Citadel and the Nile was breathtaking!',
      ),
      Review(
        name: 'يوسف خالد',
        rating: 4,
        date: 'من أسبوعين',
        comment: 'تجربة ممتازة والطيار كان محترف. النيل من فوق شيء تاني!',
      ),
    ],
  ),

  // 2 ─ جولة جوية قصيرة فوق النيل والكورنيش (13 دقيقة طيران)
  FlyingTaxiTrip(
    name: 'جولة جوية فوق النيل والكورنيش',
    durationMinutes: 40,
    flightMinutes: 13,
    priceUsd: 100,
    description:
        'يتم استقبال العميل داخل مطار القاهرة الدولي ثم الانتقال إلى نقطة الإقلاع داخل نطاق المطار. تنطلق الطائرة في جولة جوية بانورامية قصيرة فوق نهر النيل ومشاهدة كورنيش القاهرة من الأعلى، وأحياء شرق القاهرة والمناطق العمرانية الحديثة، مع لمحة عامة لأفق المدينة والتوسع العمراني. بعد انتهاء الجولة يتم الهبوط والعودة إلى منطقة الاستقبال داخل المطار.',
    mapHint:
        'مطار القاهرة → نقطة الإقلاع → نهر النيل → كورنيش القاهرة → شرق القاهرة → الهبوط → المطار',
    cardColor: Color(0xFF187BCD),
    icon: Icons.water_rounded,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Cairo_Nile_River.jpg/1280px-Cairo_Nile_River.jpg',
    reviews: [
      Review(
        name: 'منى عبدالله',
        rating: 5,
        date: 'من يوم',
        comment: 'جولة سريعة وممتعة! النيل من فوق منظر ساحر.',
      ),
      Review(
        name: 'David Brown',
        rating: 5,
        date: 'من ٣ أيام',
        comment: 'Quick but amazing experience. The Nile view was incredible!',
      ),
      Review(
        name: 'سارة عمر',
        rating: 4,
        date: 'من أسبوع',
        comment: 'مثالية للترانزيت القصير. التجربة كانت أكتر من المتوقع!',
      ),
    ],
  ),

  // 3 ─ جولة جوية شاملة فوق الأهرامات وأبرز المعالم (30 دقيقة طيران)
  FlyingTaxiTrip(
    name: 'جولة شاملة فوق الأهرامات والمعالم',
    durationMinutes: 120,
    flightMinutes: 30,
    priceUsd: 240,
    description:
        'استقبال الركاب داخل صالة الوصول أو الترانزيت في مطار القاهرة الدولي، ثم نقلهم إلى منصة إقلاع التاكسي الطائر داخل نطاق المطار. تنطلق رحلة جوية فوق أبرز معالم القاهرة، وأهرامات الجيزة، وأبو الهول، وبرج القاهرة، وقلعة صلاح الدين. تعود الطائرة للهبوط داخل نطاق المطار ويتم إعادة الركاب إلى صالة السفر.',
    mapHint:
        'مطار القاهرة → أهرامات الجيزة → أبو الهول → برج القاهرة → قلعة صلاح الدين → الهبوط → المطار',
    cardColor: Color(0xFFD4A843),
    icon: Icons.landscape_rounded,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/9/96/Pyramids_of_the_Giza_Necropolis.jpg/1280px-Pyramids_of_the_Giza_Necropolis.jpg',
    reviews: [
      Review(
        name: 'محمد كريم',
        rating: 5,
        date: 'من يومين',
        comment: 'الأهرامات من الجو شيء خيالي! أفضل تجربة في حياتي.',
      ),
      Review(
        name: 'Emily Clark',
        rating: 5,
        date: 'من ٥ أيام',
        comment:
            'Seeing the Pyramids and Sphinx from above was unreal! Worth every dollar.',
      ),
      Review(
        name: 'أحمد سامي',
        rating: 5,
        date: 'من أسبوع',
        comment: 'رحلة شاملة وممتازة. شوفت كل معالم القاهرة في نص ساعة!',
      ),
    ],
  ),

  // 4 ─ جولة جوية سريعة فوق النيل وبرج القاهرة (10 دقائق طيران)
  FlyingTaxiTrip(
    name: 'جولة سريعة فوق النيل وبرج القاهرة',
    durationMinutes: 60,
    flightMinutes: 10,
    priceUsd: 85,
    description:
        'يتم استقبال العميل ثم الانتقال إلى نقطة الإقلاع داخل نطاق المطار، لتنطلق رحلة جوية بانورامية قصيرة فوق مسار يتيح رؤية نهر النيل من الأعلى مع لمحة علوية على الكورنيش والمناطق المحيطة، إضافة إلى إطلالة سريعة على أفق المدينة وبرج القاهرة كمعلم حضري بارز، في تجربة جوية مختصرة وواقعية دون التوقف في أي مواقع خارجية، ثم يتم الهبوط والعودة إلى منطقة الاستقبال داخل المطار.',
    mapHint:
        'مطار القاهرة → نقطة الإقلاع → نهر النيل → الكورنيش → برج القاهرة → الهبوط → المطار',
    cardColor: Color(0xFF4A44AA),
    icon: Icons.cell_tower_rounded,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Cairo_Tower_and_Qasr_El_Nil_Bridge.jpg/1280px-Cairo_Tower_and_Qasr_El_Nil_Bridge.jpg',
    reviews: [
      Review(
        name: 'ليلى إبراهيم',
        rating: 5,
        date: 'من يوم',
        comment: 'جولة سريعة بس مليانة مشاهد! برج القاهرة من فوق منظر مختلف.',
      ),
      Review(
        name: 'Thomas Brown',
        rating: 4,
        date: 'من ٣ أيام',
        comment:
            'Short but sweet! Great for a quick layover. The Nile view was perfect.',
      ),
      Review(
        name: 'فاطمة حسن',
        rating: 5,
        date: 'من أسبوع',
        comment: 'مثالية لأي حد عنده ساعة بس! تجربة مميزة جداً.',
      ),
    ],
  ),

  // 5 ─ جولة بانورامية ممتدة فوق أحياء القاهرة الحديثة (18 دقيقة طيران)
  FlyingTaxiTrip(
    name: 'جولة بانورامية فوق أحياء القاهرة',
    durationMinutes: 75,
    flightMinutes: 18,
    priceUsd: 130,
    description:
        'يتم استقبال العميل داخل مطار القاهرة الدولي، ثم الانتقال إلى نقطة الإقلاع المخصصة داخل نطاق المطار، حيث يتم تقديم نبذة سريعة عن إجراءات السلامة والاستعداد للتجربة. تنطلق الطائرة في جولة جوية بانورامية مميزة تبدأ بالتحليق فوق أحياء شرق القاهرة الحديثة، ثم تتجه نحو مسار جوي يتيح رؤية بانورامية رائعة لنهر النيل من ارتفاع مميز، مع مشهد ساحر لكورنيش القاهرة وانعكاس أشعة الشمس على المياه. تواصل الطائرة مسارها لتمنح الراكب إطلالة فريدة على أفق العاصمة الحديث، بما في ذلك الأبراج الإدارية والمناطق العمرانية الجديدة الممتدة، قبل أن تعود تدريجيًا في مسار دائري يبرز التوسع الحضري الحديث لمدينة القاهرة.',
    mapHint:
        'مطار القاهرة → شرق القاهرة → نهر النيل → الكورنيش → الأبراج الإدارية → المناطق العمرانية → المطار',
    cardColor: Color(0xFF2E8B57),
    icon: Icons.location_city_rounded,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/54/Cairo_skyline%2C_Nile_River%2C_Egypt.jpg/1280px-Cairo_skyline%2C_Nile_River%2C_Egypt.jpg',
    reviews: [
      Review(
        name: 'خالد سعيد',
        rating: 5,
        date: 'من يومين',
        comment: 'التوسع العمراني من الجو منظر مبهر! تجربة استثنائية.',
      ),
      Review(
        name: 'Anna Schmidt',
        rating: 5,
        date: 'من ٥ أيام',
        comment:
            'Beautiful panoramic views of modern Cairo! The Nile reflections were stunning.',
      ),
      Review(
        name: 'حسن السيد',
        rating: 4,
        date: 'من أسبوع',
        comment: 'النيل من ارتفاع عالي منظر مختلف تماماً. تجربة تستاهل!',
      ),
    ],
  ),

  // 6 ─ جولة جوية فوق النيل وبرج القاهرة ودار الأوبرا (22 دقيقة طيران)
  FlyingTaxiTrip(
    name: 'جولة فوق النيل والأوبرا وبرج القاهرة',
    durationMinutes: 100,
    flightMinutes: 22,
    priceUsd: 160,
    description:
        'يتم استقبال العميل داخل المطار ثم الانتقال إلى نقطة الإقلاع داخل نطاق المطار. تبدأ الجولة بالتحليق فوق مسار يتيح رؤية نهر النيل وهو يعبر المدينة، مع إطلالة واضحة على الكورنيش والمناطق المحيطة. بعد ذلك، تظهر من الأعلى إطلالة مميزة على برج القاهرة كمعلم حضري بارز يميز أفق العاصمة. يستمر المسار باتجاه منطقة وسط المدينة حيث يمكن رؤية المبنى التاريخي لدار الأوبرا المصرية من زاوية جوية فريدة، مع مشهد يبرز التوازن بين التراث والفن المعماري الحديث.',
    mapHint:
        'مطار القاهرة → نهر النيل → الكورنيش → برج القاهرة → دار الأوبرا → وسط المدينة → المطار',
    cardColor: Color(0xFF800020),
    icon: Icons.theater_comedy_rounded,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Egyptian_Opera_House.jpg/1280px-Egyptian_Opera_House.jpg',
    reviews: [
      Review(
        name: 'نور شوقي',
        rating: 5,
        date: 'من يوم',
        comment: 'دار الأوبرا من فوق منظر جميل جداً! والنيل كان ساحر.',
      ),
      Review(
        name: 'Jessica Taylor',
        rating: 5,
        date: 'من ٣ أيام',
        comment:
            'The Cairo Tower and Opera House from above were spectacular! Loved this route.',
      ),
      Review(
        name: 'عمر حسان',
        rating: 5,
        date: 'من أسبوع',
        comment: 'أطول جولة أخدتها وكل دقيقة كانت تستاهل!',
      ),
    ],
  ),

  // 7 ─ جولة جوية فوق القاهرة الجديدة والعاصمة الإدارية (25 دقيقة طيران)
  FlyingTaxiTrip(
    name: 'جولة فوق القاهرة الجديدة والعاصمة الإدارية',
    durationMinutes: 90,
    flightMinutes: 25,
    priceUsd: 170,
    description:
        'يتم استقبال العميل داخل المطار ثم الانتقال إلى نقطة الإقلاع. تنطلق الطائرة في جولة جوية بانورامية لمدة 25 دقيقة فوق القاهرة الجديدة، والجامعة الأمريكية بالقاهرة (منظر علوي للحرم الجامعي)، والعاصمة الإدارية الجديدة ومشاهدة المناطق العمرانية الحديثة وخطط التوسع. بعد ذلك يتم الهبوط والعودة لمنطقة الاستقبال.',
    mapHint:
        'مطار القاهرة → القاهرة الجديدة → الجامعة الأمريكية → العاصمة الإدارية → الهبوط → المطار',
    cardColor: Color(0xFF6A0DAD),
    icon: Icons.apartment_rounded,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dc/Central_business_district_1%2C_New_Administrative_Capital.jpg/1280px-Central_business_district_1%2C_New_Administrative_Capital.jpg',
    reviews: [
      Review(
        name: 'تامر نبيل',
        rating: 5,
        date: 'من يومين',
        comment: 'العاصمة الإدارية من فوق منظر مبهر! المباني الحديثة رائعة.',
      ),
      Review(
        name: 'Patricia Garcia',
        rating: 5,
        date: 'من ٥ أيام',
        comment:
            'Amazing to see the New Administrative Capital from above! Truly futuristic.',
      ),
      Review(
        name: 'ياسمين سليمان',
        rating: 4,
        date: 'من أسبوع',
        comment:
            'الجامعة الأمريكية من فوق كانت جميلة والقاهرة الجديدة واسعة جداً!',
      ),
    ],
  ),

  // 8 ─ جولة جوية فوق القاهرة والنيل والمناطق العمرانية (30 دقيقة طيران)
  FlyingTaxiTrip(
    name: 'جولة جوية فوق القاهرة والنيل',
    durationMinutes: 120,
    flightMinutes: 30,
    priceUsd: 220,
    description:
        'ينتقل المستخدم أولًا بالتاكسي لمسافة قصيرة داخل نطاق المطار أو إلى نقطة الإقلاع المخصصة، ثم يستقل رحلة طيران قصيرة مدتها نحو 30 دقيقة فوق مدينة القاهرة، تتيح مشاهدة معالم بارزة مثل النيل والمناطق العمرانية من الجو، دون التوقف في أماكن خارجية. بعد انتهاء الجولة الجوية، يتم الهبوط مرة أخرى في مطار القاهرة الدولي.',
    mapHint:
        'مطار القاهرة → نقطة الإقلاع → نهر النيل → المناطق العمرانية → معالم القاهرة → الهبوط → المطار',
    cardColor: Color(0xFF1A1A40),
    icon: Icons.flight_rounded,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Cairo_Tower_and_Qasr_El_Nil_Bridge.jpg/1280px-Cairo_Tower_and_Qasr_El_Nil_Bridge.jpg',
    reviews: [
      Review(
        name: 'إبراهيم مصطفى',
        rating: 5,
        date: 'من يوم',
        comment:
            'رحلة ممتازة وطويلة كفاية تشوف كل حاجة! القاهرة من فوق مختلفة.',
      ),
      Review(
        name: 'Michael Schmidt',
        rating: 5,
        date: 'من أسبوع',
        comment:
            'Great 30-minute flight over Cairo! Perfect for a 2-hour layover.',
      ),
      Review(
        name: 'ريهام نصار',
        rating: 5,
        date: 'من أسبوعين',
        comment: 'تجربة لا مثيل لها! صورت فيديوهات رائعة من فوق.',
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
    final hPad = (w * 0.053).clamp(16.0, 28.0); // ~22 on M31
    final gridSpacing = (w * 0.039).clamp(12.0, 20.0); // ~16 on M31
    final gridMainSpacing = (w * 0.044).clamp(14.0, 22.0); // ~18
    // Taller cards on narrow/tall phones → better for Arabic text
    final aspectRatio = (w / h) < 0.48 ? 0.64 : 0.72;
    final titleFs = (w * 0.053).clamp(18.0, 24.0); // ~22
    final subtitleFs = (w * 0.031).clamp(11.0, 14.0); // ~13

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
                    style: roboto(
                      fontSize: subtitleFs,
                      color: Colors.grey.shade500,
                    ),
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
                    final trip = flyingTrips[i];
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
                  }, childCount: flyingTrips.length),
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
    final nameFs = (w * 0.030).clamp(11.0, 15.0); // ~12.3
    final subFs = (w * 0.024).clamp(9.0, 12.0); // ~10
    final priceFs = (w * 0.030).clamp(11.0, 15.0); // ~12.3
    final ratingFs = (w * 0.026).clamp(9.0, 13.0); // ~10.7
    final cardPadH = (w * 0.028).clamp(8.0, 14.0); // ~11.5
    final cardPadV = (w * 0.022).clamp(6.0, 12.0); // ~9
    final cardRadius = (w * 0.048).clamp(14.0, 24.0); // ~20

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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 11,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            trip.durationLabel,
                            style: roboto(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
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
                      style: roboto(
                        fontSize: nameFs,
                        fontWeight: FontWeight.w700,
                      ),
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
                          '4.${trip.flightMinutes % 5 + 4}',
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
