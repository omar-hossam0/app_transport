import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/trip_model.dart';
import '../services/trip_service.dart';
import 'auth_widgets.dart';
import 'chatbot_page.dart';
import 'transit_trip_detail_page.dart';
import '../services/smooth_navigation.dart';
import '../services/language_provider.dart';
import '../services/app_localizations.dart';

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
  final String nameAr;
  final String shortDescription;
  final String shortDescriptionEn;
  final int durationHours;
  final double durationHoursExact;
  final int priceUsd;
  final String imageUrl;
  final Color accentColor;
  final String routeLabel;
  final String routeLabelEn;
  final List<TransitStop> itinerary;
  final List<String> includedKeys;
  final List<Review> reviews;

  const TransitTrip({
    required this.name,
    this.nameAr = '',
    required this.shortDescription,
    this.shortDescriptionEn = '',
    required this.durationHours,
    required this.durationHoursExact,
    required this.priceUsd,
    required this.imageUrl,
    required this.accentColor,
    required this.routeLabel,
    this.routeLabelEn = '',
    required this.itinerary,
    required this.includedKeys,
    this.reviews = const [],
  });

  String localizedName(bool isAr) => isAr ? (nameAr.isEmpty ? name : nameAr) : name;
  String localizedShortDescription(bool isAr) =>
      isAr ? shortDescription : (shortDescriptionEn.isEmpty ? shortDescription : shortDescriptionEn);
  String localizedRouteLabel(bool isAr) =>
      isAr ? routeLabel : (routeLabelEn.isEmpty ? routeLabel : routeLabelEn);
  List<String> localizedIncluded(bool isAr) =>
      includedKeys.map((k) => S.tr(k, isAr)).toList();

  String get durationLabel =>
      durationHoursExact == durationHoursExact.truncateToDouble()
      ? '${durationHours}h'
      : '${durationHoursExact}h';
  String get priceLabel => '\$$priceUsd';
}

class TransitStop {
  final String title;
  final String titleEn;
  final String subtitle;
  final String subtitleEn;
  final String duration;
  final IconData icon;
  final Color color;
  final String imageUrl;

  const TransitStop({
    required this.title,
    this.titleEn = '',
    required this.subtitle,
    this.subtitleEn = '',
    required this.duration,
    required this.icon,
    required this.color,
    this.imageUrl = '',
  });

  String localizedTitle(bool isAr) => isAr ? title : (titleEn.isEmpty ? title : titleEn);
  String localizedSubtitle(bool isAr) => isAr ? subtitle : (subtitleEn.isEmpty ? subtitle : subtitleEn);
}

