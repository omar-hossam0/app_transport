import 'package:flutter/material.dart';
import 'page_transition.dart';

/// Navigation helper with smooth page transitions
class SmoothNavigation {
  /// Navigate to a page with slide up animation
  static Future<T?> slideUp<T>(
    BuildContext context,
    WidgetBuilder pageBuilder, {
    String routeName = '',
    Duration duration = const Duration(milliseconds: 450),
    bool rootNavigator = false,
  }) {
    return Navigator.of(context, rootNavigator: rootNavigator).push<T>(
      PageTransition.slideInUp(
        builder: pageBuilder,
        settings: routeName,
        duration: duration,
      ),
    );
  }

  /// Navigate to a page with zoom animation
  static Future<T?> zoomIn<T>(
    BuildContext context,
    WidgetBuilder pageBuilder, {
    String routeName = '',
    Duration duration = const Duration(milliseconds: 400),
    bool rootNavigator = false,
  }) {
    return Navigator.of(context, rootNavigator: rootNavigator).push<T>(
      PageTransition.zoomIn(
        builder: pageBuilder,
        settings: routeName,
        duration: duration,
      ),
    );
  }

  /// Navigate to a page with slide from right animation
  static Future<T?> slideRight<T>(
    BuildContext context,
    WidgetBuilder pageBuilder, {
    String routeName = '',
    Duration duration = const Duration(milliseconds: 450),
    bool rootNavigator = false,
  }) {
    return Navigator.of(context, rootNavigator: rootNavigator).push<T>(
      PageTransition.slideInRight(
        builder: pageBuilder,
        settings: routeName,
        duration: duration,
      ),
    );
  }

  /// Navigate to a page with rotate animation
  static Future<T?> rotateIn<T>(
    BuildContext context,
    WidgetBuilder pageBuilder, {
    String routeName = '',
    Duration duration = const Duration(milliseconds: 500),
    bool rootNavigator = false,
  }) {
    return Navigator.of(context, rootNavigator: rootNavigator).push<T>(
      PageTransition.rotateIn(
        builder: pageBuilder,
        settings: routeName,
        duration: duration,
      ),
    );
  }

  /// Replace current page with smooth transition
  static Future<T?> replaceWith<T>(
    BuildContext context,
    WidgetBuilder pageBuilder, {
    String routeName = '',
    Duration duration = const Duration(milliseconds: 450),
    bool rootNavigator = false,
  }) {
    return Navigator.of(
      context,
      rootNavigator: rootNavigator,
    ).pushReplacement<T, void>(
      PageTransition.slideInUp(
        builder: pageBuilder,
        settings: routeName,
        duration: duration,
      ),
    );
  }

  /// Pop with smooth animation
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  /// Pop and push new page
  static Future<T?> popAndPushNamed<T extends Object?, TT extends Object?>(
    BuildContext context,
    String newRouteName, {
    TT? result,
    Duration duration = const Duration(milliseconds: 450),
  }) {
    return Navigator.of(
      context,
    ).popAndPushNamed<T, TT>(newRouteName, result: result);
  }
}
