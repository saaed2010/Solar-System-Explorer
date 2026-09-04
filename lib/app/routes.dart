import 'package:flutter/material.dart';

import '../models/celestial_body.dart';
import '../screens/body_details_screen.dart';

Route<void> bodyDetailsRoute(CelestialBody body, {required String heroTag}) {
  return PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 720),
    reverseTransitionDuration: const Duration(milliseconds: 480),
    pageBuilder: (context, animation, secondaryAnimation) =>
        BodyDetailsScreen(body: body, heroTag: heroTag),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curve,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curve),
          alignment: Alignment.center,
          child: child,
        ),
      );
    },
  );
}
