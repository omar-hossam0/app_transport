import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Brand colours ────────────────────────────────────────────────────────────
const kBlue = Color(0xFF187BCD);
const kLightBlue = Color(0xFF5BC0EB);
const kAuthHeaderEdgeBlue = Color(0xFF072F5D);
const kAuthLightBlueBg = Color(0xFFEEF5FB);

const kAuthBgGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFFE8F2FA), // subtle light sky blue
    Color(0xFFF3F8FD), // soft light blue
  ],
);

const kSignHeaderImageProvider = ResizeImage(
  AssetImage('img/sign.png'),
  width: 1000,
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

// ── Circular Drone Emblem with Tech Engravings / Patterns ────────────────────
class AuthCircularBadge extends StatelessWidget {
  final double size;

  const AuthCircularBadge({super.key, this.size = 160});

  @override
  Widget build(BuildContext context) {
    final shortest = MediaQuery.of(context).size.shortestSide;
    final scale = (shortest / 390.0).clamp(0.85, 1.15);
    final badgeDiameter = size * scale;
    final canvasDiameter = badgeDiameter * 1.5;

    return Center(
      child: SizedBox(
        width: canvasDiameter,
        height: canvasDiameter,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative background patterns (orbital rings, ticks, satellite nodes, radiant glow)
            CustomPaint(
              size: Size(canvasDiameter, canvasDiameter),
              painter: _TechPatternPainter(),
            ),

            // Center Badge
            Container(
              width: badgeDiameter,
              height: badgeDiameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3.5 * scale,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF187BCD).withValues(alpha: 0.24),
                    blurRadius: 24 * scale,
                    offset: Offset(0, 10 * scale),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.9),
                    blurRadius: 10 * scale,
                    offset: Offset(0, -3 * scale),
                  ),
                ],
              ),
              child: ClipOval(
                child: Container(
                  color: const Color(0xFF072F5D),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const Image(
                        image: kSignHeaderImageProvider,
                        fit: BoxFit.cover,
                        alignment: Alignment(0, -0.22),
                      ),
                      // Soft rim vignette overlay for smooth blending
                      DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                          gradient: RadialGradient(
                            colors: [
                              Colors.transparent,
                              const Color(0xFF072F5D).withValues(alpha: 0.35),
                            ],
                            stops: const [0.78, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TechPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // 1. Soft radiant ambient halo
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF5BC0EB).withValues(alpha: 0.26),
          const Color(0xFF187BCD).withValues(alpha: 0.10),
          Colors.transparent,
        ],
        stops: const [0.35, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 0.95));
    canvas.drawCircle(center, maxRadius * 0.95, glowPaint);

    // 2. Segmented Outer Orbital Ring
    final orbitalRadius = maxRadius * 0.77;
    final ringPaint = Paint()
      ..color = const Color(0xFF187BCD).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    // Draw segmented orbital arcs with gaps for satellite nodes
    const gapAngle = 0.22; // radians
    for (int i = 0; i < 4; i++) {
      final startAngle = (i * math.pi / 2) + (math.pi / 4) + (gapAngle / 2);
      final sweepAngle = (math.pi / 2) - gapAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: orbitalRadius),
        startAngle,
        sweepAngle,
        false,
        ringPaint,
      );
    }

    // 3. Tech Hash Ticks (نقوشات فنية دائرية مستوحاة من الملاحة والدرون)
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int deg = 0; deg < 360; deg += 15) {
      final rad = deg * math.pi / 180.0;
      final isMajor = deg % 90 == 0;
      final isSemiMajor = deg % 45 == 0;

      final length = isMajor ? 8.0 : (isSemiMajor ? 5.5 : 3.5);
      tickPaint.strokeWidth = isMajor ? 1.8 : (isSemiMajor ? 1.4 : 1.0);
      tickPaint.color = isMajor
          ? const Color(0xFF187BCD).withValues(alpha: 0.45)
          : (isSemiMajor
              ? const Color(0xFF187BCD).withValues(alpha: 0.30)
              : const Color(0xFF187BCD).withValues(alpha: 0.18));

      final r1 = orbitalRadius - (length / 2);
      final r2 = orbitalRadius + (length / 2);

      final p1 = Offset(center.dx + r1 * math.cos(rad), center.dy + r1 * math.sin(rad));
      final p2 = Offset(center.dx + r2 * math.cos(rad), center.dy + r2 * math.sin(rad));

      canvas.drawLine(p1, p2, tickPaint);
    }

    // 4. Satellite Nodes at 45°, 135°, 225°, 315°
    final nodeOuterPaint = Paint()
      ..color = const Color(0xFF187BCD).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final nodeInnerPaint = Paint()
      ..color = const Color(0xFF5BC0EB)
      ..style = PaintingStyle.fill;

    for (final angle in [math.pi / 4, 3 * math.pi / 4, 5 * math.pi / 4, 7 * math.pi / 4]) {
      final nodeCenter = Offset(
        center.dx + orbitalRadius * math.cos(angle),
        center.dy + orbitalRadius * math.sin(angle),
      );
      canvas.drawCircle(nodeCenter, 5.0, nodeOuterPaint);
      canvas.drawCircle(nodeCenter, 2.5, nodeInnerPaint);
    }

    // 5. Fine inner decorative orbit
    final innerOrbitPaint = Paint()
      ..color = const Color(0xFF5BC0EB).withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, maxRadius * 0.68, innerOrbitPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Top Bar with back button ──────────────────────────────────────────────────
