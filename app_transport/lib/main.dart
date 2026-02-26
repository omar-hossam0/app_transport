import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/sign_in_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MyApp());
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
                    SizedBox(height: size.height * 0.07),
                    Center(
                      child: Image.asset(
                        'img/logo.png',
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
                        style: TextStyle(
                          fontFamily: 'Montserrat',
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
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white60,
                          fontSize: size.width * 0.034,
                          fontWeight: FontWeight.w400,
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
                        child: const Text(
                          'Explore',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
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
