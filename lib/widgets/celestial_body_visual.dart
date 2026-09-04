import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/celestial_body.dart';

class CelestialBodyVisual extends StatelessWidget {
  const CelestialBodyVisual({
    required this.body,
    required this.size,
    super.key,
    this.phase = 0,
    this.glow = true,
  });

  final CelestialBody body;
  final double size;
  final double phase;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Procedural view of ${body.name}',
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _BodyPainter(body: body, phase: phase, glow: glow),
          ),
        ),
      ),
    );
  }
}

class SlowlyRotatingBody extends StatefulWidget {
  const SlowlyRotatingBody({
    required this.body,
    required this.size,
    super.key,
    this.glow = true,
  });

  final CelestialBody body;
  final double size;
  final bool glow;

  @override
  State<SlowlyRotatingBody> createState() => _SlowlyRotatingBodyState();
}

class _SlowlyRotatingBodyState extends State<SlowlyRotatingBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0.2;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CelestialBodyVisual(
        body: widget.body,
        size: widget.size,
        phase: _controller.value,
        glow: widget.glow,
      ),
    );
  }
}

class _BodyPainter extends CustomPainter {
  const _BodyPainter({
    required this.body,
    required this.phase,
    required this.glow,
  });

  final CelestialBody body;
  final double phase;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    // A single disk-to-widget ratio keeps scientific comparisons consistent.
    final radius = shortest * 0.36;
    final colours = body.palette.map(Color.new).toList(growable: false);

