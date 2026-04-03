import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../services/trip_image_cache_manager.dart';

class TripImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext context)? placeholderBuilder;
  final Widget Function(BuildContext context)? errorBuilder;

  const TripImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholderBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();
    if (url.isEmpty) return _error(context);

    if (url.startsWith('data:image')) {
      final comma = url.indexOf(',');
      if (comma < 0 || comma >= url.length - 1) {
        return _error(context);
      }
      try {
        final bytes = base64Decode(url.substring(comma + 1));
        if (bytes.isEmpty) return _error(context);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => _error(context),
        );
      } catch (_) {
        return _error(context);
      }
    }

    return CachedNetworkImage(
      imageUrl: url,
      cacheManager: TripImageCacheManager.instance,
      width: width,
      height: height,
      fit: fit,
      useOldImageOnUrlChange: true,
      fadeInDuration: const Duration(milliseconds: 160),
      placeholderFadeInDuration: const Duration(milliseconds: 120),
      placeholder: (ctx, _) => _placeholder(ctx),
      errorWidget: (ctx, _, __) => _error(ctx),
    );
  }

  Widget _placeholder(BuildContext context) {
    if (placeholderBuilder != null) return placeholderBuilder!(context);
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF1F4F8),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _error(BuildContext context) {
    if (errorBuilder != null) return errorBuilder!(context);
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFEFF2F6),
      alignment: Alignment.center,
      child: const Icon(Icons.photo_rounded, color: Colors.grey),
    );
  }
}
