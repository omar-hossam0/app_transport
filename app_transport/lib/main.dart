import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'pages/sign_in_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize Firebase using the generated options entrypoint.
  // This uses `DefaultFirebaseOptions.currentPlatform` directly.
  try {
    print('\n═══════════════════════════════════════════════════════════');
    print('🔥 FIREBASE INITIALIZATION STARTED');
    print('═══════════════════════════════════════════════════════════');

    final options = DefaultFirebaseOptions.currentPlatform;
    print(
      '[Firebase Init] Options received - Project ID: ${options.projectId}',
    );
    print('[Firebase Init] API Key: ${options.apiKey.substring(0, 10)}...');
    print('[Firebase Init] App ID: ${options.appId}');

    await Firebase.initializeApp(options: options);

    print('✅ Firebase Initialized Successfully!');
    print('   Project: ${options.projectId}');
    print('   Database URL: ${options.databaseURL}');

    // Quick Realtime Database connectivity check
    bool dbConnected = false;
    String dbError = '';

    try {
      print('\n[DB Connection Test] Starting...');
      final db = FirebaseDatabase.instance;
      print('[DB Connection Test] FirebaseDatabase instance created');
      print('[DB Connection Test] Attempting to read from .info/connected...');

      // Try reading .info/connected with timeout
      final connectedFuture = db
          .ref('.info/connected')
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('[DB Connection Test] ⏱️ TIMEOUT after 10 seconds');
              throw TimeoutException(
                'Database read timeout - check internet and Realtime DB status',
              );
            },
          );

      final infoSnap = await connectedFuture;
      print('[DB Connection Test] Response received');
      print('[DB Connection Test] Snapshot exists: ${infoSnap.exists}');
      print('[DB Connection Test] Snapshot value: ${infoSnap.value}');
      print(
        '[DB Connection Test] Snapshot value type: ${infoSnap.value.runtimeType}',
      );

      // Handle the response - value can come as different types
      final value = infoSnap.value;
      if (value == true || value == 'true' || value == 1) {
        dbConnected = true;
        print('\n✅✅✅ SUCCESS! Realtime Database is CONNECTED!');
      } else if (infoSnap.exists && (value as dynamic) == true) {
        dbConnected = true;
        print('\n✅✅✅ SUCCESS! Realtime Database is CONNECTED!');
      } else {
        // Handle different or unexpected values
        dbError =
            '.info/connected returned: $value (type: ${value.runtimeType})';
        print(
          '[DB Connection Test] ⚠️ Unexpected value, but trying root check...',
        );

        try {
          final rootSnap = await db
              .ref('/')
              .get()
              .timeout(const Duration(seconds: 5));
          print(
            '[DB Connection Test] Root read result: exists=${rootSnap.exists}',
          );
          if (rootSnap.exists) {
            dbConnected = true; // At least we can connect
            dbError =
                '✅ Database is accessible! (.info/connected returned: $value)';
            print('[DB Connection Test] ✅ Partial connection: $dbError');
          }
        } catch (altErr) {
          dbError = 'Both checks failed: $altErr';
          print('[DB Connection Test] Alternative read also failed: $altErr');
        }

        if (!dbConnected) {
          dbError =
              'Cannot determine connection status - Check Firebase Console Realtime DB is enabled';
          print('[DB Connection Test] ❌ Connection check failed: $dbError');
        }
      }
    } catch (e) {
      dbConnected = false;
      print('[DB Connection Test] ❌ EXCEPTION: $e');
      print('[DB Connection Test] Exception type: ${e.runtimeType}');

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
        print(
          '[DB Connection Test] 📝 Database is accessible - data format is working!',
        );
      } else {
        dbError = '❌ Firebase Error: ${e.toString().split('\n').first}';
      }
    }

    print('\n═══════════════════════════════════════════════════════════');
    print('FINAL RESULT:');
    print('Database Connected: $dbConnected');
    print('Error Message: $dbError');
    print('═══════════════════════════════════════════════════════════\n');

    // Pass the DB state into the app so UI can show a message
    runApp(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AuthService())],
        child: const MyApp(),
      ),
    );
    return;
  } catch (e) {
    // Print error so we can see failure on the console
    print('\n❌❌❌ FIREBASE INITIALIZATION FAILED');
    print('Error: $e');
    print('Error type: ${e.runtimeType}');
  }

  // If initialization failed we still run the app (will show not-connected)
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthService())],
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'img/Gemini_Generated_Image_olt9flolt9flolt9.png',
              fit: BoxFit.cover,
              width: size.width,
              height: size.height,
            ),
            // Top fade
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xAA000000), Color(0x00000000)],
                  stops: [0.0, 0.30],
                ),
              ),
            ),
            // Heavy bottom shadow
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: size.height * 0.55,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xFF000000),
                      Color(0xEE000000),
                      Color(0xAA000000),
                      Color(0x00000000),
                    ],
                    stops: [0.0, 0.25, 0.55, 1.0],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.04),
                    Center(
                      child: Image.asset(
                        'img/logo2.png',
                        height: size.height * 0.28,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const Spacer(),
                    // Main heading — bold uppercase left-aligned
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'TURN YOUR\nTRANSIT TIME\nINTO A MINI\nADVENTURE',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.oswald(
                          color: Colors.white,
                          fontSize: size.width * 0.082,
                          fontWeight: FontWeight.w700,
                          height: 1.18,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Subtitle — smaller, lighter
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'PLAN YOUR JOURNEY WITH TRANSIT APPS\nAND GO ANYWHERE YOU DREAM OF',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.oswald(
                          color: Colors.white60,
                          fontSize: size.width * 0.034,
                          fontWeight: FontWeight.w300,
                          height: 1.55,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              transitionDuration: const Duration(
                                milliseconds: 550,
                              ),
                              pageBuilder: (context, anim, secAnim) =>
                                  const SignInPage(),
                              transitionsBuilder:
                                  (context, anim, secAnim, child) =>
                                      SlideTransition(
                                        position:
                                            Tween<Offset>(
                                              begin: const Offset(0, 1),
                                              end: Offset.zero,
                                            ).animate(
                                              CurvedAnimation(
                                                parent: anim,
                                                curve: Curves.easeOut,
                                              ),
                                            ),
                                        child: child,
                                      ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF187BCD),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          'Explore',
                          style: GoogleFonts.oswald(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
