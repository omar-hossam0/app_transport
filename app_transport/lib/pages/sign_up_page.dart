import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_widgets.dart';
import 'email_verification_pending_page.dart';
import 'home_page.dart';
import 'admin/admin_dashboard_page.dart';
import 'sign_in_page.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

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
  bool _didPrecacheHeaderImage = false;

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
      duration: const Duration(milliseconds: 650),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheHeaderImage) return;
    _didPrecacheHeaderImage = true;
    precacheImage(kSignHeaderImageProvider, context);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _goToHome({required bool isAdmin}) {
    final target = isAdmin ? const AdminDashboardPage() : const HomePage();
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, anim, secAnim) => target,
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

  Future<void> _handleSignUp() async {
    if (_emailCtrl.text.isEmpty ||
        _passCtrl.text.isEmpty ||
        _nameCtrl.text.isEmpty) {
      _showErrorSnackBar('Please fill in all fields');
      return;
    }

    if (_passCtrl.text.length < 6) {
      _showErrorSnackBar('Password must be at least 6 characters');
      return;
    }

    final authService = context.read<AuthService>();

    bool success = await authService.signUp(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      name: _nameCtrl.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      _showSuccessSnackBar(authService.errorMessage ?? 'Account created!');
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const EmailVerificationPendingPage(),
          ),
        );
      });
    } else {
      _showErrorSnackBar(
        authService.errorMessage ?? 'Failed to create account',
      );
    }
  }

  Future<void> _handleGoogleSignUp() async {
    final authService = context.read<AuthService>();
    if (authService.isLoading) return;

    final success = await authService.signInWithGoogle(requireNewAccount: true);
    if (!mounted) return;

    if (success) {
      final user = authService.currentUser;
      if (user != null) {
        await context.read<NotificationService>().registerForUser(user.uid);
      }
      _showSuccessSnackBar(
        authService.errorMessage ?? 'Signed up with Google successfully',
      );
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _goToHome(isAdmin: user?.isAdmin == true),
      );
      return;
    }

    final error = authService.errorMessage ?? 'Google sign up failed';
    if (error.contains('already registered')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'This Google account already exists. Please sign in instead.',
          ),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 6),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          action: SnackBarAction(
            label: 'Sign in',
            textColor: Colors.white,
            onPressed: _goToSignIn,
          ),
        ),
      );
      return;
    }
    _showErrorSnackBar(error);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFFEF4444),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _goToSignIn() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, anim, secAnim) => const SignInPage(),
        transitionsBuilder: (context, anim, secAnim, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAuthLightBlueBg,
      body: Container(
        decoration: const BoxDecoration(gradient: kAuthBgGradient),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  // ── Top Navigation Bar ─────────────────────────────────
                  AuthTopBar(onBackTap: () => Navigator.of(context).maybePop()),

                  // ── Scrollable Form Area ───────────────────────────────
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 4,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // ── Centered Circular Drone Emblem with Engravings ──
                              const AuthCircularBadge(size: 145),
                              const SizedBox(height: 14),

                              // ── Title & Subtitle ─────────────────────────
                              Text(
                                'Create Account',
                                style: roboto(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Sign up to start your journey',
                                style: roboto(
                                  fontSize: 14,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 22),

                              // ── Inputs ───────────────────────────────────
                              AuthInputField(
                                controller: _nameCtrl,
                                label: 'Full name',
                                hintText: 'John Doe',
                                prefixIcon: const Icon(
                                  Icons.person_outline_rounded,
                                  color: Color(0xFF94A3B8),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 14),

                              AuthInputField(
                                controller: _emailCtrl,
                                label: 'Email address',
                                hintText: 'name@example.com',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: Color(0xFF94A3B8),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 14),

                              AuthInputField(
                                controller: _passCtrl,
                                label: 'Password',
                                hintText: '••••••••',
                                obscure: _obscure,
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: Color(0xFF94A3B8),
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF94A3B8),
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),

                              // ── Password Strength Bar ────────────────────
                              if (_passCtrl.text.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    ...List.generate(4, (i) {
                                      return Expanded(
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          margin: EdgeInsets.only(
                                            right: i < 3 ? 6 : 0,
                                          ),
                                          height: 4.5,
                                          decoration: BoxDecoration(
                                            color: i < _strength
                                                ? _strengthColor
                                                : Colors.grey.shade300,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
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

                              // ── Modern Gradient Sign Up Button ───────────
                              Consumer<AuthService>(
                                builder: (context, authService, _) {
                                  return AuthGradientButton(
                                    label: authService.isLoading
                                        ? 'Signing up...'
                                        : 'Sign Up',
                                    isLoading: authService.isLoading,
                                    onTap: authService.isLoading
                                        ? () {}
                                        : _handleSignUp,
                                  );
                                },
                              ),
                              const SizedBox(height: 18),

                              // ── Already have an account? Sign In ─────────
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: roboto(
                                      fontSize: 13,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _goToSignIn,
                                    child: Text(
                                      'Sign In',
                                      style: roboto(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: kBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // ── Or sign up with ──────────────────────────
                              const AuthOrDivider(label: 'Or sign up with'),
                              const SizedBox(height: 18),

                              // ── Social Google Sign Up ────────────────────
                              AuthSocialRow(
                                label: 'Sign up with Google',
                                onGoogleTap: _handleGoogleSignUp,
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
