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

  late final AnimationController _animCtrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
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

  Future<void> _handleFacebookSignIn() async {
    final authService = context.read<AuthService>();
    if (authService.isLoading) return;

    final success = await authService.signInWithFacebook();
    if (!mounted) return;

    if (success) {
      final user = authService.currentUser;
      if (user != null) {
        await context.read<NotificationService>().registerForUser(user.uid);
      }
      _showSuccessSnackBar('Signed in with Facebook successfully');
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _goToHome(isAdmin: user?.isAdmin == true),
      );
      return;
    }

    _showErrorSnackBar(authService.errorMessage ?? 'Facebook sign in failed');
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
        transitionDuration: const Duration(milliseconds: 550),
        pageBuilder: (context, anim, secAnim) => const SignUpPage(),
        transitionsBuilder: (context, anim, secAnim, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
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
            trailingText: "Don't have an account?",
            actionLabel: 'Get Started',
            onActionTap: _goToSignUp,
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
                                  'Welcome Back',
                                  style: roboto(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Enter your details below',
                                  style: roboto(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                AuthInputField(
                                  controller: _emailCtrl,
                                  label: 'Email Address',
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 16),
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
                                const SizedBox(height: 26),
                                Consumer<AuthService>(
                                  builder: (context, authService, _) {
                                    return AuthGradientButton(
                                      label: authService.isLoading
                                          ? 'Sign In...'
                                          : 'Sign In',
                                      onTap: authService.isLoading
                                          ? () {}
                                          : _handleSignIn,
                                    );
                                  },
                                ),
                                const SizedBox(height: 14),
                                Center(
                                  child: TextButton(
                                    onPressed: () async {
                                      final authService = context
                                          .read<AuthService>();
                                      final ok = await authService
                                          .sendPasswordResetEmail(
                                            _emailCtrl.text,
                                          );
                                      if (!mounted) return;
                                      if (ok) {
                                        _showSuccessSnackBar(
                                          authService.errorMessage ??
                                              'Reset email sent successfully.',
                                        );
                                      } else {
                                        _showErrorSnackBar(
                                          authService.errorMessage ??
                                              'Failed to send reset email.',
                                        );
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Text(
                                      'Forgot your password?',
                                      style: roboto(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ── Bottom section: pinned ──────────────────
                        Column(
                          children: [
                            const AuthOrDivider(label: 'Or sign in with'),
                            const SizedBox(height: 18),
                            AuthSocialRow(
                              onGoogleTap: _handleGoogleSignIn,
                              onFacebookTap: _handleFacebookSignIn,
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