class AuthTopBar extends StatelessWidget {
  final VoidCallback? onBackTap;
  final Widget? trailing;

  const AuthTopBar({super.key, this.onBackTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (canPop)
            GestureDetector(
              onTap: onBackTap ?? () => Navigator.of(context).maybePop(),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xFF1E293B),
                  size: 26,
                ),
              ),
            )
          else
            const SizedBox(width: 42, height: 42),
          if (trailing != null) trailing! else const SizedBox(width: 42),
        ],
      ),
    );
  }
}

// ── Modern Input field ────────────────────────────────────────────────────────
class AuthInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.obscure = false,
    this.keyboardType,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.of(context).size.shortestSide / 390.0).clamp(0.92, 1.08);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.035),
            blurRadius: 10 * scale,
            offset: Offset(0, 3 * scale),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: roboto(
          fontSize: 15 * scale,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle: roboto(
            fontSize: 13 * scale,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
          hintStyle: roboto(
            fontSize: 14 * scale,
            color: const Color(0xFF94A3B8),
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 18 * scale,
            vertical: 17 * scale,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16 * scale),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16 * scale),
            borderSide: const BorderSide(color: kBlue, width: 1.8),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

// ── Modern Gradient Action Button ─────────────────────────────────────────────
class AuthGradientButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;
  final IconData? icon;

  const AuthGradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<AuthGradientButton> createState() => _AuthGradientButtonState();
}

class _AuthGradientButtonState extends State<AuthGradientButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.of(context).size.shortestSide / 390.0).clamp(0.92, 1.08);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          width: double.infinity,
          height: 56 * scale,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0284C7), // Sky/Azure blue
                Color(0xFF187BCD), // Primary brand blue
                Color(0xFF0369A1), // Deep royal blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18 * scale),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF187BCD).withValues(alpha: 0.38),
                blurRadius: 18 * scale,
                offset: Offset(0, 8 * scale),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.20),
                blurRadius: 6 * scale,
                offset: Offset(0, 2 * scale),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.label,
                        style: roboto(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 28), // balance arrow icon
                      Text(
                        widget.label,
                        style: roboto(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.icon ?? Icons.arrow_forward_rounded,
                          size: 15 * scale,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
        Expanded(child: Divider(color: const Color(0xFFCBD5E1), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: roboto(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ),
        Expanded(child: Divider(color: const Color(0xFFCBD5E1), thickness: 1)),
      ],
    );
  }
}

// ── Social row ────────────────────────────────────────────────────────────────
class AuthSocialRow extends StatelessWidget {
  final VoidCallback onGoogleTap;
  final String label;

  const AuthSocialRow({
    super.key,
    required this.onGoogleTap,
    this.label = 'Login with Google',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            onTap: onGoogleTap,
            logo: SvgPicture.asset(
              'img/google_logo.svg',
              width: 20,
              height: 20,
            ),
            label: label,
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
    final scale = (MediaQuery.of(context).size.shortestSide / 390.0).clamp(0.92, 1.08);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52 * scale,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 10 * scale,
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
              style: roboto(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Legacy AuthHeader kept for backwards compatibility if referenced ─────────
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
    return Column(
      children: [
        AuthTopBar(
          trailing: GestureDetector(
            onTap: onActionTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: kBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                actionLabel.toUpperCase(),
                style: roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kBlue,
                ),
              ),
            ),
          ),
        ),
        const AuthCircularBadge(),
      ],
    );
  }
}
