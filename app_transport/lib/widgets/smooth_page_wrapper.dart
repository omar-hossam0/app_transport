import 'package:flutter/material.dart';

/// Enhanced page wrapper with smooth transitions
class SmoothPageWrapper extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;

  const SmoothPageWrapper({Key? key, required this.child, this.backgroundColor})
    : super(key: key);

  @override
  State<SmoothPageWrapper> createState() => _SmoothPageWrapperState();
}

class _SmoothPageWrapperState extends State<SmoothPageWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: widget.backgroundColor ?? Colors.transparent,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Page transition configuration for better performance
class OptimizedPage<T> extends Page<T> {
  final WidgetBuilder pageBuilder;
  final Duration transitionDuration;
  final Duration reverseTransitionDuration;

  const OptimizedPage({
    required this.pageBuilder,
    this.transitionDuration = const Duration(milliseconds: 400),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    LocalKey? key,
    String? name,
    Object? arguments,
  }) : super(key: key, name: name, arguments: arguments);

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) =>
          pageBuilder(context),
      settings: this,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
      transitionsBuilder: _defaultTransitionsBuilder,
    );
  }

  static Widget _defaultTransitionsBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
      ),
      child: FadeTransition(
        opacity: animation.drive(CurveTween(curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
  }
}
