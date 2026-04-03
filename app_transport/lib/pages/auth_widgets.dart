import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Brand colours ────────────────────────────────────────────────────────────
const kBlue = Color(0xFF187BCD);
const kLightBlue = Color(0xFF5BC0EB);
const kAuthHeaderEdgeBlue = Color(0xFF072F5D);
const kSignHeaderImageProvider = ResizeImage(
  AssetImage('img/sign.png'),
  width: 1200,
);

// ── Helper: Roboto TextStyle shortcut ────────────────────────────────────────
TextStyle roboto({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = const Color(0xFF1A1A2E),
  double? height,
  double letterSpacing = 0,
}) => GoogleFonts.roboto(
  fontSize: fontSize,
  fontWeight: fontWeight,
  color: color,
  height: height,
  letterSpacing: letterSpacing,
);

// ── Input field ───────────────────────────────────────────────────────────────
class AuthInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.label,
    this.obscure = false,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.of(context).size.shortestSide / 390.0).clamp(
      0.92,
      1.08,
    );
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: roboto(fontSize: 15 * scale),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: roboto(fontSize: 13 * scale, color: Colors.grey.shade500),
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 16 * scale,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14 * scale),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14 * scale),
          borderSide: const BorderSide(color: kBlue, width: 1.6),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFB),
      ),
    );
  }
}

// ── Gradient button ───────────────────────────────────────────────────────────
class AuthGradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AuthGradientButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.of(context).size.shortestSide / 390.0).clamp(
      0.92,
      1.08,
    );
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54 * scale,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kBlue, kLightBlue],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(28 * scale),
          boxShadow: [
            BoxShadow(
              color: kBlue.withValues(alpha: 0.32),
              blurRadius: 16 * scale,
              offset: Offset(0, 6 * scale),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: roboto(
              fontSize: 15 * scale,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Or divider ────────────────────────────────────────────────────────────────
class AuthOrDivider extends StatelessWidget {
  final String label;
  const AuthOrDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: roboto(fontSize: 12, color: Colors.grey.shade400),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }
}

// ── Social row ────────────────────────────────────────────────────────────────
class AuthSocialRow extends StatelessWidget {
  final VoidCallback onGoogleTap;

  const AuthSocialRow({super.key, required this.onGoogleTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            onTap: onGoogleTap,
            logo: SvgPicture.asset(
              'img/google_logo.svg',
              width: 22,
              height: 22,
            ),
            label: 'Google',
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget logo;
  final String label;

  const _SocialButton({
    required this.onTap,
    required this.logo,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.of(context).size.shortestSide / 390.0).clamp(
      0.92,
      1.08,
    );
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50 * scale,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14 * scale),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8 * scale,
              offset: Offset(0, 3 * scale),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            logo,
            const SizedBox(width: 10),
            Text(
              label,
              style: roboto(fontSize: 13 * scale, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared gradient header ────────────────────────────────────────────────────
class AuthHeader extends StatelessWidget {
  final String trailingText;
  final String actionLabel;
  final VoidCallback onActionTap;

  const AuthHeader({
    super.key,
    required this.trailingText,
    required this.actionLabel,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;
    // Responsive header: 36% of screen height on small phones, 32% on large
    final headerH = screenH * (screenH < 700 ? 0.38 : 0.34) + topPad;
    final horizontalPadding = screenW < 360 ? 14.0 : 20.0;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: kSignHeaderImageProvider,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
        ),
      ),
      height: headerH,
      padding: EdgeInsets.only(
        top: topPad + 8,
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: 20,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Top bar ────────────────────────────────────────────────
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onActionTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        actionLabel.toUpperCase(),
                        style: roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
