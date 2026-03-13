import 'package:flutter/material.dart';

enum TripType { flying, transit }

class TripStop {
  final String title;
  final String subtitle;
  final String duration;
  final String iconName;
  final int colorValue;
  final String imageUrl;

  const TripStop({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.iconName,
    required this.colorValue,
    this.imageUrl = '',
  });

  Color get color => Color(colorValue);
  IconData get icon => TripIconHelper.iconFromName(iconName);

  Map<String, dynamic> toMap() => {
    'title': title,
    'subtitle': subtitle,
    'duration': duration,
    'iconName': iconName,
    'colorValue': colorValue,
    'imageUrl': imageUrl,
  };

  factory TripStop.fromMap(Map<String, dynamic> map) => TripStop(
    title: map['title'] as String? ?? '',
    subtitle: map['subtitle'] as String? ?? '',
    duration: map['duration'] as String? ?? '',
    iconName: map['iconName'] as String? ?? 'place',
    colorValue: ((map['colorValue'] ?? 0xFF187BCD) as num).toInt(),
    imageUrl: map['imageUrl'] as String? ?? '',
  );
}

class TripModel {
  final String id;
  final TripType type;
  final String name;
  final String shortDescription;
  final String description;
  final int durationMinutes;
  final int flightMinutes;
  final double priceUsd;
  final String imageUrl;
  final int accentColorValue;
  final String routeLabel;
  final String mapHint;
  final String locationLabel;
  final List<String> included;
  final List<TripStop> itinerary;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  TripModel({
    required this.id,
    required this.type,
    required this.name,
    this.shortDescription = '',
    this.description = '',
    this.durationMinutes = 0,
    this.flightMinutes = 0,
    this.priceUsd = 0,
    this.imageUrl = '',
    this.accentColorValue = 0xFF187BCD,
    this.routeLabel = '',
    this.mapHint = '',
    this.locationLabel = 'Cairo International Airport',
    this.included = const [],
    this.itinerary = const [],
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Color get accentColor => Color(accentColorValue);
  bool get isFlying => type == TripType.flying;
  bool get isTransit => type == TripType.transit;

  String get durationLabel {
    if (durationMinutes <= 0) return 'N/A';
    if (durationMinutes >= 60) {
      final hours = durationMinutes / 60.0;
      final isWhole = hours == hours.truncateToDouble();
      return isWhole ? '${hours.toInt()}h' : '${hours.toStringAsFixed(1)}h';
    }
    return '${durationMinutes} min';
  }

  String get priceLabel => '\$${priceUsd.toInt()}';

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.name,
    'name': name,
    'shortDescription': shortDescription,
    'description': description,
    'durationMinutes': durationMinutes,
    'flightMinutes': flightMinutes,
    'priceUsd': priceUsd,
    'imageUrl': imageUrl,
    'accentColorValue': accentColorValue,
    'routeLabel': routeLabel,
    'mapHint': mapHint,
    'locationLabel': locationLabel,
    'included': included,
    'itinerary': itinerary.map((s) => s.toMap()).toList(),
    'isActive': isActive,
    'createdAtEpoch': createdAt.millisecondsSinceEpoch,
    'updatedAtEpoch': updatedAt.millisecondsSinceEpoch,
  };

  factory TripModel.fromMap(Map<String, dynamic> map) {
    final typeRaw = (map['type'] as String? ?? '').trim();
    final type = TripType.values.firstWhere(
      (t) => t.name == typeRaw,
      orElse: () => TripType.transit,
    );

    final itineraryRaw = map['itinerary'] as List? ?? const [];
    final stops = itineraryRaw
        .map((e) => TripStop.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    final includedRaw = map['included'] as List? ?? const [];

    return TripModel(
      id: map['id'] as String? ?? '',
      type: type,
      name: map['name'] as String? ?? '',
      shortDescription: map['shortDescription'] as String? ?? '',
      description: map['description'] as String? ?? '',
      durationMinutes: ((map['durationMinutes'] ?? 0) as num).toInt(),
      flightMinutes: ((map['flightMinutes'] ?? 0) as num).toInt(),
      priceUsd: ((map['priceUsd'] ?? 0) as num).toDouble(),
      imageUrl: map['imageUrl'] as String? ?? '',
        accentColorValue: ((map['accentColorValue'] ?? 0xFF187BCD) as num)
          .toInt(),
      routeLabel: map['routeLabel'] as String? ?? '',
      mapHint: map['mapHint'] as String? ?? '',
      locationLabel: map['locationLabel'] as String? ?? 'Cairo International Airport',
      included: includedRaw.map((e) => e.toString()).toList(),
      itinerary: stops,
      isActive: map['isActive'] != false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAtEpoch'] as int?) ?? 0,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['updatedAtEpoch'] as int?) ?? 0,
      ),
    );
  }

  TripModel copyWith({
    String? id,
    TripType? type,
    String? name,
    String? shortDescription,
    String? description,
    int? durationMinutes,
    int? flightMinutes,
    double? priceUsd,
    String? imageUrl,
    int? accentColorValue,
    String? routeLabel,
    String? mapHint,
    String? locationLabel,
    List<String>? included,
    List<TripStop>? itinerary,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      flightMinutes: flightMinutes ?? this.flightMinutes,
      priceUsd: priceUsd ?? this.priceUsd,
      imageUrl: imageUrl ?? this.imageUrl,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      routeLabel: routeLabel ?? this.routeLabel,
      mapHint: mapHint ?? this.mapHint,
      locationLabel: locationLabel ?? this.locationLabel,
      included: included ?? this.included,
      itinerary: itinerary ?? this.itinerary,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TripIconHelper {
  static const Map<String, IconData> _icons = {
    'flight_land': Icons.flight_land_rounded,
    'flight_takeoff': Icons.flight_takeoff_rounded,
    'flight': Icons.flight_rounded,
    'fort': Icons.fort_rounded,
    'landscape': Icons.landscape_rounded,
    'castle': Icons.castle_rounded,
    'music': Icons.music_note_rounded,
    'account_balance': Icons.account_balance_rounded,
    'water': Icons.water_rounded,
    'shopping_cart': Icons.shopping_cart_rounded,
    'cell_tower': Icons.cell_tower_rounded,
    'directions_bus': Icons.directions_bus_rounded,
    'museum': Icons.museum_rounded,
    'photo': Icons.photo_camera_rounded,
    'local_dining': Icons.local_dining_rounded,
    'sailing': Icons.sailing_rounded,
    'walk': Icons.directions_walk_rounded,
    'place': Icons.place_rounded,
  };

  static IconData iconFromName(String name) {
    return _icons[name] ?? Icons.place_rounded;
  }

  static List<String> iconNames() => _icons.keys.toList();
}