    if (glow) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            colours.first.withValues(alpha: body.isStar ? 0.35 : 0.14),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: shortest / 2));
      canvas.drawCircle(center, shortest / 2, glowPaint);
    }

    if (body.id == 'saturn') {
      _drawRings(canvas, center, radius, colours, behind: true);
    }

    if (body.type == BodyType.asteroid || body.type == BodyType.comet) {
      _drawIrregularBody(canvas, center, radius, colours);
      return;
    }

    final sphereRect = Rect.fromCircle(center: center, radius: radius);
    final sphere = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.42, -0.45),
        radius: 0.95,
        colors: <Color>[...colours, Colors.black],
        stops: List<double>.generate(
          colours.length + 1,
          (index) => index / colours.length,
        ),
      ).createShader(sphereRect);
    canvas.drawCircle(center, radius, sphere);

    canvas.save();
    canvas.clipPath(Path()..addOval(sphereRect));
    if (body.id == 'earth') _drawEarth(canvas, center, radius);
    if (body.id == 'jupiter' || body.id == 'saturn') {
      _drawGasBands(canvas, center, radius);
    }
    if (body.id == 'neptune') _drawStorm(canvas, center, radius);
    if (body.id == 'mars') _drawMars(canvas, center, radius);
    if (body.type == BodyType.moon || body.type == BodyType.dwarfPlanet) {
      _drawCraters(canvas, center, radius);
    }
    if (body.isStar) _drawStarTexture(canvas, center, radius);
    canvas.restore();

    final shade = Paint()
      ..shader = LinearGradient(
        colors: <Color>[
          Colors.transparent,
          Colors.transparent,
          Colors.black.withValues(alpha: 0.48),
        ],
        stops: const <double>[0, 0.48, 1],
      ).createShader(sphereRect);
    canvas.drawCircle(center, radius, shade);

    if (body.id == 'saturn') {
      _drawRings(canvas, center, radius, colours, behind: false);
    }
  }

  void _drawGasBands(Canvas canvas, Offset center, double radius) {
    final band = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = -4; i <= 4; i++) {
      final y = center.dy + i * radius * 0.19;
      final halfWidth = math.sqrt(
        math.max(0, radius * radius - math.pow(y - center.dy, 2)),
      );
      band
        ..strokeWidth = radius * (i.isEven ? 0.095 : 0.045)
        ..color = (i.isEven ? Colors.white : Colors.black).withValues(
          alpha: i.isEven ? 0.12 : 0.10,
        );
      final shift = math.sin(phase * math.pi * 2 + i) * radius * 0.08;
      canvas.drawLine(
        Offset(center.dx - halfWidth + shift, y),
        Offset(center.dx + halfWidth + shift, y),
        band,
      );
    }
    if (body.id == 'jupiter') {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx + radius * 0.34, center.dy + radius * 0.24),
          width: radius * 0.48,
          height: radius * 0.22,
        ),
        Paint()..color = const Color(0xFF9F4035).withValues(alpha: 0.75),
      );
    }
  }

  void _drawEarth(Canvas canvas, Offset center, double radius) {
    final land = Paint()
      ..color = const Color(0xFF69A86F).withValues(alpha: 0.86);
    final shift = math.sin(phase * math.pi * 2) * radius * 0.15;
    final path = Path()
      ..moveTo(center.dx - radius * 0.7 + shift, center.dy - radius * 0.24)
      ..quadraticBezierTo(
        center.dx - radius * 0.25 + shift,
        center.dy - radius * 0.7,
        center.dx + radius * 0.08 + shift,
        center.dy - radius * 0.2,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.38 + shift,
        center.dy + radius * 0.06,
        center.dx + radius * 0.05 + shift,
        center.dy + radius * 0.22,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.34 + shift,
        center.dy + radius * 0.3,
        center.dx - radius * 0.7 + shift,
        center.dy - radius * 0.24,
      )
      ..close();
    canvas.drawPath(path, land);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          center.dx + radius * 0.48 + shift,
          center.dy + radius * 0.42,
        ),
        width: radius * 0.55,
        height: radius * 0.28,
      ),
      land,
    );
  }

  void _drawMars(Canvas canvas, Offset center, double radius) {
    final mark = Paint()
      ..color = const Color(0xFF6C251D).withValues(alpha: 0.48);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.25, center.dy + radius * 0.05),
        width: radius * 0.85,
        height: radius * 0.28,
      ),
      mark,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.34, center.dy - radius * 0.38),
      radius * 0.11,
      Paint()..color = Colors.white.withValues(alpha: 0.65),
    );
  }

  void _drawStorm(Canvas canvas, Offset center, double radius) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.32, center.dy + radius * 0.14),
        width: radius * 0.38,
        height: radius * 0.22,
      ),
      Paint()..color = const Color(0xFF142961).withValues(alpha: 0.7),
    );
  }

  void _drawCraters(Canvas canvas, Offset center, double radius) {
    final crater = Paint()..color = Colors.black.withValues(alpha: 0.16);
    for (var i = 0; i < 8; i++) {
      final angle = i * 2.31 + phase * 0.4;
      final distance = radius * (0.2 + (i % 3) * 0.22);
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * distance,
        radius * (0.035 + (i % 3) * 0.018),
        crater,
      );
    }
  }

  void _drawStarTexture(Canvas canvas, Offset center, double radius) {
    final texture = Paint()..color = Colors.white.withValues(alpha: 0.13);
    for (var i = 0; i < 12; i++) {
      final angle = i * 1.89 + phase * math.pi * 2;
      final distance = radius * (0.18 + (i % 4) * 0.17);
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * distance,
        radius * (0.025 + (i % 2) * 0.02),
        texture,
      );
    }
  }

  void _drawRings(
    Canvas canvas,
    Offset center,
    double radius,
    List<Color> colours, {
    required bool behind,
  }) {
    final rect = Rect.fromCenter(
      center: center,
      width: radius * 2.7,
      height: radius * 0.88,
    );
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.16
      ..color = colours.first.withValues(alpha: behind ? 0.55 : 0.76);
    if (behind) {
      canvas.drawOval(rect, ring);
      ring
        ..strokeWidth = radius * 0.055
        ..color = Colors.white.withValues(alpha: 0.42);
      canvas.drawOval(rect.deflate(radius * 0.19), ring);
    } else {
      canvas.drawArc(rect, 0, math.pi, false, ring);
    }
  }

  void _drawIrregularBody(
    Canvas canvas,
    Offset center,
    double radius,
    List<Color> colours,
  ) {
    if (body.type == BodyType.comet) {
      final tail = Paint()
        ..shader =
            LinearGradient(
              colors: <Color>[
                Colors.transparent,
                colours.first.withValues(alpha: 0.5),
              ],
            ).createShader(
              Rect.fromLTWH(
                center.dx - radius * 2.8,
                center.dy - radius,
                radius * 3.3,
                radius * 2,
              ),
            );
      final tailPath = Path()
        ..moveTo(center.dx - radius * 2.8, center.dy - radius * 0.35)
        ..quadraticBezierTo(
          center.dx - radius,
          center.dy - radius * 0.8,
          center.dx,
          center.dy,
        )
        ..quadraticBezierTo(
          center.dx - radius,
          center.dy + radius * 0.8,
          center.dx - radius * 2.8,
          center.dy + radius * 0.35,
        )
        ..close();
      canvas.drawPath(tailPath, tail);
    }
    final path = Path();
    for (var i = 0; i < 14; i++) {
      final angle = i / 14 * math.pi * 2;
      final variation = 0.78 + ((i * 47) % 29) / 100;
      final point =
          center +
          Offset(math.cos(angle), math.sin(angle)) * radius * variation;
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    path.close();
    final bounds = Rect.fromCircle(center: center, radius: radius);
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.5, -0.5),
          colors: <Color>[...colours, Colors.black],
        ).createShader(bounds),
    );
    _drawCraters(canvas, center, radius);
  }

  @override
  bool shouldRepaint(covariant _BodyPainter oldDelegate) =>
      oldDelegate.body.id != body.id ||
      oldDelegate.phase != phase ||
      oldDelegate.glow != glow;
}
