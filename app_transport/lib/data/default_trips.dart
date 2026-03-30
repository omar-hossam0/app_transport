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
];
