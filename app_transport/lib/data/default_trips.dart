import '../models/trip_model.dart';

final defaultTrips = <TripModel>[
  TripModel(
    id: 'flying_1',
    type: TripType.flying,
    name: 'Citadel & Nile Aerial Tour',
    description:
        'Depart from Cairo Airport for a panoramic flight over the Citadel and the Nile Corniche before returning to the airport terminal.',
    durationMinutes: 70,
    flightMinutes: 15,
    priceUsd: 120,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Cairo_Citadel_DSCF3411.jpg/1280px-Cairo_Citadel_DSCF3411.jpg',
    accentColorValue: 0xFF8B4513,
    routeLabel:
        'Airport -> Takeoff -> Citadel -> Nile -> Corniche -> Landing -> Airport',
    mapHint:
        'Cairo Airport -> Takeoff -> Citadel -> Nile -> Corniche -> Landing -> Airport',
    locationLabel: 'Cairo International Airport',
  ),
  TripModel(
    id: 'flying_2',
    type: TripType.flying,
    name: 'Nile & Corniche Quick Flight',
    description:
        'A short panoramic flight along the Nile River and Cairo Corniche, ideal for tight transit schedules.',
    durationMinutes: 40,
    flightMinutes: 13,
    priceUsd: 100,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Cairo_Nile_River.jpg/1280px-Cairo_Nile_River.jpg',
    accentColorValue: 0xFF187BCD,
    routeLabel:
        'Airport -> Takeoff -> Nile -> Corniche -> East Cairo -> Landing -> Airport',
    mapHint:
        'Cairo Airport -> Takeoff -> Nile -> Corniche -> East Cairo -> Landing -> Airport',
    locationLabel: 'Cairo International Airport',
  ),
  TripModel(
    id: 'flying_3',
    type: TripType.flying,
    name: 'Pyramids & Landmarks Flight',
    description:
        'A full scenic loop covering the Pyramids of Giza, the Sphinx, Cairo Tower, and the Citadel.',
    durationMinutes: 120,
    flightMinutes: 30,
    priceUsd: 240,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/9/96/Pyramids_of_the_Giza_Necropolis.jpg/1280px-Pyramids_of_the_Giza_Necropolis.jpg',
    accentColorValue: 0xFFD4A843,
    routeLabel:
        'Airport -> Pyramids -> Sphinx -> Cairo Tower -> Citadel -> Landing -> Airport',
    mapHint:
        'Cairo Airport -> Pyramids -> Sphinx -> Cairo Tower -> Citadel -> Landing -> Airport',
    locationLabel: 'Cairo International Airport',
  ),
  TripModel(
    id: 'flying_4',
    type: TripType.flying,
    name: 'Nile & Cairo Tower Hop',
    description:
        'A compact flight over the Nile and Cairo Tower with quick return to the airport.',
    durationMinutes: 60,
    flightMinutes: 10,
    priceUsd: 85,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Cairo_Tower_and_Qasr_El_Nil_Bridge.jpg/1280px-Cairo_Tower_and_Qasr_El_Nil_Bridge.jpg',
    accentColorValue: 0xFF4A44AA,
    routeLabel:
        'Airport -> Takeoff -> Nile -> Corniche -> Cairo Tower -> Landing -> Airport',
    mapHint:
        'Cairo Airport -> Takeoff -> Nile -> Corniche -> Cairo Tower -> Landing -> Airport',
    locationLabel: 'Cairo International Airport',
  ),
  TripModel(
    id: 'flying_5',
    type: TripType.flying,
    name: 'Modern Cairo Skyline Loop',
    description:
        'A panoramic route over modern Cairo districts and the Nile before returning to the airport.',
    durationMinutes: 75,
    flightMinutes: 18,
    priceUsd: 130,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Cairo_Nile_River.jpg/1280px-Cairo_Nile_River.jpg',
    accentColorValue: 0xFF0D7377,
    routeLabel:
        'Airport -> East Cairo -> Nile -> New Districts -> Landing -> Airport',
    mapHint:
        'Cairo Airport -> East Cairo -> Nile -> New Districts -> Landing -> Airport',
    locationLabel: 'Cairo International Airport',
  ),
  TripModel(
    id: 'flying_6',
    type: TripType.flying,
    name: 'Old Cairo & Historic Mosques',
    description:
        'Fly above Old Cairo and historic mosque districts with sweeping city views.',
    durationMinutes: 90,
    flightMinutes: 20,
    priceUsd: 150,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Cairo_Citadel_DSCF3411.jpg/1280px-Cairo_Citadel_DSCF3411.jpg',
    accentColorValue: 0xFF7B6CF6,
    routeLabel:
        'Airport -> Old Cairo -> Historic Mosques -> Nile -> Landing -> Airport',
    mapHint:
        'Cairo Airport -> Old Cairo -> Historic Mosques -> Nile -> Landing -> Airport',
    locationLabel: 'Cairo International Airport',
  ),
  TripModel(
    id: 'transit_1',
    type: TripType.transit,
    name: 'Baron Palace, Um Kulthum & Pharaonic Village',
    shortDescription:
        'A 6-hour transit tour visiting Baron Palace, Um Kulthum Museum, and the Pharaonic Village.',
    description:
        'Start at Cairo Airport, visit Baron Palace, continue to Um Kulthum Museum, then explore the Pharaonic Village before returning to the airport.',
    durationMinutes: 360,
    priceUsd: 180,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Baron_Empain_Palace_in_Heliopolis.jpg/1280px-Baron_Empain_Palace_in_Heliopolis.jpg',
    accentColorValue: 0xFFD4A843,
    routeLabel:
        'Airport -> Baron Palace -> Um Kulthum Museum -> Pharaonic Village -> Nile Walk -> Airport',
    included: ['Airport Transfer', 'Tour Guide', 'Entry Tickets', 'Light Meal'],
    itinerary: [
      TripStop(
        title: 'Cairo International Airport',
        subtitle: 'Meet and greet, private transfer pickup',
        duration: '20 min',
        iconName: 'flight_land',
        colorValue: 0xFF187BCD,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TripStop(
        title: 'Baron Palace',
        subtitle: 'Architecture tour and photo stop',
        duration: '1 hour',
        iconName: 'castle',
        colorValue: 0xFFD4A843,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Baron_Empain_Palace_in_Heliopolis.jpg/1280px-Baron_Empain_Palace_in_Heliopolis.jpg',
      ),
      TripStop(
        title: 'Um Kulthum Museum',
        subtitle: 'Discover the life of the legendary singer',
        duration: '1 hour',
        iconName: 'music',
        colorValue: 0xFFE02850,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/Manial_Palace.jpg/1280px-Manial_Palace.jpg',
      ),
      TripStop(
        title: 'Pharaonic Village',
        subtitle: 'Immersive experience of ancient Egypt',
        duration: '2 hours',
        iconName: 'account_balance',
        colorValue: 0xFF8B6F47,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/70/Pharaonic_Village.jpg/1280px-Pharaonic_Village.jpg',
      ),
      TripStop(
        title: 'Nile Walk',
        subtitle: 'Relaxing riverfront stop with a light meal',
        duration: '1 hour',
        iconName: 'water',
        colorValue: 0xFF0D7377,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Cairo_Nile_River.jpg/1280px-Cairo_Nile_River.jpg',
      ),
    ],
  ),
  TripModel(
    id: 'transit_2',
    type: TripType.transit,
    name: 'Baron Palace & City Stars Mall',
    shortDescription:
        'A 2-hour quick trip: Baron Palace then City Stars Mall shopping stop.',
    description:
        'A short transit tour to Baron Palace followed by a brief shopping or coffee break at City Stars Mall.',
    durationMinutes: 120,
    priceUsd: 100,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Baron_Empain_Palace_in_Heliopolis.jpg/1280px-Baron_Empain_Palace_in_Heliopolis.jpg',
    accentColorValue: 0xFF9C27B0,
    routeLabel: 'Airport -> Baron Palace -> City Stars -> Airport',
    included: ['Airport Transfer'],
    itinerary: [
      TripStop(
        title: 'Cairo International Airport',
        subtitle: 'Meet and greet, private transfer pickup',
        duration: '15 min',
        iconName: 'flight_land',
        colorValue: 0xFF187BCD,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/By_ovedc_-_Cairo_International_Airport_1.jpg/1280px-By_ovedc_-_Cairo_International_Airport_1.jpg',
      ),
      TripStop(
        title: 'Baron Palace',
        subtitle: 'Quick visit and photo stop',
        duration: '40 min',
        iconName: 'castle',
        colorValue: 0xFF9C27B0,
      ),
      TripStop(
        title: 'City Stars Mall',
        subtitle: 'Shopping or coffee break',
        duration: '30 min',
        iconName: 'shopping_cart',
        colorValue: 0xFFE87832,
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/Cairo_Tower%2C_Egypt.jpg/1280px-Cairo_Tower%2C_Egypt.jpg',
      ),
    ],
  ),
  TripModel(
    id: 'transit_3',
    type: TripType.transit,
    name: 'Egyptian Museum & Downtown Walk',
    shortDescription:
        'A 4-hour classic museum tour with a walk around Downtown Cairo.',
    description:
        'Visit the Egyptian Museum, then enjoy a guided walk through Downtown Cairo before heading back to the airport.',
    durationMinutes: 240,
    priceUsd: 140,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Mus%C3%A9e_%C3%A9gyptien_du_Caire.jpg/1280px-Mus%C3%A9e_%C3%A9gyptien_du_Caire.jpg',
    accentColorValue: 0xFF4A44AA,
    routeLabel: 'Airport -> Egyptian Museum -> Downtown Walk -> Airport',
    included: ['Airport Transfer', 'Entry Tickets', 'Tour Guide'],
    itinerary: [
      TripStop(
        title: 'Egyptian Museum',
        subtitle: 'Explore ancient artifacts and treasures',
        duration: '2 hours',
        iconName: 'museum',
        colorValue: 0xFF4A44AA,
      ),
      TripStop(
        title: 'Downtown Cairo',
        subtitle: 'Guided stroll and local insights',
        duration: '1.5 hours',
        iconName: 'walk',
        colorValue: 0xFF0D7377,
      ),
    ],
  ),
  TripModel(
    id: 'transit_4',
    type: TripType.transit,
    name: 'NMEC & Old Cairo Heritage',
    shortDescription:
        'A 4.5-hour tour through NMEC and heritage sites in Old Cairo.',
    description:
        'Visit the National Museum of Egyptian Civilization and explore the heritage landmarks of Old Cairo.',
    durationMinutes: 270,
    priceUsd: 160,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/National_Museum_of_Egyptian_Civilization.jpg/1280px-National_Museum_of_Egyptian_Civilization.jpg',
    accentColorValue: 0xFFE02850,
    routeLabel: 'Airport -> NMEC -> Old Cairo -> Airport',
    included: ['Airport Transfer', 'Tour Guide'],
    itinerary: [
      TripStop(
        title: 'NMEC',
        subtitle: 'Mummies hall and Egyptian civilization galleries',
        duration: '2 hours',
        iconName: 'museum',
        colorValue: 0xFFE02850,
      ),
      TripStop(
        title: 'Old Cairo',
        subtitle: 'Heritage churches and historic streets',
        duration: '1.5 hours',
        iconName: 'place',
        colorValue: 0xFF187BCD,
      ),
    ],
  ),
  TripModel(
    id: 'transit_5',
    type: TripType.transit,
    name: 'Khan El-Khalili & Al-Muizz Street',
    shortDescription:
        'A 3-hour market walk with historic Islamic Cairo highlights.',
    description:
        'Browse Khan El-Khalili bazaar and stroll along Al-Muizz Street before returning to the airport.',
    durationMinutes: 180,
    priceUsd: 110,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Khan_el-Khalili_2019.jpg/1280px-Khan_el-Khalili_2019.jpg',
    accentColorValue: 0xFF8B6F47,
    routeLabel: 'Airport -> Khan El-Khalili -> Al-Muizz -> Airport',
    included: ['Airport Transfer', 'Tour Guide'],
    itinerary: [
      TripStop(
        title: 'Khan El-Khalili',
        subtitle: 'Traditional market experience',
        duration: '1.5 hours',
        iconName: 'shopping_cart',
        colorValue: 0xFF8B6F47,
      ),
      TripStop(
        title: 'Al-Muizz Street',
        subtitle: 'Historic street and architecture',
        duration: '1 hour',
        iconName: 'castle',
        colorValue: 0xFF4A44AA,
      ),
    ],
  ),
  TripModel(
    id: 'transit_6',
    type: TripType.transit,
    name: 'Giza Pyramids Express',
    shortDescription:
        'A 5-hour express visit to the Pyramids and Sphinx.',
    description:
        'Visit the Pyramids of Giza and the Sphinx with a quick return to the airport.',
    durationMinutes: 300,
    priceUsd: 200,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/9/96/Pyramids_of_the_Giza_Necropolis.jpg/1280px-Pyramids_of_the_Giza_Necropolis.jpg',
    accentColorValue: 0xFFD4A843,
    routeLabel: 'Airport -> Pyramids -> Sphinx -> Airport',
    included: ['Airport Transfer', 'Tour Guide', 'Entry Tickets'],
    itinerary: [
      TripStop(
        title: 'Giza Pyramids',
        subtitle: 'Explore the Great Pyramid complex',
        duration: '2 hours',
        iconName: 'landscape',
        colorValue: 0xFFD4A843,
      ),
      TripStop(
        title: 'Great Sphinx',
        subtitle: 'Photo stop and guided commentary',
        duration: '45 min',
        iconName: 'fort',
        colorValue: 0xFF187BCD,
      ),
    ],
  ),
];
