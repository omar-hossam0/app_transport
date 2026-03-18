import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'pages/sign_in_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize Firebase using the generated options entrypoint.
  // This uses `DefaultFirebaseOptions.currentPlatform` directly.
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

    await Firebase.initializeApp(options: options);

    debugPrint('✅ Firebase Initialized Successfully!');
    debugPrint('   Project: ${options.projectId}');
    debugPrint('   Database URL: ${options.databaseURL}');

    // Quick Realtime Database connectivity check
    bool dbConnected = false;
    String dbError = '';

    try {
      debugPrint('\n[DB Connection Test] Starting...');
      final db = FirebaseDatabase.instance;
      debugPrint('[DB Connection Test] FirebaseDatabase instance created');
      debugPrint('[DB Connection Test] Attempting a safe root read...');

      // Use a safe root read for all platforms.
      // (.info/connected and '/'' can throw invalid-path errors on web SDK wrappers)
      final connectedFuture = db.ref().get().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('[DB Connection Test] ⏱️ TIMEOUT after 10 seconds');
          throw TimeoutException(
            'Database read timeout - check internet and Realtime DB status',
          );
        },
      );

      final infoSnap = await connectedFuture;
      debugPrint('[DB Connection Test] Response received');
      debugPrint('[DB Connection Test] Snapshot exists: ${infoSnap.exists}');
      debugPrint(
        '[DB Connection Test] Snapshot value type: ${infoSnap.value.runtimeType}',
      );
      dbConnected = true;
      dbError = '✅ Database is reachable';
      debugPrint('\n✅✅✅ SUCCESS! Realtime Database is CONNECTED!');
    } catch (e) {
      dbConnected = false;
      debugPrint('[DB Connection Test] ❌ EXCEPTION: $e');
      debugPrint('[DB Connection Test] Exception type: ${e.runtimeType}');

      if (e.toString().contains('TimeoutException')) {
        dbError =
            '⏱️ TIMEOUT (10s)\nFixes:\n→ Check internet connection\n→ Realtime Database should be enabled';
      } else if (e.toString().contains('PERMISSION_DENIED')) {
        dbError =
            '🔒 Permission Denied\nFix:\n→ Check Realtime Database rules in Firebase Console';
      } else if (e.toString().contains('no address associated')) {
        dbError = '🌐 No internet\nFix:\n→ Check device internet connection';
      } else if (e.toString().contains('not a subtype')) {
        // Data format issue - but database is working!
        dbConnected = true;
        dbError =
            '✅ Database is accessible! (data format note - this is normal)';
        debugPrint(
          '[DB Connection Test] 📝 Database is accessible - data format is working!',
        );
      } else {
        dbError = '❌ Firebase Error: ${e.toString().split('\n').first}';
      }
    }

    debugPrint('\n═══════════════════════════════════════════════════════════');
    debugPrint('FINAL RESULT:');
    debugPrint('Database Connected: $dbConnected');
    debugPrint('Error Message: $dbError');
    debugPrint('═══════════════════════════════════════════════════════════\n');

    // Pass the DB state into the app so UI can show a message
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProvider(create: (_) => BookingService()),
          ChangeNotifierProvider(create: (_) => FavoritesService()),
          ChangeNotifierProvider(create: (_) => TripService()),
          ChangeNotifierProvider(create: (_) => AdminService()),
          Provider(create: (_) => NotificationService()),
        ],
        child: const MyApp(),
      ),
    );
    return;
  } catch (e) {
    // Print error so we can see failure on the console
    debugPrint('\n❌❌❌ FIREBASE INITIALIZATION FAILED');
    debugPrint('Error: $e');
    debugPrint('Error type: ${e.runtimeType}');
  }

  // If initialization failed we still run the app (will show not-connected)
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => BookingService()),
        ChangeNotifierProvider(create: (_) => FavoritesService()),
        ChangeNotifierProvider(create: (_) => TripService()),
        ChangeNotifierProvider(create: (_) => AdminService()),
        Provider(create: (_) => NotificationService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Transport',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF187BCD)),
      ),
      home: const SplashScreen(),
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
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background Image ────────────────────────────────────
          Image.asset(
            'img/Background.png',
            fit: BoxFit.cover,
          ),

          // ── Button (Fixed at Bottom) ─────────────────────────────
          Positioned(
            left: 24,
            right: 24,
            bottom: 0,
            child: SafeArea(
              minimum: const EdgeInsets.only(bottom: 20),
              child: GestureDetector(
                onTap: () => _openSignIn(context),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF67D9FF).withValues(alpha: 0.42),
                        blurRadius: 20,
                        spreadRadius: -5,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.24),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFFC98A58).withValues(alpha: 0.84),
                                  const Color(0xFF8F502A).withValues(alpha: 0.84),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.26),
                                width: 1.1,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: 1.2,
                            margin: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white.withValues(alpha: 0.45),
                            ),
                          ),
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: Colors.white,
                              size: 23,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Explore Egyptian Destinations',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.2,
                                shadows: [
                                  Shadow(
                                    color: Color(0xAA000000),
                                    blurRadius: 6,
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
            ),
          ),
        ],
      ),
    );
  }
}
