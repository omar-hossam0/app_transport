import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/booking_service.dart';
import 'services/favorites_service.dart';
import 'services/trip_service.dart';
import 'services/admin_service.dart';
import 'services/notification_service.dart';
import 'services/language_service.dart';
import 'pages/sign_in_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  try {
    debugPrint('\n═══════════════════════════════════════════════════════════');
    debugPrint('🔥 FIREBASE INITIALIZATION STARTED');
    debugPrint('═══════════════════════════════════════════════════════════');

    final options = DefaultFirebaseOptions.currentPlatform;
    debugPrint(
      '[Firebase Init] Options received - Project ID: ${options.projectId}',
    );
    debugPrint(
      '[Firebase Init] API Key: ${options.apiKey.substring(0, 10)}...',
    );
    debugPrint('[Firebase Init] App ID: ${options.appId}');

    await Firebase.initializeApp(options: options).timeout(
      const Duration(seconds: 12),
      onTimeout: () {
        throw TimeoutException(
          'Firebase.initializeApp timed out after 12 seconds',
        );
      },
    );

    debugPrint('✅ Firebase Initialized Successfully!');
    debugPrint('   Project: ${options.projectId}');
    debugPrint('   Database URL: ${options.databaseURL}');
    runApp(_buildRootApp());
    unawaited(_logDatabaseHealthCheck());
    return;
  } catch (e) {
    debugPrint('\n❌❌❌ FIREBASE INITIALIZATION FAILED');
    debugPrint('Error: $e');
    debugPrint('Error type: ${e.runtimeType}');
  }

  runApp(_buildRootApp());
}

Widget _buildRootApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthService()),
      ChangeNotifierProvider(create: (_) => BookingService()),
      ChangeNotifierProvider(create: (_) => FavoritesService()),
      ChangeNotifierProvider(create: (_) => TripService()),
      ChangeNotifierProvider(create: (_) => AdminService()),
      ChangeNotifierProvider(create: (_) => LanguageService()..load()),
      Provider(create: (_) => NotificationService()),
    ],
    child: const MyApp(),
  );
}

Future<void> _logDatabaseHealthCheck() async {
  try {
    final db = FirebaseDatabase.instance;
    final snap = await db.ref('system/trips_seeded').get().timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        throw TimeoutException('Database health-check timeout');
      },
    );
    debugPrint(
      '[DB Health Check] Connected. exists=${snap.exists}, type=${snap.value.runtimeType}',
    );
  } catch (e) {
    debugPrint('[DB Health Check] Not reachable now: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  double _appTextScale(BuildContext context) {
    final shortest = MediaQuery.of(context).size.shortestSide;
    final scale = shortest / 390.0;
    return scale.clamp(0.92, 1.10);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, language, _) => MaterialApp(
        title: 'App Transport',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF187BCD)),
        ),
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(textScaler: TextScaler.linear(_appTextScale(context))),
            child: child ?? const SizedBox.shrink(),
          );
        },
        locale: language.locale,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _openSignIn(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, anim, secAnim) => const SignInPage(),
        transitionsBuilder: (context, anim, secAnim, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LanguageService>().isArabic;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background Image ────────────────────────────────────
          Image.asset('img/Background.png', fit: BoxFit.cover),

          // ── Logo (Top Left) ─────────────────────────────────────
          Positioned(
            left: 10,
            top:
                -45, // Negative position to push the logo to the extreme top edge
            child: Image.asset(
              'img/Logo-Bg.png',
              width: MediaQuery.of(context).size.width * 0.65,
              height: MediaQuery.of(context).size.width * 0.65,
              fit: BoxFit.contain,
            ),
          ),

          // ── Text + Button (Positioned above bottom) ──────────────
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).size.height * 0.12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Descriptive text
                Text(
                  isArabic
                      ? 'خطط رحلتك مع تطبيقات الترانزيت\nواكتشف أرض الفراعنة من هاتفك.'
                      : 'Plan your journey with transit apps and\nexplore the land of pharaohs at your fingertips.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.90),
                    height: 1.5,
                    letterSpacing: 0.2,
                    shadows: const [
                      Shadow(
                        color: Color(0x99000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                // Frosted glass button with warm amber tint
                GestureDetector(
                  onTap: () => _openSignIn(context),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        // Warm amber glow
                        BoxShadow(
                          color: const Color(
                            0xFFD4A04A,
                          ).withValues(alpha: 0.25),
                          blurRadius: 18,
                          spreadRadius: -2,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Warm amber-tinted frosted glass background
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(
                                      0xFFB8885A,
                                    ).withValues(alpha: 0.50),
                                    const Color(
                                      0xFF8B6540,
                                    ).withValues(alpha: 0.55),
                                    const Color(
                                      0xFF6B4C30,
                                    ).withValues(alpha: 0.60),
                                  ],
                                ),
                                border: Border.all(
                                  color: const Color(
                                    0xFFD4A04A,
                                  ).withValues(alpha: 0.60),
                                  width: 1.3,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          // Top highlight line (subtle shine)
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: 1.0,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withValues(alpha: 0.35),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Bottom center bright glow/shine
                          Align(
                            alignment: const Alignment(0.0, 1.4),
                            child: Container(
                              width: 120,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFE8C170,
                                    ).withValues(alpha: 0.60),
                                    blurRadius: 28,
                                    spreadRadius: 2,
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.30),
                                    blurRadius: 16,
                                    spreadRadius: -2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Content row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isArabic
                                    ? 'استكشف الوجهات المصرية'
                                    : 'Explore Egyptian Destinations',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.95),
                                  letterSpacing: 0.3,
                                  shadows: const [
                                    Shadow(
                                      color: Color(0x88000000),
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