// ── Trip data ─────────────────────────────────────────────────────────────
final transitTrips = <TransitTrip>[
  // ─── Trip 1: قصر البارون + متحف أم كلثوم + القرية الفرعونية + ممشى أهل مصر ───
  TransitTrip(
    name: 'Baron Palace, Um Kulthum & Pharaonic Village',
    nameAr: 'قصر البارون ومتحف أم كلثوم والقرية الفرعونية',
    shortDescription:
        'ينطلق المسافر من مطار القاهرة الدولي متوجهاً إلى قصر البارون إمبان في مصر الجديدة للتعرف على طرازه المعماري الفريد والتقاط الصور لمدة ساعة، ثم الانتقال إلى متحف أم كلثوم في منطقة المنيل للتعرف على سيرة كوكب الشرق ومشاهدة مقتنياتها الشخصية لمدة ساعة، يلي ذلك التوجه إلى القرية الفرعونية لخوض تجربة حية تحاكي الحياة في مصر القديمة لمدة ساعتين، ثم التوقف عند ممشى أهل مصر على كورنيش النيل للاستمتاع بالمشهد العام وتناول وجبة خفيفة لمدة ساعة قبل العودة إلى مطار القاهرة الدولي.',
    shortDescriptionEn:
        'Depart from Cairo International Airport to Baron Empain Palace in Heliopolis to admire its unique architecture and take photos for one hour, then head to the Um Kulthum Museum in Manial to explore the legend of the Star of the East and view her personal belongings for one hour, followed by a visit to the Pharaonic Village for an immersive experience of ancient Egyptian life for two hours, then stop at Ahl Masr Walk on the Nile Corniche to enjoy the scenery and have a light meal before returning to Cairo Airport.',
    durationHours: 6,
    durationHoursExact: 6.0,
    priceUsd: 180,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Baron_Empain_Palace_in_Heliopolis.jpg/1280px-Baron_Empain_Palace_in_Heliopolis.jpg',
    accentColor: const Color(0xFFD4A843),
    routeLabel:
        'المطار → قصر البارون → متحف أم كلثوم → القرية الفرعونية → ممشى أهل مصر → المطار',
    routeLabelEn:
        'Airport → Baron Palace → Um Kulthum Museum → Pharaonic Village → Ahl Masr Walk → Airport',
    includedKeys: ['incl_airport_transfer', 'incl_tour_guide', 'incl_entry_tickets', 'incl_light_meal'],
    itinerary: [
      TransitStop(
        title: 'استقبال – مطار القاهرة الدولي',
        titleEn: 'Pickup – Cairo International Airport',
        subtitle: 'استقبال المسافر والانتقال بسيارة سياحية مريحة',
        subtitleEn: 'Meet the traveler and transfer by comfortable tourist vehicle',
        duration: '20 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TransitStop(
        title: 'قصر البارون إمبان – مصر الجديدة',
        titleEn: 'Baron Empain Palace – Heliopolis',
        subtitle: 'التعرف على الطراز المعماري الفريد والتقاط الصور',
        subtitleEn: 'Discover the unique architectural style and take photos',
        duration: '1 hour',
        icon: Icons.castle_rounded,
        color: Color(0xFFD4A843),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Baron_Empain_Palace_in_Heliopolis.jpg/1280px-Baron_Empain_Palace_in_Heliopolis.jpg',
      ),
      TransitStop(
        title: 'متحف أم كلثوم – المنيل',
        titleEn: 'Um Kulthum Museum – Manial',
        subtitle: 'التعرف على سيرة كوكب الشرق ومشاهدة مقتنياتها الشخصية',
        subtitleEn: 'Explore the life of the Star of the East and view her personal belongings',
        duration: '1 hour',
        icon: Icons.music_note_rounded,
        color: Color(0xFFE02850),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/Manial_Palace.jpg/1280px-Manial_Palace.jpg',
      ),
      TransitStop(
        title: 'القرية الفرعونية',
        titleEn: 'Pharaonic Village',
        subtitle: 'تجربة حية تحاكي الحياة في مصر القديمة',
        subtitleEn: 'An immersive experience recreating life in ancient Egypt',
        duration: '2 hours',
        icon: Icons.account_balance_rounded,
        color: Color(0xFF8B6F47),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/70/Pharaonic_Village.jpg/1280px-Pharaonic_Village.jpg',
      ),
      TransitStop(
        title: 'ممشى أهل مصر – كورنيش النيل',
        titleEn: 'Ahl Masr Walk – Nile Corniche',
        subtitle: 'الاستمتاع بالمشهد العام وتناول وجبة خفيفة',
        subtitleEn: 'Enjoy the scenery and have a light meal',
        duration: '1 hour',
        icon: Icons.water_rounded,
        color: Color(0xFF0D7377),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Cairo_Nile_River.jpg/1280px-Cairo_Nile_River.jpg',
      ),
      TransitStop(
        title: 'العودة إلى مطار القاهرة الدولي',
        titleEn: 'Return to Cairo International Airport',
        subtitle: 'التوصيل المباشر إلى صالة المغادرة',
        subtitleEn: 'Direct drop-off at the departure terminal',
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
    nameAr: 'قصر البارون وسيتي ستارز',
    shortDescription:
        'ينطلق المسافر من مطار القاهرة الدولي متوجهاً إلى قصر البارون إمبان بمصر الجديدة لقربه من المطار، حيث يتم القيام بزيارة سريعة والتقاط الصور والتعرف على تاريخه المعماري لمدة 40 دقيقة تقريباً، ثم التوجه إلى مول سيتي ستارز لقضاء وقت قصير للتسوق أو تناول مشروب لمدة 30 دقيقة، ثم العودة مباشرة إلى مطار القاهرة الدولي.',
    shortDescriptionEn:
        'Depart from Cairo International Airport to the nearby Baron Empain Palace in Heliopolis for a quick visit, photo opportunities and a look at its architectural history for about 40 minutes, then head to City Stars Mall for a short shopping or coffee break for 30 minutes, before returning directly to Cairo International Airport.',
    durationHours: 2,
    durationHoursExact: 2.0,
    priceUsd: 100,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Baron_Empain_Palace_in_Heliopolis.jpg/1280px-Baron_Empain_Palace_in_Heliopolis.jpg',
    accentColor: const Color(0xFF9C27B0),
    routeLabel: 'المطار → قصر البارون → سيتي ستارز → المطار',
    routeLabelEn: 'Airport → Baron Palace → City Stars → Airport',
    includedKeys: ['incl_airport_transfer'],
    itinerary: [
      TransitStop(
        title: 'استقبال – مطار القاهرة الدولي',
        titleEn: 'Pickup – Cairo International Airport',
        subtitle: 'استقبال المسافر والانتقال لقصر البارون القريب من المطار',
        subtitleEn: 'Meet the traveler and transfer to the nearby Baron Palace',
        duration: '15 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TransitStop(
        title: 'قصر البارون إمبان – مصر الجديدة',
        titleEn: 'Baron Empain Palace – Heliopolis',
        subtitle: 'زيارة سريعة والتقاط الصور والتعرف على تاريخه المعماري',
        subtitleEn: 'Quick visit, photo opportunities and a look at its architectural history',
        duration: '40 min',
        icon: Icons.castle_rounded,
        color: Color(0xFF9C27B0),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Baron_Empain_Palace_in_Heliopolis.jpg/1280px-Baron_Empain_Palace_in_Heliopolis.jpg',
      ),
      TransitStop(
        title: 'مول سيتي ستارز',
        titleEn: 'City Stars Mall',
        subtitle: 'وقت قصير للتسوق أو تناول مشروب',
        subtitleEn: 'Short time for shopping or a quick drink',
        duration: '30 min',
        icon: Icons.shopping_cart_rounded,
        color: Color(0xFFE87832),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Cairo_Tower%2C_Egypt.jpg/1280px-Cairo_Tower%2C_Egypt.jpg',
      ),
      TransitStop(
        title: 'العودة إلى مطار القاهرة الدولي',
        titleEn: 'Return to Cairo International Airport',
        subtitle: 'التوصيل المباشر إلى صالة المغادرة',
        subtitleEn: 'Direct drop-off at the departure terminal',
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
    nameAr: 'الأهرامات والمتحف القومي وكورنيش النيل',
    shortDescription:
        'يتجه المسافر إلى منطقة أهرامات الجيزة لزيارة هضبة الأهرامات وأبو الهول والتجول داخل المنطقة وقضاء نحو ثلاث ساعات ثم الانتقال إلى المتحف القومي للحضارة المصرية للتعرف على تاريخ الحضارة المصرية ومشاهدة قاعة المومياوات الملكية وقضاء نحو ساعة ونصف، يلي ذلك التوجه إلى كورنيش النيل في الفسطاط للاستمتاع بالمشهد العام وتناول وجبة خفيفة قبل العودة إلى مطار القاهرة الدولي.',
    shortDescriptionEn:
        'Head to the Giza Pyramids to visit the pyramid plateau and the Sphinx, exploring the area for about three hours, then transfer to the National Museum of Egyptian Civilization to discover Egyptian history and view the Royal Mummies Hall for about one and a half hours, followed by a stop at the Nile Corniche in Fustat to enjoy the views and have a light meal before returning to Cairo International Airport.',
    durationHours: 8,
    durationHoursExact: 8.0,
    priceUsd: 220,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Kheops-Pyramid.jpg/1280px-Kheops-Pyramid.jpg',
    accentColor: const Color(0xFFD4A843),
    routeLabel:
        'المطار → أهرامات الجيزة → المتحف القومي → كورنيش الفسطاط → المطار',
    routeLabelEn:
        'Airport → Giza Pyramids → NMEC → Fustat Corniche → Airport',
    includedKeys: ['incl_airport_transfer', 'incl_tour_guide', 'incl_entry_tickets', 'incl_light_meal'],
    itinerary: [
      TransitStop(
        title: 'استقبال – مطار القاهرة الدولي',
        titleEn: 'Pickup – Cairo International Airport',
        subtitle: 'استقبال المسافر والانتقال بسيارة سياحية مريحة',
        subtitleEn: 'Meet the traveler and transfer by comfortable tourist vehicle',
        duration: '30 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TransitStop(
        title: 'أهرامات الجيزة وأبو الهول',
        titleEn: 'Giza Pyramids & the Sphinx',
        subtitle: 'زيارة هضبة الأهرامات والتجول داخل المنطقة ومشاهدة أبو الهول',
        subtitleEn: 'Visit the pyramid plateau, explore the area and see the Sphinx',
        duration: '3 hours',
        icon: Icons.landscape_rounded,
        color: Color(0xFFD4A843),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Kheops-Pyramid.jpg/1280px-Kheops-Pyramid.jpg',
      ),
      TransitStop(
        title: 'المتحف القومي للحضارة المصرية',
        titleEn: 'National Museum of Egyptian Civilization',
        subtitle:
            'التعرف على تاريخ الحضارة المصرية ومشاهدة قاعة المومياوات الملكية',
        subtitleEn: 'Explore Egyptian civilization history and view the Royal Mummies Hall',
        duration: '1.5 hours',
        icon: Icons.museum_rounded,
        color: Color(0xFFE02850),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/NMEC-MainEntrance.jpg/1280px-NMEC-MainEntrance.jpg',
      ),
      TransitStop(
        title: 'كورنيش النيل – الفسطاط',
        titleEn: 'Nile Corniche – Fustat',
        subtitle: 'الاستمتاع بالمشهد العام وتناول وجبة خفيفة',
        subtitleEn: 'Enjoy the views and have a light meal',
        duration: '1 hour',
        icon: Icons.water_rounded,
        color: Color(0xFF0D7377),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/54/Cairo_skyline%2C_Nile_River%2C_Egypt.jpg/1280px-Cairo_skyline%2C_Nile_River%2C_Egypt.jpg',
      ),
      TransitStop(
        title: 'العودة إلى مطار القاهرة الدولي',
        titleEn: 'Return to Cairo International Airport',
        subtitle: 'التوصيل المباشر إلى صالة المغادرة',
        subtitleEn: 'Direct drop-off at the departure terminal',
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
    nameAr: 'حديقة الأزهر والقلعة وخان الخليلي والقاهرة القبطية',
    shortDescription:
        'مطار القاهرة الدولي — يتم استقبال المسافر داخل المطار ثم الانتقال بسيارة سياحية مريحة إلى أول نقطة زيارة. خلال البرنامج يتم التوجه إلى حديقة الأزهر للتجول وسط المساحات الخضراء والاستمتاع بإطلالة بانورامية على القاهرة القديمة، وهي تجربة هادئة ومناسبة للتصوير. بعد ذلك يتم الانتقال إلى قلعة صلاح الدين حيث يمكن مشاهدة أسوار القلعة التاريخية وإطلالة علوية على المدينة مع شرح تاريخي مختصر. تستغرق الزيارتان نحو ساعتين إجمالًا. يلي ذلك زيارة خان الخليلي للتجول في السوق التاريخي وشراء الهدايا التذكارية وتناول مشروب أو وجبة خفيفة لمدة نحو ساعة. في ختام الجولة يتم التوجه إلى منطقة القاهرة القبطية لزيارة الكنيسة المعلقة والتعرف على أحد أقدم المعالم الدينية في مصر في زيارة قصيرة مدتها نحو 30 دقيقة.',
    shortDescriptionEn:
        'Cairo International Airport — the traveler is met inside the airport then transferred by comfortable tourist vehicle to the first stop. The program includes a visit to Al-Azhar Park to stroll through green spaces and enjoy a panoramic view of Old Cairo, a peaceful experience ideal for photography. Then transfer to the Saladin Citadel to see the historic fortress walls and enjoy an aerial city view with a brief historical narration. Both visits take about two hours total. Next, visit Khan El-Khalili to explore the historic bazaar, buy souvenirs and have a drink or light snack for about an hour. The tour concludes with a visit to the Hanging Church in Coptic Cairo, one of Egypt\'s oldest religious landmarks, in a short 30-minute stop.',
    durationHours: 4,
    durationHoursExact: 4.0,
    priceUsd: 160,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/Al-Azhar_Park_Kairo_04.jpg/1280px-Al-Azhar_Park_Kairo_04.jpg',
    accentColor: const Color(0xFF4CAF50),
    routeLabel:
        'المطار → حديقة الأزهر → قلعة صلاح الدين → خان الخليلي → الكنيسة المعلقة → المطار',
    routeLabelEn:
        'Airport → Azhar Park → Saladin Citadel → Khan El-Khalili → Hanging Church → Airport',
    includedKeys: ['incl_airport_transfer', 'incl_tour_guide', 'incl_entry_tickets', 'incl_drink'],
    itinerary: [
      TransitStop(
        title: 'استقبال – مطار القاهرة الدولي',
        titleEn: 'Pickup – Cairo International Airport',
        subtitle: 'استقبال المسافر والانتقال بسيارة سياحية مريحة',
        subtitleEn: 'Meet the traveler and transfer by comfortable tourist vehicle',
        duration: '25 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TransitStop(
        title: 'حديقة الأزهر',
        titleEn: 'Al-Azhar Park',
        subtitle:
            'التجول وسط المساحات الخضراء والاستمتاع بإطلالة بانورامية على القاهرة القديمة',
        subtitleEn: 'Stroll through green spaces and enjoy a panoramic view of Old Cairo',
        duration: '1 hour',
        icon: Icons.park_rounded,
        color: Color(0xFF4CAF50),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/Al-Azhar_Park_Kairo_04.jpg/1280px-Al-Azhar_Park_Kairo_04.jpg',
      ),
      TransitStop(
        title: 'قلعة صلاح الدين',
        titleEn: 'Saladin Citadel',
        subtitle:
            'مشاهدة أسوار القلعة التاريخية وإطلالة علوية على المدينة مع شرح تاريخي مختصر',
        subtitleEn: 'See the historic fortress walls and enjoy an aerial city view with a brief historical narration',
        duration: '1 hour',
        icon: Icons.fort_rounded,
        color: Color(0xFFE02850),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Cairo_Citadel_DSCF3411.jpg/1280px-Cairo_Citadel_DSCF3411.jpg',
      ),
      TransitStop(
        title: 'خان الخليلي',
        titleEn: 'Khan El-Khalili',
        subtitle:
            'التجول في السوق التاريخي وشراء الهدايا التذكارية وتناول مشروب أو وجبة خفيفة',
        subtitleEn: 'Explore the historic bazaar, buy souvenirs and have a drink or light snack',
        duration: '1 hour',
        icon: Icons.shopping_bag_rounded,
        color: Color(0xFFE87832),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Khan_el-Khalili_2019.jpg/1280px-Khan_el-Khalili_2019.jpg',
      ),
      TransitStop(
        title: 'الكنيسة المعلقة – القاهرة القبطية',
        titleEn: 'Hanging Church – Coptic Cairo',
        subtitle: 'زيارة أحد أقدم المعالم الدينية في مصر',
        subtitleEn: 'Visit one of Egypt\'s oldest religious landmarks',
        duration: '30 min',
        icon: Icons.church_rounded,
        color: Color(0xFF4A44AA),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Hanging_Church_Cairo.jpg/1280px-Hanging_Church_Cairo.jpg',
      ),
      TransitStop(
        title: 'العودة إلى مطار القاهرة الدولي',
        titleEn: 'Return to Cairo International Airport',
        subtitle: 'التوصيل المباشر إلى صالة المغادرة',
        subtitleEn: 'Direct drop-off at the departure terminal',
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
    nameAr: 'قصر عابدين والكنيسة المعلقة وحديقة الأزهر',
    shortDescription:
        'ينطلق المسافر من مطار القاهرة الدولي متوجهاً إلى قصر عابدين لزيارة القاعات الملكية والتعرف على تاريخ أسرة محمد علي لمدة ساعة، ثم الانتقال إلى الكنيسة المعلقة في منطقة مصر القديمة لاستكشاف أحد أقدم الكنائس في مصر وقضاء نحو 45 دقيقة، يلي ذلك التوجه إلى حديقة الأزهر للاستمتاع بإطلالة رائعة على القاهرة وتناول مشروب خفيف لمدة 45 دقيقة، ثم العودة إلى مطار القاهرة الدولي.',
    shortDescriptionEn:
        'Depart from Cairo International Airport to Abdeen Palace to visit the royal halls and learn about the Muhammad Ali dynasty for one hour, then transfer to the Hanging Church in Old Cairo to explore one of Egypt\'s oldest churches for about 45 minutes, followed by a visit to Al-Azhar Park to enjoy a stunning view of Cairo and have a light drink for 45 minutes, then return to Cairo International Airport.',
    durationHours: 3,
    durationHoursExact: 3.0,
    priceUsd: 130,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Abdeen_Palace.jpg/1280px-Abdeen_Palace.jpg',
    accentColor: const Color(0xFF4A44AA),
    routeLabel: 'المطار → قصر عابدين → الكنيسة المعلقة → حديقة الأزهر → المطار',
    routeLabelEn: 'Airport → Abdeen Palace → Hanging Church → Azhar Park → Airport',
    includedKeys: ['incl_airport_transfer', 'incl_tour_guide', 'incl_entry_tickets'],
    itinerary: [
      TransitStop(
        title: 'استقبال – مطار القاهرة الدولي',
        titleEn: 'Pickup – Cairo International Airport',
        subtitle: 'استقبال المسافر والانتقال بسيارة سياحية مريحة',
        subtitleEn: 'Meet the traveler and transfer by comfortable tourist vehicle',
        duration: '20 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TransitStop(
        title: 'قصر عابدين',
        titleEn: 'Abdeen Palace',
        subtitle: 'زيارة القاعات الملكية والتعرف على تاريخ أسرة محمد علي',
        subtitleEn: 'Visit the royal halls and learn about the Muhammad Ali dynasty',
        duration: '1 hour',
        icon: Icons.castle_rounded,
        color: Color(0xFF4A44AA),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Abdeen_Palace.jpg/1280px-Abdeen_Palace.jpg',
      ),
      TransitStop(
        title: 'الكنيسة المعلقة – مصر القديمة',
        titleEn: 'Hanging Church – Old Cairo',
        subtitle: 'استكشاف أحد أقدم الكنائس في مصر',
        subtitleEn: 'Explore one of the oldest churches in Egypt',
        duration: '45 min',
        icon: Icons.church_rounded,
        color: Color(0xFF8B6F47),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Hanging_Church_Cairo.jpg/1280px-Hanging_Church_Cairo.jpg',
      ),
      TransitStop(
        title: 'حديقة الأزهر',
        titleEn: 'Al-Azhar Park',
        subtitle: 'إطلالة رائعة على القاهرة وتناول مشروب خفيف',
        subtitleEn: 'Stunning view of Cairo and a light drink',
        duration: '45 min',
        icon: Icons.park_rounded,
        color: Color(0xFF4CAF50),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/Al-Azhar_Park_Kairo_04.jpg/1280px-Al-Azhar_Park_Kairo_04.jpg',
      ),
      TransitStop(
        title: 'العودة إلى مطار القاهرة الدولي',
        titleEn: 'Return to Cairo International Airport',
        subtitle: 'التوصيل المباشر إلى صالة المغادرة',
        subtitleEn: 'Direct drop-off at the departure terminal',
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
    nameAr: 'القلعة وشارع المعز ومقهى نيلي',
    shortDescription:
        'ينطلق المسافر من مطار القاهرة الدولي متوجهاً إلى قلعة صلاح الدين الأيوبي للاستمتاع بجولة لمدة ساعة ونصف وزيارة مسجد محمد علي ومشاهدة الإطلالة البانورامية على القاهرة، ثم الانتقال إلى شارع المعز والتجول بين المباني الأثرية والأسواق التاريخية وصولاً إلى خان الخليلي لقضاء وقت ممتع وشراء الهدايا التذكارية لمدة ساعة ونصف، يلي ذلك التوجه إلى أحد المقاهي المطلة على نهر النيل في وسط القاهرة للاستمتاع بالمشهد العام وتناول مشروب أو وجبة خفيفة لمدة ساعة، ثم العودة إلى مطار القاهرة الدولي.',
    shortDescriptionEn:
        'Depart from Cairo International Airport to the Saladin Citadel for a one-and-a-half-hour tour visiting the Muhammad Ali Mosque and enjoying the panoramic view of Cairo, then transfer to Al-Muizz Street to stroll among historic buildings and markets leading to Khan El-Khalili for souvenirs and fun for one and a half hours, followed by a visit to a Nile-view café in central Cairo for a drink or light snack for one hour, then return to Cairo International Airport.',
    durationHours: 5,
    durationHoursExact: 5.0,
    priceUsd: 160,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Cairo_Citadel_DSCF3411.jpg/1280px-Cairo_Citadel_DSCF3411.jpg',
    accentColor: const Color(0xFFE02850),
    routeLabel:
        'المطار → القلعة → شارع المعز → خان الخليلي → مقهى نيلي → المطار',
    routeLabelEn:
        'Airport → Citadel → Al-Muizz St. → Khan El-Khalili → Nile Café → Airport',
    includedKeys: ['incl_airport_transfer', 'incl_tour_guide', 'incl_citadel_tickets', 'incl_drink'],
    itinerary: [
      TransitStop(
        title: 'استقبال – مطار القاهرة الدولي',
        titleEn: 'Pickup – Cairo International Airport',
        subtitle: 'استقبال المسافر والانتقال بسيارة سياحية مريحة',
        subtitleEn: 'Meet the traveler and transfer by comfortable tourist vehicle',
        duration: '25 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TransitStop(
        title: 'قلعة صلاح الدين الأيوبي',
        titleEn: 'Saladin Citadel',
        subtitle:
            'زيارة مسجد محمد علي ومشاهدة الإطلالة البانورامية على القاهرة',
        subtitleEn: 'Visit the Muhammad Ali Mosque and enjoy the panoramic view of Cairo',
        duration: '1.5 hours',
        icon: Icons.fort_rounded,
        color: Color(0xFFE02850),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Cairo_Citadel_DSCF3411.jpg/1280px-Cairo_Citadel_DSCF3411.jpg',
      ),
      TransitStop(
        title: 'شارع المعز وخان الخليلي',
        titleEn: 'Al-Muizz Street & Khan El-Khalili',
        subtitle:
            'التجول بين المباني الأثرية والأسواق التاريخية وشراء الهدايا التذكارية',
        subtitleEn: 'Stroll among historic buildings and markets, and buy souvenirs',
        duration: '1.5 hours',
        icon: Icons.storefront_rounded,
        color: Color(0xFF8B6F47),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Khan_el-Khalili_2019.jpg/1280px-Khan_el-Khalili_2019.jpg',
      ),
      TransitStop(
        title: 'مقهى مطل على نهر النيل',
        titleEn: 'Nile-view Café',
        subtitle: 'الاستمتاع بالمشهد العام وتناول مشروب أو وجبة خفيفة',
        subtitleEn: 'Enjoy the views and have a drink or light snack',
        duration: '1 hour',
        icon: Icons.local_cafe_rounded,
        color: Color(0xFF0D7377),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Cairo_Tower_and_Qasr_El_Nil_Bridge.jpg/1280px-Cairo_Tower_and_Qasr_El_Nil_Bridge.jpg',
      ),
      TransitStop(
        title: 'العودة إلى مطار القاهرة الدولي',
        titleEn: 'Return to Cairo International Airport',
        subtitle: 'التوصيل المباشر إلى صالة المغادرة',
        subtitleEn: 'Direct drop-off at the departure terminal',
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
    nameAr: 'الأهرامات والمتحف المصري وحديقة الأزهر وخان الخليلي',
    shortDescription:
        'ينطلق المسافر من مطار القاهرة الدولي متوجهاً إلى أهرامات الجيزة لزيارة هضبة الأهرامات والتجول بالمنطقة ومشاهدة أبو الهول وقضاء نحو ثلاث ساعات، ثم الانتقال إلى المتحف المصري بالتحرير للتعرف على كنوز الحضارة المصرية القديمة ومشاهدة أهم القطع الأثرية لمدة ساعتين، يلي ذلك التوجه إلى حديقة الأزهر للاستمتاع بالمشي وإطلالة بانورامية على القاهرة التاريخية لمدة ساعة ونصف، ثم زيارة خان الخليلي للتسوق وقضاء وقت حر لمدة ساعة ونصف قبل العودة إلى مطار القاهرة الدولي.',
    shortDescriptionEn:
        'Depart from Cairo International Airport to the Giza Pyramids to visit the pyramid plateau, explore the area and see the Sphinx for about three hours, then transfer to the Egyptian Museum in Tahrir to discover treasures of ancient Egyptian civilization and view key artifacts for two hours, followed by a visit to Al-Azhar Park for a walk and panoramic view of historic Cairo for one and a half hours, then visit Khan El-Khalili for shopping and free time for one and a half hours before returning to Cairo International Airport.',
    durationHours: 9,
    durationHoursExact: 9.0,
    priceUsd: 250,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Kheops-Pyramid.jpg/1280px-Kheops-Pyramid.jpg',
    accentColor: const Color(0xFFD4A843),
    routeLabel:
        'المطار → الأهرامات → المتحف المصري → حديقة الأزهر → خان الخليلي → المطار',
    routeLabelEn:
        'Airport → Pyramids → Egyptian Museum → Azhar Park → Khan El-Khalili → Airport',
    includedKeys: ['incl_airport_transfer', 'incl_tour_guide', 'incl_entry_tickets', 'incl_light_meal'],
    itinerary: [
      TransitStop(
        title: 'استقبال – مطار القاهرة الدولي',
        titleEn: 'Pickup – Cairo International Airport',
        subtitle: 'استقبال المسافر والانتقال بسيارة سياحية مريحة',
        subtitleEn: 'Meet the traveler and transfer by comfortable tourist vehicle',
        duration: '30 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TransitStop(
        title: 'أهرامات الجيزة وأبو الهول',
        titleEn: 'Giza Pyramids & the Sphinx',
        subtitle: 'زيارة هضبة الأهرامات والتجول بالمنطقة ومشاهدة أبو الهول',
        subtitleEn: 'Visit the pyramid plateau, explore the area and see the Sphinx',
        duration: '3 hours',
        icon: Icons.landscape_rounded,
        color: Color(0xFFD4A843),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Kheops-Pyramid.jpg/1280px-Kheops-Pyramid.jpg',
      ),
      TransitStop(
        title: 'المتحف المصري بالتحرير',
        titleEn: 'Egyptian Museum – Tahrir',
        subtitle:
            'التعرف على كنوز الحضارة المصرية القديمة ومشاهدة أهم القطع الأثرية',
        subtitleEn: 'Discover treasures of ancient Egyptian civilization and view key artifacts',
        duration: '2 hours',
        icon: Icons.museum_rounded,
        color: Color(0xFFE02850),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/71/The_Egyptian_Museum.jpg/1280px-The_Egyptian_Museum.jpg',
      ),
      TransitStop(
        title: 'حديقة الأزهر',
        titleEn: 'Al-Azhar Park',
        subtitle: 'الاستمتاع بالمشي وإطلالة بانورامية على القاهرة التاريخية',
        subtitleEn: 'Enjoy a walk and a panoramic view of historic Cairo',
        duration: '1.5 hours',
        icon: Icons.park_rounded,
        color: Color(0xFF4CAF50),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/Al-Azhar_Park_Kairo_04.jpg/1280px-Al-Azhar_Park_Kairo_04.jpg',
      ),
      TransitStop(
        title: 'خان الخليلي',
        titleEn: 'Khan El-Khalili',
        subtitle: 'التسوق وقضاء وقت حر في السوق التاريخي',
        subtitleEn: 'Shopping and free time in the historic bazaar',
        duration: '1.5 hours',
        icon: Icons.shopping_bag_rounded,
        color: Color(0xFFE87832),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Khan_el-Khalili_2019.jpg/1280px-Khan_el-Khalili_2019.jpg',
      ),
      TransitStop(
        title: 'العودة إلى مطار القاهرة الدولي',
        titleEn: 'Return to Cairo International Airport',
        subtitle: 'التوصيل المباشر إلى صالة المغادرة',
        subtitleEn: 'Direct drop-off at the departure terminal',
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
    nameAr: 'قصر البارون والمتحف القومي وحديقة الأزهر',
    shortDescription:
        'ينطلق المسافر من مطار القاهرة الدولي متوجهاً إلى قصر البارون إمبان للاستمتاع بزيارة قصيرة والتعرف على طرازه المعماري المميز لمدة ساعة تقريبًا، ثم الانتقال إلى المتحف القومي للحضارة المصرية للتعرف على تاريخ الحضارة المصرية ومشاهدة أبرز المعروضات لمدة ساعة ونصف، يلي ذلك التوجه إلى حديقة الأزهر للاستمتاع بالمشي وسط المساحات الخضراء وإطلالة مميزة على القاهرة مع وقت لتناول مشروب أو وجبة خفيفة لمدة ساعة، ثم العودة إلى مطار القاهرة الدولي.',
    shortDescriptionEn:
        'Depart from Cairo International Airport to Baron Empain Palace for a short visit to admire its distinctive architecture for about one hour, then transfer to the National Museum of Egyptian Civilization to explore Egyptian history and view the main exhibits for one and a half hours, followed by a visit to Al-Azhar Park to walk through green spaces, enjoy a scenic view of Cairo and have a drink or light snack for one hour, then return to Cairo International Airport.',
    durationHours: 5,
    durationHoursExact: 5.0,
    priceUsd: 155,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Baron_Empain_Palace_in_Heliopolis.jpg/1280px-Baron_Empain_Palace_in_Heliopolis.jpg',
    accentColor: const Color(0xFF4CAF50),
    routeLabel: 'المطار → قصر البارون → المتحف القومي → حديقة الأزهر → المطار',
    routeLabelEn: 'Airport → Baron Palace → NMEC → Azhar Park → Airport',
    includedKeys: ['incl_airport_transfer', 'incl_tour_guide', 'incl_entry_tickets', 'incl_drink'],
    itinerary: [
      TransitStop(
        title: 'استقبال – مطار القاهرة الدولي',
        titleEn: 'Pickup – Cairo International Airport',
        subtitle: 'استقبال المسافر والانتقال بسيارة سياحية مريحة',
        subtitleEn: 'Meet the traveler and transfer by comfortable tourist vehicle',
        duration: '20 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TransitStop(
        title: 'قصر البارون إمبان',
        titleEn: 'Baron Empain Palace',
        subtitle: 'زيارة قصيرة والتعرف على طرازه المعماري المميز والتقاط الصور',
        subtitleEn: 'Short visit to admire its distinctive architecture and take photos',
        duration: '1 hour',
        icon: Icons.castle_rounded,
        color: Color(0xFFD4A843),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Baron_Empain_Palace_in_Heliopolis.jpg/1280px-Baron_Empain_Palace_in_Heliopolis.jpg',
      ),
      TransitStop(
        title: 'المتحف القومي للحضارة المصرية',
        titleEn: 'National Museum of Egyptian Civilization',
        subtitle: 'التعرف على تاريخ الحضارة المصرية ومشاهدة أبرز المعروضات',
        subtitleEn: 'Explore Egyptian civilization history and view the main exhibits',
        duration: '1.5 hours',
        icon: Icons.museum_rounded,
        color: Color(0xFFE02850),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/NMEC-MainEntrance.jpg/1280px-NMEC-MainEntrance.jpg',
      ),
      TransitStop(
        title: 'حديقة الأزهر',
        titleEn: 'Al-Azhar Park',
        subtitle:
            'الاستمتاع بالمشي وسط المساحات الخضراء وإطلالة مميزة مع تناول مشروب أو وجبة خفيفة',
        subtitleEn: 'Walk through green spaces, enjoy a scenic view and have a drink or light snack',
        duration: '1 hour',
        icon: Icons.park_rounded,
        color: Color(0xFF4CAF50),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/Al-Azhar_Park_Kairo_04.jpg/1280px-Al-Azhar_Park_Kairo_04.jpg',
      ),
      TransitStop(
        title: 'العودة إلى مطار القاهرة الدولي',
        titleEn: 'Return to Cairo International Airport',
        subtitle: 'التوصيل المباشر إلى صالة المغادرة',
        subtitleEn: 'Direct drop-off at the departure terminal',
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
    nameAr: 'المتحف الكبير وسقارة وبرج القاهرة',
    shortDescription:
        'مطار القاهرة الدولي — يتم استقبال المسافر داخل مطار القاهرة الدولي ثم الانطلاق بسيارة سياحية مريحة بصحبة مرشد سياحي. تبدأ الجولة بزيارة المتحف المصري الكبير للتعرف على أبرز كنوز الحضارة المصرية وقضاء نحو ثلاث ساعات، ثم الانتقال إلى سقارة لزيارة هرم زوسر المدرج والتجول في المنطقة الأثرية لمدة ساعة ونصف. يلي ذلك التوجه إلى برج القاهرة للاستمتاع بإطلالة بانورامية على المدينة مع وقت لالتقاط الصور أو تناول مشروب لمدة ساعة، ثم العودة إلى مطار القاهرة الدولي.',
    shortDescriptionEn:
        'Cairo International Airport — the traveler is met inside the airport then departs by comfortable tourist vehicle with a tour guide. The tour begins with a visit to the Grand Egyptian Museum to discover the greatest treasures of Egyptian civilization for about three hours, then transfer to Saqqara to visit the Step Pyramid of Djoser and explore the archaeological area for one and a half hours. Next, head to Cairo Tower to enjoy a panoramic city view with time for photos or a drink for one hour, then return to Cairo International Airport.',
    durationHours: 8,
    durationHoursExact: 8.0,
    priceUsd: 230,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/Grand_Egyptian_Museum_-_EGWUG_Trip_%281%29.jpg/1280px-Grand_Egyptian_Museum_-_EGWUG_Trip_%281%29.jpg',
    accentColor: const Color(0xFF8B6F47),
    routeLabel: 'المطار → المتحف الكبير → سقارة → برج القاهرة → المطار',
    routeLabelEn: 'Airport → Grand Museum → Saqqara → Cairo Tower → Airport',
    includedKeys: ['incl_airport_transfer', 'incl_tour_guide', 'incl_entry_tickets', 'incl_drink'],
    itinerary: [
      TransitStop(
        title: 'استقبال – مطار القاهرة الدولي',
        titleEn: 'Pickup – Cairo International Airport',
        subtitle: 'استقبال المسافر والانطلاق بسيارة سياحية بصحبة مرشد سياحي',
        subtitleEn: 'Meet the traveler and depart by tourist vehicle with a tour guide',
        duration: '30 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TransitStop(
        title: 'المتحف المصري الكبير',
        titleEn: 'Grand Egyptian Museum',
        subtitle: 'التعرف على أبرز كنوز الحضارة المصرية',
        subtitleEn: 'Discover the greatest treasures of Egyptian civilization',
        duration: '3 hours',
        icon: Icons.museum_rounded,
        color: Color(0xFF8B6F47),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/Grand_Egyptian_Museum_-_EGWUG_Trip_%281%29.jpg/1280px-Grand_Egyptian_Museum_-_EGWUG_Trip_%281%29.jpg',
      ),
      TransitStop(
        title: 'سقارة – هرم زوسر المدرج',
        titleEn: 'Saqqara – Step Pyramid of Djoser',
        subtitle: 'زيارة أقدم هرم في مصر والتجول في المنطقة الأثرية',
        subtitleEn: 'Visit Egypt\'s oldest pyramid and explore the archaeological area',
        duration: '1.5 hours',
        icon: Icons.landscape_rounded,
        color: Color(0xFFD4A843),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Saqqara_BW_5.jpg/1280px-Saqqara_BW_5.jpg',
      ),
      TransitStop(
        title: 'برج القاهرة',
        titleEn: 'Cairo Tower',
        subtitle:
            'إطلالة بانورامية على المدينة مع وقت لالتقاط الصور أو تناول مشروب',
        subtitleEn: 'Panoramic city view with time for photos or a drink',
        duration: '1 hour',
        icon: Icons.cell_tower_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Cairo_Tower%2C_Egypt.jpg/1280px-Cairo_Tower%2C_Egypt.jpg',
      ),
      TransitStop(
        title: 'العودة إلى مطار القاهرة الدولي',
        titleEn: 'Return to Cairo International Airport',
        subtitle: 'التوصيل المباشر إلى صالة المغادرة',
        subtitleEn: 'Direct drop-off at the departure terminal',
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
    nameAr: 'المتحف القومي وقصر عابدين وممشى أهل مصر',
    shortDescription:
        'مطار القاهرة الدولي — يتم استقبال المسافر داخل مطار القاهرة الدولي ثم الانتقال بسيارة سياحية مريحة إلى أولى محطات الزيارة. خلال البرنامج يتم التوجه إلى المتحف القومي للحضارة المصرية في الفسطاط للتعرف على تطور الحضارة المصرية عبر العصور ومشاهدة قاعة المومياوات الملكية في زيارة تستغرق نحو ساعة ونصف. بعد ذلك يتم الانتقال إلى قصر عابدين لاستكشاف القاعات الملكية والتعرف على تاريخ الأسرة العلوية لمدة ساعة تقريبًا. يلي ذلك التوجه إلى ممشى أهل مصر على كورنيش النيل للاستمتاع بالمشهد العام والتقاط الصور وتناول مشروب أو وجبة خفيفة لمدة نحو 45 دقيقة.',
    shortDescriptionEn:
        'Cairo International Airport — the traveler is met inside the airport then transferred by comfortable tourist vehicle to the first stop. The program includes a visit to the National Museum of Egyptian Civilization in Fustat to explore the evolution of Egyptian civilization across the ages and view the Royal Mummies Hall in a visit lasting about one and a half hours. Then transfer to Abdeen Palace to explore the royal halls and learn about the ruling dynasty for about one hour. Next, head to Ahl Masr Walk on the Nile Corniche to enjoy the scenery, take photos and have a drink or light snack for about 45 minutes.',
    durationHours: 4,
    durationHoursExact: 4.0,
    priceUsd: 150,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/NMEC-MainEntrance.jpg/1280px-NMEC-MainEntrance.jpg',
    accentColor: const Color(0xFF0D7377),
    routeLabel: 'المطار → المتحف القومي → قصر عابدين → ممشى أهل مصر → المطار',
    routeLabelEn: 'Airport → NMEC → Abdeen Palace → Ahl Masr Walk → Airport',
    includedKeys: ['incl_airport_transfer', 'incl_tour_guide', 'incl_entry_tickets', 'incl_drink'],
    itinerary: [
      TransitStop(
        title: 'استقبال – مطار القاهرة الدولي',
        titleEn: 'Pickup – Cairo International Airport',
        subtitle: 'استقبال المسافر والانتقال بسيارة سياحية مريحة',
        subtitleEn: 'Meet the traveler and transfer by comfortable tourist vehicle',
        duration: '25 min',
        icon: Icons.flight_land_rounded,
        color: Color(0xFF187BCD),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TransitStop(
        title: 'المتحف القومي للحضارة المصرية – الفسطاط',
        titleEn: 'National Museum of Egyptian Civilization – Fustat',
        subtitle:
            'التعرف على تطور الحضارة المصرية عبر العصور ومشاهدة قاعة المومياوات الملكية',
        subtitleEn: 'Explore the evolution of Egyptian civilization and view the Royal Mummies Hall',
        duration: '1.5 hours',
        icon: Icons.museum_rounded,
        color: Color(0xFFE02850),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/NMEC-MainEntrance.jpg/1280px-NMEC-MainEntrance.jpg',
      ),
      TransitStop(
        title: 'قصر عابدين',
        titleEn: 'Abdeen Palace',
        subtitle: 'استكشاف القاعات الملكية والتعرف على تاريخ الأسرة العلوية',
        subtitleEn: 'Explore the royal halls and learn about the ruling dynasty',
        duration: '1 hour',
        icon: Icons.castle_rounded,
        color: Color(0xFF4A44AA),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Abdeen_Palace.jpg/1280px-Abdeen_Palace.jpg',
      ),
      TransitStop(
        title: 'ممشى أهل مصر – كورنيش النيل',
        titleEn: 'Ahl Masr Walk – Nile Corniche',
        subtitle:
            'الاستمتاع بالمشهد العام والتقاط الصور وتناول مشروب أو وجبة خفيفة',
        subtitleEn: 'Enjoy the scenery, take photos and have a drink or light snack',
        duration: '45 min',
        icon: Icons.water_rounded,
        color: Color(0xFF0D7377),
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Cairo_Nile_River.jpg/1280px-Cairo_Nile_River.jpg',
      ),
      TransitStop(
        title: 'العودة إلى مطار القاهرة الدولي',
        titleEn: 'Return to Cairo International Airport',
        subtitle: 'التوصيل المباشر إلى صالة المغادرة',
        subtitleEn: 'Direct drop-off at the departure terminal',
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
  List<String> _getFilters(bool isAr) => [
    S.tr('all_filter', isAr), '≤4h', '4–8h', '8h+'
  ];

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
        return transitTrips.where((t) => t.durationHours <= 4).toList();
      case 2:
        return transitTrips
            .where((t) => t.durationHours > 4 && t.durationHours <= 8)
            .toList();
      case 3:
        return transitTrips.where((t) => t.durationHours > 8).toList();
      default:
        return transitTrips;
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
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (c, a, s) => TransitTripDetailPage(trip: trip),
        transitionsBuilder: (c, a, s, child) => ScaleTransition(
          scale: Tween<double>(
            begin: 0.92,
            end: 1.0,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: FadeTransition(
            opacity: CurvedAnimation(parent: a, curve: Curves.easeOutCubic),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.12, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final isAr = context.watch<LanguageProvider>().isArabic;
    final tripSvc = context.watch<TripService>();
    final liveTrips = tripSvc.activeTrips.where((t) => t.type == TripType.transit).toList();
    
    // Combine local data with live data, avoiding duplicates by name
    final allTrips = <TransitTrip>[];
    
    // Add live trips from Firebase
    for (final lt in liveTrips) {
      allTrips.add(TransitTrip(
        name: lt.name,
        nameAr: lt.nameAr,
        shortDescription: lt.shortDescription,
        durationHours: (lt.durationMinutes / 60).ceil(),
        durationHoursExact: lt.durationMinutes / 60.0,
        priceUsd: lt.priceUsd.toInt(),
        imageUrl: lt.imageUrl,
        accentColor: lt.accentColor,
        routeLabel: lt.routeLabel,
        itinerary: lt.itinerary.map((s) => TransitStop(
          title: s.title,
          subtitle: s.subtitle,
          duration: s.duration,
          icon: s.icon,
          color: s.color,
          imageUrl: s.imageUrl,
        )).toList(),
        includedKeys: lt.included,
      ));
    }
    
    // Add local trips that aren't in Firebase yet (by name)
    for (final local in transitTrips) {
      if (!allTrips.any((t) => t.name == local.name)) {
        allTrips.add(local);
      }
    }

    final trips = _filterIndex == 0 
        ? allTrips 
        : allTrips.where((t) {
            final h = t.durationHoursExact;
            if (_filterIndex == 1) return h <= 3;
            if (_filterIndex == 2) return h > 3 && h <= 6;
            return h > 6;
          }).toList();

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
                            S.tr('transit_page_title', isAr),
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
                                  S.tr('cairo_airport', isAr),
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
                        S.tr('transit_subtitle', isAr),
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
                          children: List.generate(_getFilters(isAr).length, (i) {
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
                                  _getFilters(isAr)[i],
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
                              S.tr('no_filter_trips', isAr),
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
                                isAr: isAr,
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
                    onTap: () {
                      SmoothNavigation.zoomIn(
                        context,
                        (context) => const ChatBotPage(),
                        routeName: 'chatbot_transit',
                      );
                    },
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
                                  S.tr('find_best_trip_banner', isAr),
                                  style: roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  S.tr('ai_recommendations', isAr),
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
  final bool isAr;

  const _TimelineRow({
    required this.trip,
    required this.isLast,
    required this.index,
    required this.onTap,
    this.isAr = false,
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
                            trip.localizedName(isAr),
                            style: roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            trip.localizedShortDescription(isAr),
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
                                  trip.localizedRouteLabel(isAr),
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
                                      '${trip.durationHours} ${S.tr('hours_label', isAr)}',
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
                                    S.tr('details_button', isAr),
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
