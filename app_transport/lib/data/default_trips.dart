import '../models/trip_model.dart';

final defaultTrips = <TripModel>[
  // ── Flying Trips ──
  TripModel(
    id: 'flying_1',
    type: TripType.flying,
    name: 'Citadel & Nile Aerial Tour',
    nameAr: 'جولة جوية فوق القلعة والنيل',
    description:
        'Depart from Cairo Airport for a panoramic flight over the Citadel and the Nile Corniche before returning to the airport terminal.',
    descriptionAr:
        'انطلق من مطار القاهرة في جولة جوية بانورامية فوق القلعة وكورنيش النيل قبل العودة للمطار.',
    durationMinutes: 70,
    flightMinutes: 15,
    priceUsd: 120,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Cairo_Citadel_DSCF3411.jpg/1280px-Cairo_Citadel_DSCF3411.jpg',
    accentColorValue: 0xFF8B4513,
    routeLabel:
        'Airport → Citadel → Nile → Corniche → Airport',
    mapHint:
        'Cairo Airport → Citadel → Nile → Corniche → Airport',
    locationLabel: 'Cairo International Airport',
    locationLabelAr: 'مطار القاهرة الدولي',
  ),
  TripModel(
    id: 'flying_3',
    type: TripType.flying,
    name: 'Pyramids & Landmarks Flight',
    nameAr: 'جولة شاملة فوق الأهرامات والمعالم',
    description:
        'A full scenic loop covering the Pyramids of Giza, the Sphinx, Cairo Tower, and the Citadel.',
    descriptionAr:
        'جولة جوية شاملة فوق أهرامات الجيزة وأبو الهول وبرج القاهرة والقلعة.',
    durationMinutes: 120,
    flightMinutes: 30,
    priceUsd: 240,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/9/96/Pyramids_of_the_Giza_Necropolis.jpg/1280px-Pyramids_of_the_Giza_Necropolis.jpg',
    accentColorValue: 0xFFD4A843,
    routeLabel:
        'Airport → Pyramids → Sphinx → Cairo Tower → Citadel → Airport',
    mapHint:
        'Cairo Airport → Pyramids → Sphinx → Cairo Tower → Citadel → Airport',
    locationLabel: 'Cairo International Airport',
    locationLabelAr: 'مطار القاهرة الدولي',
  ),
  TripModel(
    id: 'flying_7',
    type: TripType.flying,
    name: 'New Capital Aerial Tour',
    nameAr: 'جولة فوق القاهرة الجديدة والعاصمة الإدارية',
    description:
        'Fly over New Cairo, the American University campus, and the New Administrative Capital.',
    descriptionAr:
        'تحليق فوق القاهرة الجديدة والجامعة الأمريكية والعاصمة الإدارية الجديدة.',
    durationMinutes: 90,
    flightMinutes: 25,
    priceUsd: 170,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dc/Central_business_district_1%2C_New_Administrative_Capital.jpg/1280px-Central_business_district_1%2C_New_Administrative_Capital.jpg',
    accentColorValue: 0xFF6A0DAD,
    routeLabel:
        'Airport → New Cairo → AUC → Administrative Capital → Airport',
    mapHint:
        'Cairo Airport → New Cairo → AUC → Administrative Capital → Airport',
    locationLabel: 'Cairo International Airport',
    locationLabelAr: 'مطار القاهرة الدولي',
  ),

  // ── Transit Trips ──
  TripModel(
    id: 'transit_default_1',
    type: TripType.transit,
    name: 'Baron Palace & Pharaonic Village',
    nameAr: 'قصر البارون والقرية الفرعونية',
    description:
        'Visit the stunning Baron Empain Palace in Heliopolis, then experience ancient Egyptian life at the Pharaonic Village, and end with a stroll along Ahl Masr Walkway.',
    descriptionAr:
        'زيارة قصر البارون إمبان في مصر الجديدة، ثم تجربة الحياة الفرعونية في القرية الفرعونية، وختام بممشى أهل مصر.',
    durationMinutes: 360,
    priceUsd: 180,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Baron_Empain_Palace_in_Heliopolis.jpg/1280px-Baron_Empain_Palace_in_Heliopolis.jpg',
    accentColorValue: 0xFFD4A843,
    routeLabel:
        'Airport → Baron Palace → Pharaonic Village → Ahl Masr → Airport',
    locationLabel: 'Cairo, Heliopolis',
    locationLabelAr: 'القاهرة، مصر الجديدة',
    included: ['Airport Transfer', 'Tour Guide', 'Entry Tickets', 'Light Meal'],
    itinerary: [
      TripStop(
        title: 'Cairo Airport Pickup',
        subtitle: 'Meet & greet at the airport',
        duration: '30 min',
        iconName: 'flight_land',
        colorValue: 0xFF187BCD,
      ),
      TripStop(
        title: 'Baron Empain Palace',
        subtitle: 'Explore the iconic Indian-style palace',
        duration: '1 hr',
        iconName: 'castle',
        colorValue: 0xFFD4A843,
      ),
      TripStop(
        title: 'Pharaonic Village',
        subtitle: 'Interactive ancient Egypt experience',
        duration: '2 hrs',
        iconName: 'account_balance',
        colorValue: 0xFF8B4513,
      ),
      TripStop(
        title: 'Ahl Masr Walkway',
        subtitle: 'Nile corniche walk & light meal',
        duration: '1 hr',
        iconName: 'directions_walk',
        colorValue: 0xFF0D7377,
      ),
    ],
  ),
  TripModel(
    id: 'transit_default_2',
    type: TripType.transit,
    name: 'Pyramids & Egyptian Museum Express',
    nameAr: 'الأهرامات والمتحف المصري',
    description:
        'A fast-paced tour from Cairo Airport to the Giza Pyramids, the Sphinx, and then the Grand Egyptian Museum before returning.',
    descriptionAr:
        'جولة سريعة من مطار القاهرة إلى أهرامات الجيزة وأبو الهول ثم المتحف المصري الكبير.',
    durationMinutes: 300,
    priceUsd: 220,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/9/96/Pyramids_of_the_Giza_Necropolis.jpg/1280px-Pyramids_of_the_Giza_Necropolis.jpg',
    accentColorValue: 0xFFFF8C00,
    routeLabel:
        'Airport → Pyramids → Sphinx → Grand Museum → Airport',
    locationLabel: 'Cairo / Giza',
    locationLabelAr: 'القاهرة / الجيزة',
    included: ['Airport Transfer', 'Tour Guide', 'Entry Tickets', 'Lunch'],
    itinerary: [
      TripStop(
        title: 'Cairo Airport Pickup',
        subtitle: 'Private car transfer',
        duration: '30 min',
        iconName: 'flight_land',
        colorValue: 0xFF187BCD,
      ),
      TripStop(
        title: 'Giza Pyramids & Sphinx',
        subtitle: 'Guided tour of the ancient wonders',
        duration: '2 hrs',
        iconName: 'landscape',
        colorValue: 0xFFFF8C00,
      ),
      TripStop(
        title: 'Grand Egyptian Museum',
        subtitle: 'World\'s largest archaeological museum',
        duration: '1.5 hrs',
        iconName: 'museum',
        colorValue: 0xFF4A44AA,
      ),
    ],
  ),
  TripModel(
    id: 'transit_default_3',
    type: TripType.transit,
    name: 'Old Cairo & Khan El-Khalili',
    nameAr: 'القاهرة القديمة وخان الخليلي',
    description:
        'Explore Islamic Cairo: visit the Citadel, Al-Muizz Street, Al-Azhar Mosque, and shop at Khan El-Khalili bazaar.',
    descriptionAr:
        'استكشف القاهرة الإسلامية: القلعة وشارع المعز والجامع الأزهر والتسوق في خان الخليلي.',
    durationMinutes: 240,
    priceUsd: 150,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Cairo_Citadel_DSCF3411.jpg/1280px-Cairo_Citadel_DSCF3411.jpg',
    accentColorValue: 0xFFE02850,
    routeLabel:
        'Airport → Citadel → Al-Muizz St → Khan El-Khalili → Airport',
    locationLabel: 'Islamic Cairo',
    locationLabelAr: 'القاهرة الإسلامية',
    included: ['Airport Transfer', 'Tour Guide', 'Light Snack'],
    itinerary: [
      TripStop(
        title: 'Cairo Airport Pickup',
        subtitle: 'Comfortable private transfer',
        duration: '30 min',
        iconName: 'flight_land',
        colorValue: 0xFF187BCD,
      ),
      TripStop(
        title: 'Saladin Citadel',
        subtitle: 'Mohamed Ali Mosque & panoramic views',
        duration: '1 hr',
        iconName: 'castle',
        colorValue: 0xFFE02850,
      ),
      TripStop(
        title: 'Al-Muizz Street',
        subtitle: 'Historic Islamic architecture walk',
        duration: '45 min',
        iconName: 'directions_walk',
        colorValue: 0xFF0D7377,
      ),
      TripStop(
        title: 'Khan El-Khalili',
        subtitle: 'Traditional bazaar shopping & tea',
        duration: '1 hr',
        iconName: 'store',
        colorValue: 0xFFD4A843,
      ),
    ],
  ),
];
