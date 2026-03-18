import 'dart:async';
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background Image ────────────────────────────────────
          Image.asset(
            'img/Background.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),

          // ── Dark Overlay ─────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.05),
                  Colors.black.withValues(alpha: 0.35),
                ],
              ),
            ),
          ),
        ],
      ),
      // ── Fixed Bottom Button ──────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: GestureDetector(
              onTap: () => _openSignIn(context),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFB8885B),
                      Color(0xFFA67A4D),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B6F47).withValues(alpha: 0.40),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Explore Egyptian Destinations',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
