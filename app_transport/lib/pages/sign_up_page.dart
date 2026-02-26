import 'package:flutter/material.dart';
import 'auth_widgets.dart';
import 'home_page.dart';
import 'sign_in_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  late final AnimationController _animCtrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  int get _strength {
    final p = _passCtrl.text;
    if (p.isEmpty) return 0;
    int s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(p)) s++;
    if (RegExp(r'[0-9]').hasMatch(p)) s++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(p)) s++;
    return s;
  }

  String get _strengthLabel =>
      ['', 'Weak', 'Fair', 'Good', 'Strong'][_strength];

  Color get _strengthColor => [
    Colors.transparent,
    Colors.redAccent,
    Colors.orange,
    Colors.amber,
    kLightBlue,
  ][_strength];

  @override
  void initState() {
    super.initState();
    _passCtrl.addListener(() => setState(() {}));
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.decelerate));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _goToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, anim, secAnim) => const HomePage(),
        transitionsBuilder: (context, anim, secAnim, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          );
        },
      ),
      (_) => false,
    );
  }

  void _goToSignIn() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 550),
        pageBuilder: (context, anim, secAnim) => const SignInPage(),
        transitionsBuilder: (context, anim, secAnim, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlue,
      body: Column(
        children: [
          // ── Gradient header ──────────────────────────────────────────
          AuthHeader(
            trailingText: 'Already have an account?',
            actionLabel: 'Sign In',
            onActionTap: _goToSignIn,
          ),

          // ── White card — fills remaining height exactly ───────────────
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ── Top section: scrollable ──────────────────
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Get started free.',
                                  style: roboto(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Free forever. No credit card needed.',
                                  style: roboto(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                AuthInputField(
                                  controller: _emailCtrl,
                                  label: 'Email Address',
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 14),
                                AuthInputField(
                                  controller: _nameCtrl,
                                  label: 'Your name',
                                ),
                                const SizedBox(height: 14),
                                AuthInputField(
                                  controller: _passCtrl,
                                  label: 'Password',
                                  obscure: _obscure,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.grey.shade400,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                if (_passCtrl.text.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      ...List.generate(4, (i) {
                                        return Expanded(
                                          child: Container(
                                            margin: EdgeInsets.only(
                                              right: i < 3 ? 5 : 0,
                                            ),
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: i < _strength
                                                  ? _strengthColor
                                                  : Colors.grey.shade200,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        );
                                      }),
                                      const SizedBox(width: 10),
                                      Text(
                                        _strengthLabel,
                                        style: roboto(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _strengthColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 24),
                                AuthGradientButton(
                                  label: 'Sign up',
                                  onTap: _goToHome,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ── Bottom section: pinned ──────────────────
                        Column(
                          children: [
                            const AuthOrDivider(label: 'Or sign up with'),
                            const SizedBox(height: 18),
                            AuthSocialRow(
                              onGoogleTap: () {},
                              onFacebookTap: () {},
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
