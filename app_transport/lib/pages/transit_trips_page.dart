import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'auth_widgets.dart';
import 'transit_trip_detail_page.dart';
import '../models/trip_model.dart';
import '../services/trip_service.dart';

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
  final String imageUrl;

  const TransitStop({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.icon,
    required this.color,
    this.imageUrl = '',
  });
}

// ── Trip data ─────────────────────────────────────────────────────────────
final transitTrips = <TransitTrip>[
  // ─── Trip 1: قصر البارون + متحف أم كلثوم + القرية الفرعونية + ممشى أهل مصر ───
  TransitTrip(
    name: 'Baron Palace, Um Kulthum & Pharaonic Village',
    shortDescription:
        'ينطلق المسافر من مطار القاهرة الدولي متوجهاً إلى قصر البارون إمبان في مصر الجديدة للتعرف على طرازه المعماري الفريد والتقاط الصور لمدة ساعة، ثم الانتقال إلى متحف أم كلثوم في منطقة المنيل للتعرف على سيرة كوكب الشرق ومشاهدة مقتنياتها الشخصية لمدة ساعة، يلي ذلك التوجه إلى القرية الفرعونية لخوض تجربة حية تحاكي الحياة في مصر القديمة لمدة ساعتين، ثم التوقف عند ممشى أهل مصر على كورنيش النيل للاستمتاع بالمشهد العام وتناول وجبة خفيفة لمدة ساعة قبل العودة إلى مطار القاهرة الدولي.',
    durationHours: 6,
    durationHoursExact: 6.0,
    priceUsd: 180,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Baron_Empain_Palace_in_Heliopolis.jpg/1280px-Baron_Empain_Palace_in_Heliopolis.jpg',
    accentColor: const Color(0xFFD4A843),
    routeLabel:
        'المطار → قصر البارون → متحف أم كلثوم → القرية الفرعونية → ممشى أهل مصر → المطار',
    included: ['Airport Transfer', 'Tour Guide', 'Entry Tickets', 'Light Meal'],
    itinerary: [
      TransitStop(
        title: 'استقبال – مطار القاهرة الدولي',
        subtitle: 'استقبال المسافر والانتقال بسيارة سياحية مريحة',
        duration: '20 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TransitStop(
        title: 'قصر البارون إمبان – مصر الجديدة',
        subtitle: 'التعرف على الطراز المعماري الفريد والتقاط الصور',
        duration: '1 hour',
        icon: Icons.castle_rounded,
        color: Color(0xFFD4A843),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Baron_Empain_Palace_in_Heliopolis.jpg/1280px-Baron_Empain_Palace_in_Heliopolis.jpg',
      ),
      TransitStop(
        title: 'متحف أم كلثوم – المنيل',
        subtitle: 'التعرف على سيرة كوكب الشرق ومشاهدة مقتنياتها الشخصية',
        duration: '1 hour',
        icon: Icons.music_note_rounded,
        color: Color(0xFFE02850),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/Manial_Palace.jpg/1280px-Manial_Palace.jpg',
      ),
      TransitStop(
        title: 'القرية الفرعونية',
        subtitle: 'تجربة حية تحاكي الحياة في مصر القديمة',
        duration: '2 hours',
        icon: Icons.account_balance_rounded,
        color: Color(0xFF8B6F47),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/70/Pharaonic_Village.jpg/1280px-Pharaonic_Village.jpg',
      ),
      TransitStop(
        title: 'ممشى أهل مصر – كورنيش النيل',
        subtitle: 'الاستمتاع بالمشهد العام وتناول وجبة خفيفة',
        duration: '1 hour',
        icon: Icons.water_rounded,
        color: Color(0xFF0D7377),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Cairo_Nile_River.jpg/1280px-Cairo_Nile_River.jpg',
      ),
      TransitStop(
        title: 'العودة إلى مطار القاهرة الدولي',
        subtitle: 'التوصيل المباشر إلى صالة المغادرة',
        duration: '30 min',
        icon: Icons.flight_takeoff_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
    ],
    reviews: [
      Review(
        name: 'أحمد محمد',
        rating: 5,
        date: 'منذ يومين',
        comment: 'قصر البارون رائع والقرية الفرعونية تجربة ممتعة للعائلة!',
      ),
      Review(
        name: 'Sarah Johnson',
        rating: 5,
        date: '5 days ago',
        comment:
            'The Pharaonic Village was incredible! A unique experience in Cairo.',
      ),
      Review(
        name: 'ليلى حسن',
        rating: 4,
        date: 'منذ أسبوع',
        comment: 'ممشى أهل مصر جميل جداً ومتحف أم كلثوم مؤثر!',
      ),
    ],
  ),

  // ─── Trip 2: قصر البارون + سيتي ستارز ───
  TransitTrip(
    name: 'Baron Palace & City Stars Mall',
    shortDescription:
        'ينطلق المسافر من مطار القاهرة الدولي متوجهاً إلى قصر البارون إمبان بمصر الجديدة لقربه من المطار، حيث يتم القيام بزيارة سريعة والتقاط الصور والتعرف على تاريخه المعماري لمدة 40 دقيقة تقريباً، ثم التوجه إلى مول سيتي ستارز لقضاء وقت قصير للتسوق أو تناول مشروب لمدة 30 دقيقة، ثم العودة مباشرة إلى مطار القاهرة الدولي.',
    durationHours: 2,
    durationHoursExact: 2.0,
    priceUsd: 100,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Baron_Empain_Palace_in_Heliopolis.jpg/1280px-Baron_Empain_Palace_in_Heliopolis.jpg',
    accentColor: const Color(0xFF9C27B0),
    routeLabel: 'المطار → قصر البارون → سيتي ستارز → المطار',
    included: ['Airport Transfer'],
    itinerary: [
      TransitStop(
        title: 'استقبال – مطار القاهرة الدولي',
        subtitle: 'استقبال المسافر والانتقال لقصر البارون القريب من المطار',
        duration: '15 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TransitStop(
        title: 'قصر البارون إمبان – مصر الجديدة',
        subtitle: 'زيارة سريعة والتقاط الصور والتعرف على تاريخه المعماري',
        duration: '40 min',
        icon: Icons.castle_rounded,
        color: Color(0xFF9C27B0),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Baron_Empain_Palace_in_Heliopolis.jpg/1280px-Baron_Empain_Palace_in_Heliopolis.jpg',
      ),
      TransitStop(
        title: 'مول سيتي ستارز',
        subtitle: 'وقت قصير للتسوق أو تناول مشروب',
        duration: '30 min',
        icon: Icons.shopping_cart_rounded,
        color: Color(0xFFE87832),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Cairo_Tower%2C_Egypt.jpg/1280px-Cairo_Tower%2C_Egypt.jpg',
      ),
      TransitStop(
        title: 'العودة إلى مطار القاهرة الدولي',
        subtitle: 'التوصيل المباشر إلى صالة المغادرة',
        duration: '15 min',
        icon: Icons.flight_takeoff_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
    ],
    reviews: [
      Review(
        name: 'سارة أحمد',
        rating: 5,
        date: 'منذ يومين',
        comment: 'مثالية للترانزيت القصير! قصر البارون قريب من المطار.',
      ),
      Review(
        name: 'David Brown',
        rating: 4,
        date: '1 week ago',
        comment: 'Quick and convenient. Perfect for a short layover!',
      ),
      Review(
        name: 'مريم خالد',
        rating: 5,
        date: 'منذ أسبوعين',
        comment: 'سيتي ستارز مول كبير وجميل والقصر تحفة معمارية!',
      ),
    ],
  ),

  // ─── Trip 3: أهرامات الجيزة + المتحف القومي للحضارة + كورنيش الفسطاط ───
  TransitTrip(
    name: 'Pyramids, NMEC & Nile Corniche',
    shortDescription:
        'يتجه المسافر إلى منطقة أهرامات الجيزة لزيارة هضبة الأهرامات وأبو الهول والتجول داخل المنطقة وقضاء نحو ثلاث ساعات ثم الانتقال إلى المتحف القومي للحضارة المصرية للتعرف على تاريخ الحضارة المصرية ومشاهدة قاعة المومياوات الملكية وقضاء نحو ساعة ونصف، يلي ذلك التوجه إلى كورنيش النيل في الفسطاط للاستمتاع بالمشهد العام وتناول وجبة خفيفة قبل العودة إلى مطار القاهرة الدولي.',
    durationHours: 8,
    durationHoursExact: 8.0,
    priceUsd: 220,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Kheops-Pyramid.jpg/1280px-Kheops-Pyramid.jpg',
    accentColor: const Color(0xFFD4A843),
    routeLabel:
        'المطار → أهرامات الجيزة → المتحف القومي → كورنيش الفسطاط → المطار',
    included: ['Airport Transfer', 'Tour Guide', 'Entry Tickets', 'Light Meal'],
    itinerary: [
      TransitStop(
        title: 'استقبال – مطار القاهرة الدولي',
        subtitle: 'استقبال المسافر والانتقال بسيارة سياحية مريحة',
        duration: '30 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TransitStop(
        title: 'أهرامات الجيزة وأبو الهول',
        subtitle: 'زيارة هضبة الأهرامات والتجول داخل المنطقة ومشاهدة أبو الهول',
        duration: '3 hours',
        icon: Icons.landscape_rounded,
        color: Color(0xFFD4A843),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Kheops-Pyramid.jpg/1280px-Kheops-Pyramid.jpg',
      ),
      TransitStop(
        title: 'المتحف القومي للحضارة المصرية',
        subtitle:
            'التعرف على تاريخ الحضارة المصرية ومشاهدة قاعة المومياوات الملكية',
        duration: '1.5 hours',
        icon: Icons.museum_rounded,
        color: Color(0xFFE02850),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/NMEC-MainEntrance.jpg/1280px-NMEC-MainEntrance.jpg',
      ),
      TransitStop(
        title: 'كورنيش النيل – الفسطاط',
        subtitle: 'الاستمتاع بالمشهد العام وتناول وجبة خفيفة',
        duration: '1 hour',
        icon: Icons.water_rounded,
        color: Color(0xFF0D7377),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/54/Cairo_skyline%2C_Nile_River%2C_Egypt.jpg/1280px-Cairo_skyline%2C_Nile_River%2C_Egypt.jpg',
      ),
      TransitStop(
        title: 'العودة إلى مطار القاهرة الدولي',
        subtitle: 'التوصيل المباشر إلى صالة المغادرة',
        duration: '30 min',
        icon: Icons.flight_takeoff_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
    ],
    reviews: [
      Review(
        name: 'طارق سعيد',
        rating: 5,
        date: 'منذ يوم',
        comment: 'الأهرامات مذهلة وقاعة المومياوات تجربة فريدة!',
      ),
      Review(
        name: 'Patricia Miller',
        rating: 5,
        date: '5 days ago',
        comment:
            'The pyramids were breathtaking! NMEC mummies hall is a must-see.',
      ),
      Review(
        name: 'عائشة كريم',
        rating: 5,
        date: 'منذ 10 أيام',
        comment: 'كورنيش الفسطاط مكان رائع للاسترخاء بعد يوم حافل!',
      ),
    ],
  ),

  // ─── Trip 4: حديقة الأزهر + قلعة صلاح الدين + خان الخليلي + الكنيسة المعلقة ───
  TransitTrip(
    name: 'Azhar Park, Citadel, Khan & Coptic Cairo',
    shortDescription:
        'مطار القاهرة الدولي — يتم استقبال المسافر داخل المطار ثم الانتقال بسيارة سياحية مريحة إلى أول نقطة زيارة. خلال البرنامج يتم التوجه إلى حديقة الأزهر للتجول وسط المساحات الخضراء والاستمتاع بإطلالة بانورامية على القاهرة القديمة، وهي تجربة هادئة ومناسبة للتصوير. بعد ذلك يتم الانتقال إلى قلعة صلاح الدين حيث يمكن مشاهدة أسوار القلعة التاريخية وإطلالة علوية على المدينة مع شرح تاريخي مختصر. تستغرق الزيارتان نحو ساعتين إجمالًا. يلي ذلك زيارة خان الخليلي للتجول في السوق التاريخي وشراء الهدايا التذكارية وتناول مشروب أو وجبة خفيفة لمدة نحو ساعة. في ختام الجولة يتم التوجه إلى منطقة القاهرة القبطية لزيارة الكنيسة المعلقة والتعرف على أحد أقدم المعالم الدينية في مصر في زيارة قصيرة مدتها نحو 30 دقيقة.',
    durationHours: 4,
    durationHoursExact: 4.0,
    priceUsd: 160,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/Al-Azhar_Park_Kairo_04.jpg/1280px-Al-Azhar_Park_Kairo_04.jpg',
    accentColor: const Color(0xFF4CAF50),
    routeLabel:
        'المطار → حديقة الأزهر → قلعة صلاح الدين → خان الخليلي → الكنيسة المعلقة → المطار',
    included: ['Airport Transfer', 'Tour Guide', 'Entry Tickets', 'Drink'],
    itinerary: [
      TransitStop(
        title: 'استقبال – مطار القاهرة الدولي',
        subtitle: 'استقبال المسافر والانتقال بسيارة سياحية مريحة',
        duration: '25 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TransitStop(
        title: 'حديقة الأزهر',
        subtitle:
            'التجول وسط المساحات الخضراء والاستمتاع بإطلالة بانورامية على القاهرة القديمة',
        duration: '1 hour',
        icon: Icons.park_rounded,
        color: Color(0xFF4CAF50),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/Al-Azhar_Park_Kairo_04.jpg/1280px-Al-Azhar_Park_Kairo_04.jpg',
      ),
      TransitStop(
        title: 'قلعة صلاح الدين',
        subtitle:
            'مشاهدة أسوار القلعة التاريخية وإطلالة علوية على المدينة مع شرح تاريخي مختصر',
        duration: '1 hour',
        icon: Icons.fort_rounded,
        color: Color(0xFFE02850),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Cairo_Citadel_DSCF3411.jpg/1280px-Cairo_Citadel_DSCF3411.jpg',
      ),
      TransitStop(
        title: 'خان الخليلي',
        subtitle:
            'التجول في السوق التاريخي وشراء الهدايا التذكارية وتناول مشروب أو وجبة خفيفة',
        duration: '1 hour',
        icon: Icons.shopping_bag_rounded,
        color: Color(0xFFE87832),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Khan_el-Khalili_2019.jpg/1280px-Khan_el-Khalili_2019.jpg',
      ),
      TransitStop(
        title: 'الكنيسة المعلقة – القاهرة القبطية',
        subtitle: 'زيارة أحد أقدم المعالم الدينية في مصر',
        duration: '30 min',
        icon: Icons.church_rounded,
        color: Color(0xFF4A44AA),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Hanging_Church_Cairo.jpg/1280px-Hanging_Church_Cairo.jpg',
      ),
      TransitStop(
        title: 'العودة إلى مطار القاهرة الدولي',
        subtitle: 'التوصيل المباشر إلى صالة المغادرة',
        duration: '25 min',
        icon: Icons.flight_takeoff_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
    ],
    reviews: [
      Review(
        name: 'يوسف أحمد',
        rating: 5,
        date: 'منذ يومين',
        comment: 'حديقة الأزهر مكان هادئ ورائع والقلعة إطلالة لا تنسى!',
      ),
      Review(
        name: 'Emma Davis',
        rating: 5,
        date: '1 week ago',
        comment:
            'Great variety of sights in 4 hours. Khan El-Khalili was amazing!',
      ),
      Review(
        name: 'عمر حسن',
        rating: 4,
        date: 'منذ أسبوعين',
        comment: 'جولة منوعة وممتعة تجمع الطبيعة والتاريخ والتسوق!',
      ),
    ],
  ),

  // ─── Trip 5: قصر عابدين + الكنيسة المعلقة + حديقة الأزهر ───
  TransitTrip(
    name: 'Abdeen Palace, Hanging Church & Azhar Park',
    shortDescription:
        'ينطلق المسافر من مطار القاهرة الدولي متوجهاً إلى قصر عابدين لزيارة القاعات الملكية والتعرف على تاريخ أسرة محمد علي لمدة ساعة، ثم الانتقال إلى الكنيسة المعلقة في منطقة مصر القديمة لاستكشاف أحد أقدم الكنائس في مصر وقضاء نحو 45 دقيقة، يلي ذلك التوجه إلى حديقة الأزهر للاستمتاع بإطلالة رائعة على القاهرة وتناول مشروب خفيف لمدة 45 دقيقة، ثم العودة إلى مطار القاهرة الدولي.',
    durationHours: 3,
    durationHoursExact: 3.0,
    priceUsd: 130,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Abdeen_Palace.jpg/1280px-Abdeen_Palace.jpg',
    accentColor: const Color(0xFF4A44AA),
    routeLabel: 'المطار → قصر عابدين → الكنيسة المعلقة → حديقة الأزهر → المطار',
    included: ['Airport Transfer', 'Tour Guide', 'Entry Tickets'],
    itinerary: [
      TransitStop(
        title: 'استقبال – مطار القاهرة الدولي',
        subtitle: 'استقبال المسافر والانتقال بسيارة سياحية مريحة',
        duration: '20 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TransitStop(
        title: 'قصر عابدين',
        subtitle: 'زيارة القاعات الملكية والتعرف على تاريخ أسرة محمد علي',
        duration: '1 hour',
        icon: Icons.castle_rounded,
        color: Color(0xFF4A44AA),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Abdeen_Palace.jpg/1280px-Abdeen_Palace.jpg',
      ),
      TransitStop(
        title: 'الكنيسة المعلقة – مصر القديمة',
        subtitle: 'استكشاف أحد أقدم الكنائس في مصر',
        duration: '45 min',
        icon: Icons.church_rounded,
        color: Color(0xFF8B6F47),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Hanging_Church_Cairo.jpg/1280px-Hanging_Church_Cairo.jpg',
      ),
      TransitStop(
        title: 'حديقة الأزهر',
        subtitle: 'إطلالة رائعة على القاهرة وتناول مشروب خفيف',
        duration: '45 min',
        icon: Icons.park_rounded,
        color: Color(0xFF4CAF50),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/Al-Azhar_Park_Kairo_04.jpg/1280px-Al-Azhar_Park_Kairo_04.jpg',
      ),
      TransitStop(
        title: 'العودة إلى مطار القاهرة الدولي',
        subtitle: 'التوصيل المباشر إلى صالة المغادرة',
        duration: '20 min',
        icon: Icons.flight_takeoff_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
    ],
    reviews: [
      Review(
        name: 'فاطمة خليل',
        rating: 5,
        date: 'منذ يوم',
        comment: 'قصر عابدين فخم جداً والكنيسة المعلقة مكان روحاني!',
      ),
      Review(
        name: 'Mark Thompson',
        rating: 4,
        date: '4 days ago',
        comment: 'Short but packed with history. Abdeen Palace is stunning!',
      ),
      Review(
        name: 'نور حسن',
        rating: 5,
        date: 'منذ أسبوع',
        comment: 'رحلة مناسبة لمن لديه وقت قصير. المناظر من الأزهر رائعة!',
      ),
    ],
  ),

  // ─── Trip 6: قلعة صلاح الدين + شارع المعز + خان الخليلي + مقهى نيلي ───
  TransitTrip(
    name: 'Citadel, Al-Muizz Street & Nile Café',
    shortDescription:
        'ينطلق المسافر من مطار القاهرة الدولي متوجهاً إلى قلعة صلاح الدين الأيوبي للاستمتاع بجولة لمدة ساعة ونصف وزيارة مسجد محمد علي ومشاهدة الإطلالة البانورامية على القاهرة، ثم الانتقال إلى شارع المعز والتجول بين المباني الأثرية والأسواق التاريخية وصولاً إلى خان الخليلي لقضاء وقت ممتع وشراء الهدايا التذكارية لمدة ساعة ونصف، يلي ذلك التوجه إلى أحد المقاهي المطلة على نهر النيل في وسط القاهرة للاستمتاع بالمشهد العام وتناول مشروب أو وجبة خفيفة لمدة ساعة، ثم العودة إلى مطار القاهرة الدولي.',
    durationHours: 5,
    durationHoursExact: 5.0,
    priceUsd: 160,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Cairo_Citadel_DSCF3411.jpg/1280px-Cairo_Citadel_DSCF3411.jpg',
    accentColor: const Color(0xFFE02850),
    routeLabel:
        'المطار → القلعة → شارع المعز → خان الخليلي → مقهى نيلي → المطار',
    included: ['Airport Transfer', 'Tour Guide', 'Citadel Tickets', 'Drink'],
    itinerary: [
      TransitStop(
        title: 'استقبال – مطار القاهرة الدولي',
        subtitle: 'استقبال المسافر والانتقال بسيارة سياحية مريحة',
        duration: '25 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TransitStop(
        title: 'قلعة صلاح الدين الأيوبي',
        subtitle:
            'زيارة مسجد محمد علي ومشاهدة الإطلالة البانورامية على القاهرة',
        duration: '1.5 hours',
        icon: Icons.fort_rounded,
        color: Color(0xFFE02850),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Cairo_Citadel_DSCF3411.jpg/1280px-Cairo_Citadel_DSCF3411.jpg',
      ),
      TransitStop(
        title: 'شارع المعز وخان الخليلي',
        subtitle:
            'التجول بين المباني الأثرية والأسواق التاريخية وشراء الهدايا التذكارية',
        duration: '1.5 hours',
        icon: Icons.storefront_rounded,
        color: Color(0xFF8B6F47),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Khan_el-Khalili_2019.jpg/1280px-Khan_el-Khalili_2019.jpg',
      ),
      TransitStop(
        title: 'مقهى مطل على نهر النيل',
        subtitle: 'الاستمتاع بالمشهد العام وتناول مشروب أو وجبة خفيفة',
        duration: '1 hour',
        icon: Icons.local_cafe_rounded,
        color: Color(0xFF0D7377),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Cairo_Tower_and_Qasr_El_Nil_Bridge.jpg/1280px-Cairo_Tower_and_Qasr_El_Nil_Bridge.jpg',
      ),
      TransitStop(
        title: 'العودة إلى مطار القاهرة الدولي',
        subtitle: 'التوصيل المباشر إلى صالة المغادرة',
        duration: '25 min',
        icon: Icons.flight_takeoff_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
    ],
    reviews: [
      Review(
        name: 'ريم منصور',
        rating: 5,
        date: 'منذ 3 أيام',
        comment: 'القلعة مذهلة وشارع المعز مليء بالتاريخ!',
      ),
      Review(
        name: 'James Wilson',
        rating: 5,
        date: '1 week ago',
        comment:
            'Loved the citadel views and the Nile café was a perfect ending!',
      ),
      Review(
        name: 'دينا نور',
        rating: 4,
        date: 'منذ أسبوعين',
        comment: 'جولة تاريخية ممتعة والمقهى على النيل كان رائعاً!',
      ),
    ],
  ),

  // ─── Trip 7: أهرامات الجيزة + المتحف المصري + حديقة الأزهر + خان الخليلي ───
  TransitTrip(
    name: 'Pyramids, Egyptian Museum, Azhar Park & Khan',
    shortDescription:
        'ينطلق المسافر من مطار القاهرة الدولي متوجهاً إلى أهرامات الجيزة لزيارة هضبة الأهرامات والتجول بالمنطقة ومشاهدة أبو الهول وقضاء نحو ثلاث ساعات، ثم الانتقال إلى المتحف المصري بالتحرير للتعرف على كنوز الحضارة المصرية القديمة ومشاهدة أهم القطع الأثرية لمدة ساعتين، يلي ذلك التوجه إلى حديقة الأزهر للاستمتاع بالمشي وإطلالة بانورامية على القاهرة التاريخية لمدة ساعة ونصف، ثم زيارة خان الخليلي للتسوق وقضاء وقت حر لمدة ساعة ونصف قبل العودة إلى مطار القاهرة الدولي.',
    durationHours: 9,
    durationHoursExact: 9.0,
    priceUsd: 250,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Kheops-Pyramid.jpg/1280px-Kheops-Pyramid.jpg',
    accentColor: const Color(0xFFD4A843),
    routeLabel:
        'المطار → الأهرامات → المتحف المصري → حديقة الأزهر → خان الخليلي → المطار',
    included: ['Airport Transfer', 'Tour Guide', 'Entry Tickets', 'Light Meal'],
    itinerary: [
      TransitStop(
        title: 'استقبال – مطار القاهرة الدولي',
        subtitle: 'استقبال المسافر والانتقال بسيارة سياحية مريحة',
        duration: '30 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TransitStop(
        title: 'أهرامات الجيزة وأبو الهول',
        subtitle: 'زيارة هضبة الأهرامات والتجول بالمنطقة ومشاهدة أبو الهول',
        duration: '3 hours',
        icon: Icons.landscape_rounded,
        color: Color(0xFFD4A843),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Kheops-Pyramid.jpg/1280px-Kheops-Pyramid.jpg',
      ),
      TransitStop(
        title: 'المتحف المصري بالتحرير',
        subtitle:
            'التعرف على كنوز الحضارة المصرية القديمة ومشاهدة أهم القطع الأثرية',
        duration: '2 hours',
        icon: Icons.museum_rounded,
        color: Color(0xFFE02850),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/71/The_Egyptian_Museum.jpg/1280px-The_Egyptian_Museum.jpg',
      ),
      TransitStop(
        title: 'حديقة الأزهر',
        subtitle: 'الاستمتاع بالمشي وإطلالة بانورامية على القاهرة التاريخية',
        duration: '1.5 hours',
        icon: Icons.park_rounded,
        color: Color(0xFF4CAF50),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/Al-Azhar_Park_Kairo_04.jpg/1280px-Al-Azhar_Park_Kairo_04.jpg',
      ),
      TransitStop(
        title: 'خان الخليلي',
        subtitle: 'التسوق وقضاء وقت حر في السوق التاريخي',
        duration: '1.5 hours',
        icon: Icons.shopping_bag_rounded,
        color: Color(0xFFE87832),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Khan_el-Khalili_2019.jpg/1280px-Khan_el-Khalili_2019.jpg',
      ),
      TransitStop(
        title: 'العودة إلى مطار القاهرة الدولي',
        subtitle: 'التوصيل المباشر إلى صالة المغادرة',
        duration: '30 min',
        icon: Icons.flight_takeoff_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
    ],
    reviews: [
      Review(
        name: 'محمد علي',
        rating: 5,
        date: 'منذ يوم',
        comment: 'الأهرامات مذهلة والمتحف رائع! رحلة شاملة وممتازة.',
      ),
      Review(
        name: 'Emily Clark',
        rating: 5,
        date: '3 days ago',
        comment:
            'Best day trip in Cairo! The pyramids and Khan El-Khalili were amazing.',
      ),
      Review(
        name: 'نور الدين',
        rating: 5,
        date: 'منذ أسبوع',
        comment: 'حديقة الأزهر جميلة جداً وخان الخليلي تجربة لا تنسى!',
      ),
    ],
  ),

  // ─── Trip 8: قصر البارون + المتحف القومي + حديقة الأزهر ───
  TransitTrip(
    name: 'Baron Palace, NMEC & Azhar Park',
    shortDescription:
        'ينطلق المسافر من مطار القاهرة الدولي متوجهاً إلى قصر البارون إمبان للاستمتاع بزيارة قصيرة والتعرف على طرازه المعماري المميز لمدة ساعة تقريبًا، ثم الانتقال إلى المتحف القومي للحضارة المصرية للتعرف على تاريخ الحضارة المصرية ومشاهدة أبرز المعروضات لمدة ساعة ونصف، يلي ذلك التوجه إلى حديقة الأزهر للاستمتاع بالمشي وسط المساحات الخضراء وإطلالة مميزة على القاهرة مع وقت لتناول مشروب أو وجبة خفيفة لمدة ساعة، ثم العودة إلى مطار القاهرة الدولي.',
    durationHours: 5,
    durationHoursExact: 5.0,
    priceUsd: 155,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Baron_Empain_Palace_in_Heliopolis.jpg/1280px-Baron_Empain_Palace_in_Heliopolis.jpg',
    accentColor: const Color(0xFF4CAF50),
    routeLabel: 'المطار → قصر البارون → المتحف القومي → حديقة الأزهر → المطار',
    included: ['Airport Transfer', 'Tour Guide', 'Entry Tickets', 'Drink'],
    itinerary: [
      TransitStop(
        title: 'استقبال – مطار القاهرة الدولي',
        subtitle: 'استقبال المسافر والانتقال بسيارة سياحية مريحة',
        duration: '20 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TransitStop(
        title: 'قصر البارون إمبان',
        subtitle: 'زيارة قصيرة والتعرف على طرازه المعماري المميز والتقاط الصور',
        duration: '1 hour',
        icon: Icons.castle_rounded,
        color: Color(0xFFD4A843),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Baron_Empain_Palace_in_Heliopolis.jpg/1280px-Baron_Empain_Palace_in_Heliopolis.jpg',
      ),
      TransitStop(
        title: 'المتحف القومي للحضارة المصرية',
        subtitle: 'التعرف على تاريخ الحضارة المصرية ومشاهدة أبرز المعروضات',
        duration: '1.5 hours',
        icon: Icons.museum_rounded,
        color: Color(0xFFE02850),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/NMEC-MainEntrance.jpg/1280px-NMEC-MainEntrance.jpg',
      ),
      TransitStop(
        title: 'حديقة الأزهر',
        subtitle:
            'الاستمتاع بالمشي وسط المساحات الخضراء وإطلالة مميزة مع تناول مشروب أو وجبة خفيفة',
        duration: '1 hour',
        icon: Icons.park_rounded,
        color: Color(0xFF4CAF50),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/Al-Azhar_Park_Kairo_04.jpg/1280px-Al-Azhar_Park_Kairo_04.jpg',
      ),
      TransitStop(
        title: 'العودة إلى مطار القاهرة الدولي',
        subtitle: 'التوصيل المباشر إلى صالة المغادرة',
        duration: '25 min',
        icon: Icons.flight_takeoff_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
    ],
    reviews: [
      Review(
        name: 'منى عبدالله',
        rating: 5,
        date: 'منذ 3 أيام',
        comment: 'قصر البارون قريب من المطار والحديقة مكان مثالي للتصوير!',
      ),
      Review(
        name: 'Robert Lee',
        rating: 5,
        date: '1 week ago',
        comment: 'A great mix of history, culture and nature in 5 hours!',
      ),
      Review(
        name: 'سلمى حسين',
        rating: 4,
        date: 'منذ أسبوعين',
        comment: 'المتحف القومي رائع والأزهر بارك مكان هادئ وجميل!',
      ),
    ],
  ),

  // ─── Trip 9: المتحف المصري الكبير + سقارة + برج القاهرة ───
  TransitTrip(
    name: 'Grand Museum, Saqqara & Cairo Tower',
    shortDescription:
        'مطار القاهرة الدولي — يتم استقبال المسافر داخل مطار القاهرة الدولي ثم الانطلاق بسيارة سياحية مريحة بصحبة مرشد سياحي. تبدأ الجولة بزيارة المتحف المصري الكبير للتعرف على أبرز كنوز الحضارة المصرية وقضاء نحو ثلاث ساعات، ثم الانتقال إلى سقارة لزيارة هرم زوسر المدرج والتجول في المنطقة الأثرية لمدة ساعة ونصف. يلي ذلك التوجه إلى برج القاهرة للاستمتاع بإطلالة بانورامية على المدينة مع وقت لالتقاط الصور أو تناول مشروب لمدة ساعة، ثم العودة إلى مطار القاهرة الدولي.',
    durationHours: 8,
    durationHoursExact: 8.0,
    priceUsd: 230,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/Grand_Egyptian_Museum_-_EGWUG_Trip_%281%29.jpg/1280px-Grand_Egyptian_Museum_-_EGWUG_Trip_%281%29.jpg',
    accentColor: const Color(0xFF8B6F47),
    routeLabel: 'المطار → المتحف الكبير → سقارة → برج القاهرة → المطار',
    included: ['Airport Transfer', 'Tour Guide', 'Entry Tickets', 'Drink'],
    itinerary: [
      TransitStop(
        title: 'استقبال – مطار القاهرة الدولي',
        subtitle: 'استقبال المسافر والانطلاق بسيارة سياحية بصحبة مرشد سياحي',
        duration: '30 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TransitStop(
        title: 'المتحف المصري الكبير',
        subtitle: 'التعرف على أبرز كنوز الحضارة المصرية',
        duration: '3 hours',
        icon: Icons.museum_rounded,
        color: Color(0xFF8B6F47),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/Grand_Egyptian_Museum_-_EGWUG_Trip_%281%29.jpg/1280px-Grand_Egyptian_Museum_-_EGWUG_Trip_%281%29.jpg',
      ),
      TransitStop(
        title: 'سقارة – هرم زوسر المدرج',
        subtitle: 'زيارة أقدم هرم في مصر والتجول في المنطقة الأثرية',
        duration: '1.5 hours',
        icon: Icons.landscape_rounded,
        color: Color(0xFFD4A843),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Saqqara_BW_5.jpg/1280px-Saqqara_BW_5.jpg',
      ),
      TransitStop(
        title: 'برج القاهرة',
        subtitle:
            'إطلالة بانورامية على المدينة مع وقت لالتقاط الصور أو تناول مشروب',
        duration: '1 hour',
        icon: Icons.cell_tower_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Cairo_Tower%2C_Egypt.jpg/1280px-Cairo_Tower%2C_Egypt.jpg',
      ),
      TransitStop(
        title: 'العودة إلى مطار القاهرة الدولي',
        subtitle: 'التوصيل المباشر إلى صالة المغادرة',
        duration: '30 min',
        icon: Icons.flight_takeoff_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
    ],
    reviews: [
      Review(
        name: 'أحمد سامي',
        rating: 5,
        date: 'منذ يومين',
        comment: 'المتحف الكبير تجربة لا مثيل لها وسقارة مكان ساحر!',
      ),
      Review(
        name: 'Sophie Martin',
        rating: 5,
        date: '5 days ago',
        comment:
            'The Grand Museum is world-class! Cairo Tower sunset was perfect.',
      ),
      Review(
        name: 'كريم حسن',
        rating: 5,
        date: 'منذ أسبوع',
        comment: 'برج القاهرة منظر خيالي وهرم زوسر عظيم!',
      ),
    ],
  ),

  // ─── Trip 10: المتحف القومي + قصر عابدين + ممشى أهل مصر ───
  TransitTrip(
    name: 'NMEC, Abdeen Palace & Ahl Masr Walk',
    shortDescription:
        'مطار القاهرة الدولي — يتم استقبال المسافر داخل مطار القاهرة الدولي ثم الانتقال بسيارة سياحية مريحة إلى أولى محطات الزيارة. خلال البرنامج يتم التوجه إلى المتحف القومي للحضارة المصرية في الفسطاط للتعرف على تطور الحضارة المصرية عبر العصور ومشاهدة قاعة المومياوات الملكية في زيارة تستغرق نحو ساعة ونصف. بعد ذلك يتم الانتقال إلى قصر عابدين لاستكشاف القاعات الملكية والتعرف على تاريخ الأسرة العلوية لمدة ساعة تقريبًا. يلي ذلك التوجه إلى ممشى أهل مصر على كورنيش النيل للاستمتاع بالمشهد العام والتقاط الصور وتناول مشروب أو وجبة خفيفة لمدة نحو 45 دقيقة.',
    durationHours: 4,
    durationHoursExact: 4.0,
    priceUsd: 150,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/NMEC-MainEntrance.jpg/1280px-NMEC-MainEntrance.jpg',
    accentColor: const Color(0xFF0D7377),
    routeLabel: 'المطار → المتحف القومي → قصر عابدين → ممشى أهل مصر → المطار',
    included: ['Airport Transfer', 'Tour Guide', 'Entry Tickets', 'Drink'],
    itinerary: [
      TransitStop(
        title: 'استقبال – مطار القاهرة الدولي',
        subtitle: 'استقبال المسافر والانتقال بسيارة سياحية مريحة',
        duration: '25 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TransitStop(
        title: 'المتحف القومي للحضارة المصرية – الفسطاط',
        subtitle:
            'التعرف على تطور الحضارة المصرية عبر العصور ومشاهدة قاعة المومياوات الملكية',
        duration: '1.5 hours',
        icon: Icons.museum_rounded,
        color: Color(0xFFE02850),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/NMEC-MainEntrance.jpg/1280px-NMEC-MainEntrance.jpg',
      ),
      TransitStop(
        title: 'قصر عابدين',
        subtitle: 'استكشاف القاعات الملكية والتعرف على تاريخ الأسرة العلوية',
        duration: '1 hour',
        icon: Icons.castle_rounded,
        color: Color(0xFF4A44AA),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Abdeen_Palace.jpg/1280px-Abdeen_Palace.jpg',
      ),
      TransitStop(
        title: 'ممشى أهل مصر – كورنيش النيل',
        subtitle:
            'الاستمتاع بالمشهد العام والتقاط الصور وتناول مشروب أو وجبة خفيفة',
        duration: '45 min',
        icon: Icons.water_rounded,
        color: Color(0xFF0D7377),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Cairo_Nile_River.jpg/1280px-Cairo_Nile_River.jpg',
      ),
      TransitStop(
        title: 'العودة إلى مطار القاهرة الدولي',
        subtitle: 'التوصيل المباشر إلى صالة المغادرة',
        duration: '25 min',
        icon: Icons.flight_takeoff_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
    ],
    reviews: [
      Review(
        name: 'خالد إبراهيم',
        rating: 5,
        date: 'منذ يوم',
        comment: 'المتحف القومي رائع وقاعة المومياوات تجربة لا تنسى!',
      ),
      Review(
        name: 'Anna Schmidt',
        rating: 5,
        date: '4 days ago',
        comment: 'NMEC mummies hall is incredible! Abdeen Palace was a bonus.',
      ),
      Review(
        name: 'هدى سامي',
        rating: 4,
        date: 'منذ أسبوع',
        comment: 'ممشى أهل مصر مكان جميل للاسترخاء على النيل!',
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripService>().loadTrips();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<TripModel> _filteredTrips(List<TripModel> trips) {
    switch (_filterIndex) {
      case 1:
        return trips.where((t) => t.durationMinutes <= 240).toList();
      case 2:
        return trips
            .where(
              (t) => t.durationMinutes > 240 && t.durationMinutes <= 480,
            )
            .toList();
      case 3:
        return trips.where((t) => t.durationMinutes > 480).toList();
      default:
        return trips;
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

  void _openDetail(TripModel trip) {
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
    final tripService = context.watch<TripService>();
    final trips = _filteredTrips(
      tripService.activeTrips.where((t) => t.isTransit).toList(),
    );

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
  final TripModel trip;
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
    final durColor = trip.durationMinutes <= 240
        ? const Color(0xFF0D7377)
      : trip.durationMinutes <= 480
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
                                      trip.durationLabel,
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
