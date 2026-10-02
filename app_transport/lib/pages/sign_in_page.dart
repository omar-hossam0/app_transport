import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_widgets.dart';
import 'home_page.dart';
import 'admin/admin_dashboard_page.dart';
import 'email_verification_pending_page.dart';
import 'sign_up_page.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _rememberMe = false;
  bool _didPrecacheHeaderImage = false;

  late final AnimationController _animCtrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
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

  Future<void> _handleSignIn() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      _showErrorSnackBar('Email and password are required');
      return;
    }

    final authService = context.read<AuthService>();

    bool success = await authService.signIn(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      final user = authService.currentUser;
      if (user != null) {
        await context.read<NotificationService>().registerForUser(user.uid);
      }
      _showSuccessSnackBar('Welcome back!');
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _goToHome(isAdmin: user?.isAdmin == true),
      );
    } else {
      if (authService.needsEmailVerification) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const EmailVerificationPendingPage(),
          ),
        );
        return;
      }
      _showErrorSnackBar(authService.errorMessage ?? 'Sign in failed');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authService = context.read<AuthService>();
    if (authService.isLoading) return;

    final success = await authService.signInWithGoogle();
    if (!mounted) return;

    if (success) {
      final user = authService.currentUser;
      if (user != null) {
        await context.read<NotificationService>().registerForUser(user.uid);
      }
      _showSuccessSnackBar('Signed in with Google successfully');
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _goToHome(isAdmin: user?.isAdmin == true),
      );
      return;
    }

    _showErrorSnackBar(authService.errorMessage ?? 'Google sign in failed');
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showErrorSnackBar('Please enter your email to reset password');
      return;
    }
    final authService = context.read<AuthService>();
    final ok = await authService.sendPasswordResetEmail(email);
    if (!mounted) return;
    if (ok) {
      _showSuccessSnackBar(
        authService.errorMessage ?? 'Password reset link sent to your email.',
      );
    } else {
      _showErrorSnackBar(
        authService.errorMessage ?? 'Failed to send reset email.',
      );
    }
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

  void _goToSignUp() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, anim, secAnim) => const SignUpPage(),
        transitionsBuilder: (context, anim, secAnim, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
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
        decoration: const BoxDecoration(
          gradient: kAuthBgGradient,
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  // ── Top Navigation Bar ─────────────────────────────────
                  AuthTopBar(
                    onBackTap: () => Navigator.of(context).maybePop(),
                  ),

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
                              const AuthCircularBadge(size: 150),
                              const SizedBox(height: 16),

                              // ── Title & Subtitle ─────────────────────────
                              Text(
                                'Welcome Back',
                                style: roboto(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Login to access your account',
                                style: roboto(
                                  fontSize: 14,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // ── Inputs ───────────────────────────────────
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
                              const SizedBox(height: 12),

                              // ── Remember me & Forgot Password Row ────────
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => setState(
                                      () => _rememberMe = !_rememberMe,
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            onChanged: (v) => setState(
                                              () => _rememberMe = v ?? false,
                                            ),
                                            activeColor: kBlue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            side: BorderSide(
                                              color: Colors.grey.shade400,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Remember me',
                                          style: roboto(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF475569),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _handleForgotPassword,
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Forgot password?',
                                      style: roboto(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFE11D48),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // ── Modern Gradient Login Button ─────────────
                              Consumer<AuthService>(
                                builder: (context, authService, _) {
                                  return AuthGradientButton(
                                    label: authService.isLoading
                                        ? 'Logging in...'
                                        : 'Login',
                                    isLoading: authService.isLoading,
                                    onTap: authService.isLoading
                                        ? () {}
                                        : _handleSignIn,
                                  );
                                },
                              ),
                              const SizedBox(height: 18),

                              // ── Don't have an account? Sign Up ───────────
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have account? ",
                                    style: roboto(
                                      fontSize: 13,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _goToSignUp,
                                    child: Text(
                                      'Sign Up',
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

                              // ── Or sign in with ──────────────────────────
                              const AuthOrDivider(label: 'Or sign in with'),
                              const SizedBox(height: 18),

                              // ── Social Google Login ──────────────────────
                              AuthSocialRow(
                                label: 'Login with Google',
                                onGoogleTap: _handleGoogleSignIn,
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
