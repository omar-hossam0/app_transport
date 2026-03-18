import 'package:flutter/material.dart';

/// Custom page transition animations for smooth navigation between pages
class PageTransition {
  /// Fade + Slide transition (smooth entry from bottom)
  static PageRoute<T> slideInUp<T>({
    required WidgetBuilder builder,
    required String settings,
    Duration duration = const Duration(milliseconds: 450),
  }) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: settings),
      transitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(
              Tween<double>(
                begin: 0.85,
                end: 1.0,
              ).chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: child,
          ),
        );
      },
    );
  }

  /// Fade + Scale transition (smooth zoom entry)
  static PageRoute<T> zoomIn<T>({
    required WidgetBuilder builder,
    required String settings,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: settings),
      transitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleTween = Tween<double>(
          begin: 0.92,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        final fadeTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  /// Slide from right transition
  static PageRoute<T> slideInRight<T>({
    required WidgetBuilder builder,
    required String settings,
    Duration duration = const Duration(milliseconds: 450),
  }) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: settings),
      transitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(
          begin: const Offset(0.3, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(
              Tween<double>(
                begin: 0.7,
                end: 1.0,
              ).chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: child,
          ),
        );
      },
    );
  }

  /// Rotate + Fade transition
  static PageRoute<T> rotateIn<T>({
    required WidgetBuilder builder,
    required String settings,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: settings),
      transitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final rotateTween = Tween<double>(
          begin: -0.15,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        final scaleTween = Tween<double>(
          begin: 0.85,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return RotationTransition(
          turns: animation.drive(rotateTween),
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            child: FadeTransition(opacity: animation, child: child),
          ),
        );
      },
    );
  }
}

/// Smooth animated switcher for switching between widgets
class AnimatedPageSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration reverseDuration;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  final int? animationKey;

  const AnimatedPageSwitcher({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.reverseDuration = const Duration(milliseconds: 300),
    this.switchInCurve = Curves.easeOutCubic,
    this.switchOutCurve = Curves.easeInCubic,
    this.animationKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      reverseDuration: reverseDuration,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      transitionBuilder: (child, animation) {
        return _buildTransition(child, animation);
      },
      child: KeyedSubtree(key: ValueKey<int?>(animationKey), child: child),
    );
  }

  Widget _buildTransition(Widget child, Animation<double> animation) {
    // Smooth fade + scale transition
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.94,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: switchInCurve)),
      child: FadeTransition(
        opacity: animation.drive(CurveTween(curve: switchInCurve)),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: switchInCurve)),
          child: child,
        ),
      ),
    );
  }
}
