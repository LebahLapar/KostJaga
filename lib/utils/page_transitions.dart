import 'package:flutter/material.dart';

// Slide Transition (dari kanan ke kiri)
class SlideRightRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideRightRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

// Slide Up Transition (dari bawah ke atas)
class SlideUpRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideUpRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}

// Fade Transition
class FadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

// Scale Transition (zoom in)
class ScaleRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ScaleRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOut;
            var tween = Tween(begin: 0.8, end: 1.0).chain(
              CurveTween(curve: curve),
            );

            return ScaleTransition(
              scale: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

// Rotation + Fade Transition
class RotationRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  RotationRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOut;
            var rotationTween = Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: curve),
            );

            return RotationTransition(
              turns: animation.drive(rotationTween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        );
}

// Custom combination: Slide + Fade
class SlideFadeRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideFadeRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.3, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var slideTween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(slideTween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        );
}

// Helper class untuk mudah pakai
class AppNavigator {
  // Slide dari kanan (default untuk push screens)
  static Future<T?> slideRight<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(SlideRightRoute(page: page));
  }

  // Slide dari bawah (untuk modal-like screens)
  static Future<T?> slideUp<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(SlideUpRoute(page: page));
  }

  // Fade (untuk subtle transitions)
  static Future<T?> fade<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(FadeRoute(page: page));
  }

  // Scale (untuk dialog-like screens)
  static Future<T?> scale<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(ScaleRoute(page: page));
  }

  // Slide + Fade (recommended untuk most screens)
  static Future<T?> slideFade<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(SlideFadeRoute(page: page));
  }

  // Replace dengan animation
  static Future<T?> replaceWith<T>(
    BuildContext context,
    Widget page, {
    bool useSlide = true,
  }) {
    return Navigator.of(context).pushReplacement<T, void>(
      useSlide ? SlideRightRoute(page: page) : FadeRoute(page: page),
    );
  }

  // Push and remove all previous routes
  static Future<T?> pushAndRemoveAll<T>(
    BuildContext context,
    Widget page, {
    bool useFade = true,
  }) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      useFade ? FadeRoute(page: page) : SlideRightRoute(page: page),
      (route) => false,
    );
  }
}