import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class TripImageCacheManager {
  static const String _cacheKey = 'tripImageCacheV1';

  static final CacheManager instance = CacheManager(
    Config(
      _cacheKey,
      stalePeriod: const Duration(days: 120),
      maxNrOfCacheObjects: 3000,
    ),
  );
}
