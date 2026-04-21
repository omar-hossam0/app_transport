import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class TripImageCacheManager {
  static const String _cacheKey = 'tripImageCacheV1';

  static final CacheManager instance = CacheManager(
    Config(
      _cacheKey,
      stalePeriod: const Duration(days: 120),
      maxNrOfCacheObjects: 3000,
      fileService: _TimeoutHttpFileService(),
    ),
  );
}

class _TimeoutHttpFileService extends HttpFileService {
  static const Duration _requestTimeout = Duration(seconds: 15);

  @override
  Future<FileServiceResponse> get(String url, {Map<String, String>? headers}) {
    return super.get(url, headers: headers).timeout(_requestTimeout);
  }
}
