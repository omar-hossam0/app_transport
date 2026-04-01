import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_widgets.dart';
import 'home_page.dart';
import 'admin/admin_dashboard_page.dart';
import 'email_verification_pending_page.dart';
import 'sign_up_page.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/language_provider.dart';
import '../services/app_localizations.dart';

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
  bool _didPrecacheHeaderImage = false;

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
      final isAr = context.read<LanguageProvider>().isArabic;
      _showErrorSnackBar(S.tr('email_pass_required', isAr));
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
      _showSuccessSnackBar(S.tr('welcome_back_msg', context.read<LanguageProvider>().isArabic));
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
      _showErrorSnackBar(authService.errorMessage ?? S.tr('sign_in_failed', context.read<LanguageProvider>().isArabic));
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

    _showErrorSnackBar(authService.errorMessage ?? S.tr('google_sign_in_failed', context.read<LanguageProvider>().isArabic));
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
    final isAr = context.watch<LanguageProvider>().isArabic;
    return Scaffold(
      backgroundColor: kAuthHeaderEdgeBlue,
      body: Column(
        children: [
          // ── Gradient header ─────────────────────────────────────────────
          AuthHeader(
            trailingText: S.tr('dont_have_account_header', isAr),
            actionLabel: S.tr('sign_up', isAr),
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
                                  S.tr('welcome_back', isAr),
                                  style: roboto(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  S.tr('enter_details', isAr),
                                  style: roboto(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                AuthInputField(
                                  controller: _emailCtrl,
                                  label: S.tr('email_address', isAr),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 16),
                                AuthInputField(
                                  controller: _passCtrl,
                                  label: S.tr('password', isAr),
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
                                          ? S.tr('sign_in_loading', isAr)
                                          : S.tr('sign_in', isAr),
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
                                              S.tr('reset_email_sent', isAr),
                                        );
                                      } else {
                                        _showErrorSnackBar(
                                          authService.errorMessage ??
                                              S.tr('reset_email_failed', isAr),
                                        );
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Text(
                                      S.tr('forgot_password_link', isAr),
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
                            AuthOrDivider(label: S.tr('or_sign_in_with', isAr)),
                            const SizedBox(height: 18),
                            AuthSocialRow(onGoogleTap: _handleGoogleSignIn),
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
