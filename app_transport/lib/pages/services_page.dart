import 'package:flutter/material.dart';
import 'auth_widgets.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  static const _services = [
    (
      Icons.wifi_rounded,
      'Airport WiFi',
      'Free high-speed internet at Cairo Airport',
      Color(0xFF187BCD),
    ),
    (
      Icons.local_taxi_rounded,
      'Private Car Hire',
      'Comfortable private transfers around Cairo',
      Color(0xFF4A44AA),
    ),
    (
      Icons.language_rounded,
      'Tour Guide',
      'Certified multilingual guides for your tour',
      Color(0xFF0D7377),
    ),
    (
      Icons.photo_camera_rounded,
      'Photography Tour',
      'Professional photo sessions at landmarks',
      Color(0xFFE02850),
    ),
    (
      Icons.luggage_rounded,
      'Luggage Storage',
      'Safe storage at the airport during your tour',
      Color(0xFFFF6B35),
    ),
    (
      Icons.local_dining_rounded,
      'Egyptian Dining',
      'Traditional meal experiences included',
      Color(0xFF2E7D32),
    ),
    (
      Icons.sim_card_rounded,
      'SIM Card',
      'Local Egyptian SIM with data package',
      Color(0xFF6A1B9A),
    ),
    (
      Icons.medical_services_rounded,
      'Travel Insurance',
      'Full coverage for all our tour packages',
      Color(0xFF00838F),
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                  colors: [kBlue, kLightBlue],
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
                    'Our Services',
                    style: roboto(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Everything you need for the perfect Egypt tour',
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
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate((ctx, i) {
                final s = _services[i];
                return Container(
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
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: s.$4.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(s.$1, color: s.$4, size: 24),
                      ),
                      const Spacer(),
                      Text(
                        s.$2,
                        style: roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.$3,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: roboto(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              }, childCount: _services.length),
            ),
          ),
        ],
      ),
    );
  }
}
