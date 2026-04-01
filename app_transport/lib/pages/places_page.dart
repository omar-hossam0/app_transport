import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_widgets.dart';
import '../services/language_provider.dart';
import '../services/app_localizations.dart';

class PlacesPage extends StatelessWidget {
  const PlacesPage({super.key});

  static const _places = [
    (
      'giza_pyramids',
      'giza_pyramids_loc',
      'giza_pyramids_desc',
      Icons.account_balance_rounded,
      Color(0xFFFF8C00),
      '8h',
    ),
    (
      'khan_khalili',
      'khan_khalili_loc',
      'khan_khalili_desc',
      Icons.store_rounded,
      Color(0xFF187BCD),
      '3h',
    ),
    (
      'egyptian_museum',
      'egyptian_museum_loc',
      'egyptian_museum_desc',
      Icons.museum_rounded,
      Color(0xFF4A44AA),
      '3h',
    ),
    (
      'nile_cruise',
      'nile_cruise_loc',
      'nile_cruise_desc',
      Icons.sailing_rounded,
      Color(0xFF0D7377),
      '2h',
    ),
    (
      'saladin_citadel',
      'saladin_citadel_loc',
      'saladin_citadel_desc',
      Icons.castle_rounded,
      Color(0xFFE02850),
      '3h',
    ),
    (
      'grand_museum',
      'grand_museum_loc',
      'grand_museum_desc',
      Icons.account_balance_rounded,
      Color(0xFF2E7D32),
      '4h',
    ),
    (
      'memphis_saqqara',
      'memphis_saqqara_loc',
      'memphis_saqqara_desc',
      Icons.landscape_rounded,
      Color(0xFF6A1B9A),
      '4h',
    ),
    (
      'cairo_tower',
      'cairo_tower_loc',
      'cairo_tower_desc',
      Icons.cell_tower_rounded,
      Color(0xFF00838F),
      '1h',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<LanguageProvider>().isArabic;
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(22, topPad + 16, 22, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5BC0EB), Color(0xFF187BCD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
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
                  const SizedBox(height: 14),
                  Text(
                    isAr ? 'أماكن مشهورة' : 'Popular Places',
                    style: roboto(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isAr ? 'أشهر المعالم السياحية في مصر' : 'Top tourist landmarks across Egypt',
                    style: roboto(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((ctx, i) {
                final p = _places[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: p.$5.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(p.$4, color: p.$5, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.tr(p.$1, isAr),
                              style: roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(
                                  Icons.place_rounded,
                                  size: 12,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  S.tr(p.$2, isAr),
                                  style: roboto(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              S.tr(p.$3, isAr),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: roboto(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: p.$5.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              p.$6,
                              style: roboto(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: p.$5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }, childCount: _places.length),
            ),
          ),
        ],
      ),
    );
  }
}
