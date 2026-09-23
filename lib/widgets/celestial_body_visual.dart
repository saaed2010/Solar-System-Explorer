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

  static const Set<String> _artworkIds = <String>{
    'sun',
    'mercury',
    'venus',
    'earth',
    'mars',
    'jupiter',
    'saturn',
    'uranus',
    'neptune',
    'pluto',
    'moon',
    'phobos',
    'deimos',
    'io',
    'europa',
    'ganymede',
    'callisto',
    'titan',
    'enceladus',
    'triton',
    'vesta',
    'bennu',
    'halley',
    '67p',
  };

  @override
  Widget build(BuildContext context) {
    final hasArtwork = _artworkIds.contains(body.id);
    final artworkExtent = body.id == 'halley' ? size : size * 0.812;
    return Semantics(
      image: true,
      label: 'Rendered view of ${body.name}',
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: size,
          child: hasArtwork
              ? Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Center(
                      child: SizedBox.square(
                        dimension: artworkExtent,
                        child: Image.asset(
                          'assets/celestial/${body.id}.png',
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                          gaplessPlayback: true,
                          excludeFromSemantics: true,
                        ),
                      ),
                    ),
                    CustomPaint(
                      painter: _ArtworkOverlayPainter(
                        body: body,
                        phase: phase,
                        glow: glow,
                      ),
                    ),
                  ],
                )
              : CustomPaint(
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

class _ArtworkOverlayPainter extends CustomPainter {
  const _ArtworkOverlayPainter({
    required this.body,
    required this.phase,
    required this.glow,
  });

  final CelestialBody body;
  final double phase;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final shortest = math.min(size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = shortest * 0.355;
    final colour = Color(body.palette.first);

    if (glow) {
      canvas.drawCircle(
        center,
        shortest * 0.49,
        Paint()
          ..shader =
              RadialGradient(
                colors: <Color>[
                  colour.withValues(alpha: body.isStar ? 0.23 : 0.09),
                  Colors.transparent,
                ],
                stops: const <double>[0.54, 1],
              ).createShader(
                Rect.fromCircle(center: center, radius: shortest * 0.49),
              ),
      );
    }

    if (body.id == 'earth') {
      final cloud = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = math.max(0.55, radius * 0.018)
        ..color = Colors.white.withValues(alpha: 0.18);
      final shift = math.sin(phase * math.pi * 2) * radius * 0.12;
      for (var i = -1; i <= 1; i++) {
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(center.dx + shift, center.dy + i * radius * 0.3),
            width: radius * 1.45,
            height: radius * 0.28,
          ),
          i.isEven ? 0.1 : math.pi,
          math.pi * 0.72,
          false,
          cloud,
        );
      }
    } else if (body.id == 'jupiter' ||
        body.id == 'saturn' ||
        body.id == 'neptune') {
      final band = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = math.max(0.45, radius * 0.012)
        ..color = Colors.white.withValues(alpha: 0.1);
      for (var i = -2; i <= 2; i++) {
        final y = center.dy + i * radius * 0.25;
        final halfWidth = math.sqrt(
          math.max(0, radius * radius - math.pow(y - center.dy, 2)),
        );
        final drift = math.sin(phase * math.pi * 2 + i) * radius * 0.05;
        canvas.drawLine(
          Offset(center.dx - halfWidth + drift, y),
          Offset(center.dx + halfWidth + drift, y),
          band,
        );
      }
    }

    if (body.id == 'earth' ||
        body.id == 'venus' ||
        body.id == 'uranus' ||
        body.id == 'neptune') {
      canvas.drawCircle(
        center,
        radius * 1.012,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(0.7, radius * 0.022)
          ..color = colour.withValues(alpha: 0.28),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArtworkOverlayPainter oldDelegate) =>
      oldDelegate.body.id != body.id ||
      oldDelegate.phase != phase ||
      oldDelegate.glow != glow;
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
    final radius = shortest * 0.355;
    final colours = body.palette.map(Color.new).toList(growable: false);

    if (body.isStar && glow) {
      _drawCorona(canvas, center, radius, colours);
    }

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

    if (body.type == BodyType.region) {
      _drawAsteroidField(canvas, center, radius, colours);
      return;
    }

    if (body.type == BodyType.asteroid ||
        body.type == BodyType.comet ||
        body.id == 'phobos' ||
        body.id == 'deimos') {
      _drawIrregularBody(canvas, center, radius, colours);
      return;
    }

    final sphereRect = body.id == 'haumea'
        ? Rect.fromCenter(
            center: center,
            width: radius * 2,
            height: radius * 1.42,
          )
        : Rect.fromCircle(center: center, radius: radius);
    final spherePath = Path()..addOval(sphereRect);
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
    canvas.drawPath(spherePath, sphere);

    canvas.save();
    canvas.clipPath(spherePath);
    _drawSurfaceGrain(canvas, center, radius, colours);
    switch (body.id) {
      case 'earth':
        _drawEarth(canvas, center, radius);
        _drawClouds(canvas, center, radius);
        break;
      case 'venus':
        _drawVenus(canvas, center, radius);
        break;
      case 'mars':
        _drawMars(canvas, center, radius);
        break;
      case 'jupiter':
      case 'saturn':
        _drawGasBands(canvas, center, radius);
        break;
      case 'uranus':
        _drawUranus(canvas, center, radius);
        break;
      case 'neptune':
        _drawNeptune(canvas, center, radius);
        break;
      case 'pluto':
        _drawPluto(canvas, center, radius);
        break;
      case 'moon':
        _drawMoonMaria(canvas, center, radius);
        _drawCraters(canvas, center, radius, count: 12);
        break;
      case 'io':
        _drawIo(canvas, center, radius);
        break;
      case 'europa':
        _drawEuropa(canvas, center, radius);
        break;
      case 'ganymede':
        _drawGanymede(canvas, center, radius);
        break;
      case 'callisto':
        _drawCallisto(canvas, center, radius);
        break;
      case 'titan':
        _drawTitan(canvas, center, radius);
        break;
      case 'enceladus':
        _drawEnceladus(canvas, center, radius);
        break;
      case 'triton':
        _drawTriton(canvas, center, radius);
        break;
      case 'ceres':
        _drawCeres(canvas, center, radius);
        break;
      case 'eris':
      case 'makemake':
      case 'haumea':
        _drawDwarfWorld(canvas, center, radius);
        break;
      case 'mercury':
        _drawCraters(canvas, center, radius, count: 15);
        break;
      default:
        if (body.type == BodyType.dwarfPlanet) {
          _drawCraters(canvas, center, radius);
        }
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
    canvas.drawPath(spherePath, shade);

    canvas.drawPath(
      spherePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.65, radius * 0.025)
        ..color = colours.first.withValues(alpha: body.isStar ? 0.42 : 0.30),
    );
    if (body.id == 'earth' ||
        body.id == 'venus' ||
        body.id == 'uranus' ||
        body.id == 'neptune') {
      canvas.drawCircle(
        center,
        radius * 1.018,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(0.8, radius * 0.035)
          ..color = colours.first.withValues(alpha: 0.22),
      );
    }

    if (body.id == 'saturn') {
      _drawRings(canvas, center, radius, colours, behind: false);
    }
  }

  void _drawSurfaceGrain(
    Canvas canvas,
    Offset center,
    double radius,
    List<Color> colours,
  ) {
    final seed = body.id.codeUnits.fold<int>(0, (value, unit) => value + unit);
    final count = radius < 10 ? 5 : (radius < 24 ? 12 : 24);
    for (var i = 0; i < count; i++) {
      final angle = i * 2.399 + seed * 0.013 + phase * 0.12;
      final distance = radius * (0.12 + ((i * 37 + seed) % 78) / 100);
      final point =
          center + Offset(math.cos(angle), math.sin(angle)) * distance;
      canvas.drawCircle(
        point,
        radius * (0.008 + (i % 4) * 0.004),
        Paint()
          ..color = (i.isEven ? Colors.white : colours.last).withValues(
            alpha: body.isStar ? 0.08 : 0.045,
          ),
      );
    }
  }

  void _drawClouds(Canvas canvas, Offset center, double radius) {
    final cloud = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(0.7, radius * 0.045)
      ..color = Colors.white.withValues(alpha: 0.24);
    final shift = math.sin(phase * math.pi * 2) * radius * 0.1;
    for (var i = -2; i <= 2; i++) {
      final y = center.dy + i * radius * 0.31;
      final halfWidth = math.sqrt(
        math.max(0, radius * radius - math.pow(y - center.dy, 2)),
      );
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(center.dx + shift, y),
          width: halfWidth * 1.45,
          height: radius * 0.18,
        ),
        math.pi * (i.isEven ? 0.12 : 1.05),
        math.pi * 0.72,
        false,
        cloud,
      );
    }
  }

  void _drawVenus(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = -5; i <= 5; i++) {
      final y = center.dy + i * radius * 0.17;
      final halfWidth = math.sqrt(
        math.max(0, radius * radius - math.pow(y - center.dy, 2)),
      );
      final wave = math.sin(i * 1.7 + phase * math.pi * 2) * radius * 0.09;
      final cloudPath = Path()
        ..moveTo(center.dx - halfWidth, y)
        ..quadraticBezierTo(
          center.dx - halfWidth * 0.25,
          y + wave,
          center.dx + halfWidth * 0.25,
          y - wave * 0.7,
        )
        ..quadraticBezierTo(
          center.dx + halfWidth * 0.7,
          y + wave * 0.35,
          center.dx + halfWidth,
          y,
        );
      paint
        ..strokeWidth = radius * (i.isEven ? 0.085 : 0.045)
        ..color = (i.isEven ? const Color(0xFFFFE3A4) : const Color(0xFF9D552B))
            .withValues(alpha: i.isEven ? 0.25 : 0.20);
      canvas.drawPath(cloudPath, paint);
    }
  }

  void _drawGasBands(Canvas canvas, Offset center, double radius) {
    final band = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final bandColours = body.id == 'jupiter'
        ? const <Color>[
            Color(0xFFF7E6C4),
            Color(0xFFB86D43),
            Color(0xFFE3B77F),
            Color(0xFF75483D),
          ]
        : const <Color>[
            Color(0xFFF5DFA4),
            Color(0xFFC7A96C),
            Color(0xFF9E804F),
            Color(0xFFF0CE8A),
          ];
    for (var i = -6; i <= 6; i++) {
      final y = center.dy + i * radius * 0.145;
      final halfWidth = math.sqrt(
        math.max(0, radius * radius - math.pow(y - center.dy, 2)),
      );
      band
        ..strokeWidth = radius * (i.isEven ? 0.11 : 0.065)
        ..color = bandColours[(i + 8) % bandColours.length].withValues(
          alpha: body.id == 'jupiter' ? 0.46 : 0.30,
        );
      final wave = math.sin(phase * math.pi * 2 + i * 1.3) * radius * 0.045;
      final path = Path()
        ..moveTo(center.dx - halfWidth, y)
        ..quadraticBezierTo(center.dx, y + wave, center.dx + halfWidth, y);
      canvas.drawPath(path, band);
    }
    if (body.id == 'jupiter') {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx + radius * 0.34, center.dy + radius * 0.24),
          width: radius * 0.55,
          height: radius * 0.29,
        ),
        Paint()..color = const Color(0xFFFFC09A).withValues(alpha: 0.34),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx + radius * 0.34, center.dy + radius * 0.24),
          width: radius * 0.43,
          height: radius * 0.20,
        ),
        Paint()..color = const Color(0xFFA83E32).withValues(alpha: 0.82),
      );
    }
  }

  void _drawEarth(Canvas canvas, Offset center, double radius) {
    final shift = math.sin(phase * math.pi * 2) * radius * 0.16;
    final land = Paint()..color = const Color(0xFF5D8F55);
    final africaEurope = Path()
      ..moveTo(center.dx - radius * 0.2 + shift, center.dy - radius * 0.62)
      ..cubicTo(
        center.dx + radius * 0.28 + shift,
        center.dy - radius * 0.67,
        center.dx + radius * 0.52 + shift,
        center.dy - radius * 0.3,
        center.dx + radius * 0.3 + shift,
        center.dy - radius * 0.08,
      )
      ..cubicTo(
        center.dx + radius * 0.18 + shift,
        center.dy + radius * 0.35,
        center.dx - radius * 0.03 + shift,
        center.dy + radius * 0.72,
        center.dx - radius * 0.18 + shift,
        center.dy + radius * 0.42,
      )
      ..cubicTo(
        center.dx - radius * 0.42 + shift,
        center.dy + radius * 0.08,
        center.dx - radius * 0.55 + shift,
        center.dy - radius * 0.22,
        center.dx - radius * 0.2 + shift,
        center.dy - radius * 0.62,
      )
      ..close();
    canvas.drawPath(africaEurope, land);
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - radius * 0.94 + shift, center.dy - radius * 0.43)
        ..cubicTo(
          center.dx - radius * 0.66 + shift,
          center.dy - radius * 0.62,
          center.dx - radius * 0.46 + shift,
          center.dy - radius * 0.17,
          center.dx - radius * 0.57 + shift,
          center.dy + radius * 0.08,
        )
        ..cubicTo(
          center.dx - radius * 0.46 + shift,
          center.dy + radius * 0.48,
          center.dx - radius * 0.66 + shift,
          center.dy + radius * 0.72,
          center.dx - radius * 0.76 + shift,
          center.dy + radius * 0.26,
        )
        ..close(),
      Paint()..color = const Color(0xFF6E9B59),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          center.dx + radius * 0.6 + shift,
          center.dy + radius * 0.46,
        ),
        width: radius * 0.42,
        height: radius * 0.22,
      ),
      Paint()..color = const Color(0xFF8A9D5B),
    );
  }

  void _drawMars(Canvas canvas, Offset center, double radius) {
    final mark = Paint()
      ..color = const Color(0xFF5A211C).withValues(alpha: 0.7);
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - radius * 0.82, center.dy - radius * 0.05)
        ..cubicTo(
          center.dx - radius * 0.45,
          center.dy - radius * 0.36,
          center.dx - radius * 0.15,
          center.dy + radius * 0.08,
          center.dx + radius * 0.12,
          center.dy - radius * 0.12,
        )
        ..cubicTo(
          center.dx + radius * 0.42,
          center.dy - radius * 0.3,
          center.dx + radius * 0.72,
          center.dy + radius * 0.06,
          center.dx + radius * 0.52,
          center.dy + radius * 0.23,
        )
        ..cubicTo(
          center.dx + radius * 0.14,
          center.dy + radius * 0.4,
          center.dx - radius * 0.43,
          center.dy + radius * 0.25,
          center.dx - radius * 0.82,
          center.dy - radius * 0.05,
        )
        ..close(),
      mark,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.18, center.dy + radius * 0.16),
        width: radius * 0.55,
        height: radius * 0.08,
      ),
      Paint()..color = const Color(0xFFDA7850).withValues(alpha: 0.42),
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.15, center.dy - radius * 0.86),
      radius * 0.25,
      Paint()..color = const Color(0xFFFFE5D2).withValues(alpha: 0.78),
    );
    _drawCraters(canvas, center, radius, count: 6);
  }

  void _drawUranus(Canvas canvas, Offset center, double radius) {
    final band = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.65, radius * 0.045)
      ..color = const Color(0xFFE0FFFF).withValues(alpha: 0.15);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.28);
    for (var i = -4; i <= 4; i++) {
      canvas.drawLine(
        Offset(-radius, i * radius * 0.17),
        Offset(radius, i * radius * 0.17),
        band,
      );
    }
    canvas.restore();
  }

  void _drawNeptune(Canvas canvas, Offset center, double radius) {
    final cloud = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(0.65, radius * 0.055)
      ..color = const Color(0xFF8FCBFF).withValues(alpha: 0.23);
    for (var i = -3; i <= 3; i++) {
      final y = center.dy + i * radius * 0.22;
      final halfWidth = math.sqrt(
        math.max(0, radius * radius - math.pow(y - center.dy, 2)),
      );
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(center.dx, y),
          width: halfWidth * 1.7,
          height: radius * 0.12,
        ),
        i.isEven ? 0.1 : math.pi,
        math.pi * 0.72,
        false,
        cloud,
      );
    }
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.32, center.dy + radius * 0.14),
        width: radius * 0.42,
        height: radius * 0.23,
      ),
      Paint()..color = const Color(0xFF101D58).withValues(alpha: 0.78),
    );
  }

  void _drawPluto(Canvas canvas, Offset center, double radius) {
    final heart = Path()
      ..moveTo(center.dx, center.dy + radius * 0.46)
      ..cubicTo(
        center.dx - radius * 0.62,
        center.dy + radius * 0.06,
        center.dx - radius * 0.54,
        center.dy - radius * 0.38,
        center.dx - radius * 0.18,
        center.dy - radius * 0.32,
      )
      ..cubicTo(
        center.dx,
        center.dy - radius * 0.28,
        center.dx + radius * 0.12,
        center.dy - radius * 0.38,
        center.dx + radius * 0.28,
        center.dy - radius * 0.26,
      )
      ..cubicTo(
        center.dx + radius * 0.54,
        center.dy,
        center.dx + radius * 0.28,
        center.dy + radius * 0.26,
        center.dx,
        center.dy + radius * 0.46,
      )
      ..close();
    canvas.drawPath(
      heart,
      Paint()..color = const Color(0xFFF0DED0).withValues(alpha: 0.78),
    );
    _drawCraters(canvas, center, radius, count: 7);
  }

  void _drawMoonMaria(Canvas canvas, Offset center, double radius) {
    final maria = Paint()
      ..color = const Color(0xFF51545A).withValues(alpha: 0.42);
    final regions = <Rect>[
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.28, center.dy - radius * 0.18),
        width: radius * 0.72,
        height: radius * 0.46,
      ),
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.38, center.dy + radius * 0.12),
        width: radius * 0.48,
        height: radius * 0.58,
      ),
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.08, center.dy + radius * 0.44),
        width: radius * 0.38,
        height: radius * 0.26,
      ),
    ];
    for (final region in regions) {
      canvas.drawOval(region, maria);
    }
  }

  void _drawIo(Canvas canvas, Offset center, double radius) {
    final colours = <Color>[
      const Color(0xFF8B351B),
      const Color(0xFFE36D18),
      const Color(0xFF6E4C23),
    ];
    for (var i = 0; i < 11; i++) {
      final angle = i * 2.399 + phase * 0.25;
      final distance = radius * (0.18 + (i % 4) * 0.19);
      final point =
          center + Offset(math.cos(angle), math.sin(angle)) * distance;
      canvas.drawCircle(
        point,
        radius * (0.045 + (i % 3) * 0.025),
        Paint()..color = colours[i % colours.length].withValues(alpha: 0.78),
      );
      if (i % 3 == 0) {
        canvas.drawCircle(
          point,
          radius * 0.022,
          Paint()..color = const Color(0xFF33201B).withValues(alpha: 0.75),
        );
      }
    }
  }

  void _drawEuropa(Canvas canvas, Offset center, double radius) {
    final fracture = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.55, radius * 0.022)
      ..color = const Color(0xFF8B493A).withValues(alpha: 0.62);
    for (var i = -4; i <= 4; i++) {
      final path = Path()
        ..moveTo(center.dx - radius, center.dy + i * radius * 0.18)
        ..cubicTo(
          center.dx - radius * 0.35,
          center.dy + (i * 0.18 + 0.18) * radius,
          center.dx + radius * 0.2,
          center.dy + (i * 0.18 - 0.12) * radius,
          center.dx + radius,
          center.dy + i * radius * 0.18,
        );
      canvas.drawPath(path, fracture);
    }
  }

  void _drawGanymede(Canvas canvas, Offset center, double radius) {
    final dark = Paint()
      ..color = const Color(0xFF4D4647).withValues(alpha: 0.36);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.34, center.dy - radius * 0.16),
        width: radius * 0.92,
        height: radius * 0.7,
      ),
      dark,
    );
    final groove = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.45, radius * 0.018)
      ..color = Colors.white.withValues(alpha: 0.18);
    for (var i = -3; i <= 3; i++) {
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(center.dx + i * radius * 0.08, center.dy),
          radius: radius * (0.35 + i.abs() * 0.06),
        ),
        -1.1,
        2.2,
        false,
        groove,
      );
    }
    _drawCraters(canvas, center, radius, count: 7);
  }

  void _drawCallisto(Canvas canvas, Offset center, double radius) {
    _drawCraters(canvas, center, radius, count: 18, highContrast: true);
  }

  void _drawTitan(Canvas canvas, Offset center, double radius) {
    final haze = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.8, radius * 0.075)
      ..color = const Color(0xFFFFC85B).withValues(alpha: 0.34);
    for (var i = -3; i <= 3; i++) {
      final y = center.dy + i * radius * 0.22;
      final halfWidth = math.sqrt(
        math.max(0, radius * radius - math.pow(y - center.dy, 2)),
      );
      canvas.drawLine(
        Offset(center.dx - halfWidth, y),
        Offset(center.dx + halfWidth, y),
        haze,
      );
    }
  }

  void _drawEnceladus(Canvas canvas, Offset center, double radius) {
    final fissure = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.55, radius * 0.022)
      ..color = const Color(0xFF67B9D4).withValues(alpha: 0.62);
    for (var i = -2; i <= 2; i++) {
      final x = center.dx + i * radius * 0.16;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(x, center.dy + radius * 0.42),
          width: radius * 0.26,
          height: radius * 0.9,
        ),
        -2.0,
        2.4,
        false,
        fissure,
      );
    }
    _drawCraters(canvas, center, radius, count: 5);
  }

  void _drawTriton(Canvas canvas, Offset center, double radius) {
    final cap = Paint()
      ..color = const Color(0xFFE7CCD5).withValues(alpha: 0.54);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - radius * 0.52),
        width: radius * 1.55,
        height: radius * 0.66,
      ),
      cap,
    );
    final plume = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.5, radius * 0.022)
      ..color = const Color(0xFF4A3442).withValues(alpha: 0.52);
    for (var i = 0; i < 4; i++) {
      final x = center.dx + (i - 1.5) * radius * 0.26;
      canvas.drawLine(
        Offset(x, center.dy - radius * 0.2),
        Offset(x + radius * 0.08, center.dy + radius * 0.45),
        plume,
      );
    }
  }

  void _drawCeres(Canvas canvas, Offset center, double radius) {
    _drawCraters(canvas, center, radius, count: 12, highContrast: true);
    final deposit = Paint()..color = Colors.white.withValues(alpha: 0.78);
    canvas.drawCircle(
      center + Offset(radius * 0.26, radius * 0.04),
      math.max(0.7, radius * 0.034),
      deposit,
    );
    canvas.drawCircle(
      center + Offset(radius * 0.31, radius * 0.07),
      math.max(0.45, radius * 0.02),
      deposit,
    );
  }

  void _drawDwarfWorld(Canvas canvas, Offset center, double radius) {
    final accent = switch (body.id) {
      'makemake' => const Color(0xFF9A4F35),
      'haumea' => const Color(0xFF8A6F68),
      _ => const Color(0xFFD9E5EA),
    };
    for (var i = 0; i < 7; i++) {
      final angle = i * 2.17 + phase * 0.16;
      final point =
          center +
          Offset(math.cos(angle), math.sin(angle)) *
              radius *
              (0.18 + (i % 3) * 0.22);
      canvas.drawOval(
        Rect.fromCenter(
          center: point,
          width: radius * (0.16 + (i % 2) * 0.09),
          height: radius * (0.08 + (i % 3) * 0.045),
        ),
        Paint()..color = accent.withValues(alpha: 0.18),
      );
    }
    _drawCraters(canvas, center, radius, count: 5);
  }

  void _drawCraters(
    Canvas canvas,
    Offset center,
    double radius, {
    int count = 8,
    bool highContrast = false,
  }) {
    final crater = Paint()
      ..color = Colors.black.withValues(alpha: highContrast ? 0.34 : 0.18);
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.45, radius * 0.012)
      ..color = Colors.white.withValues(alpha: highContrast ? 0.28 : 0.13);
    final visibleCount = radius < 9 ? math.min(count, 4) : count;
    for (var i = 0; i < visibleCount; i++) {
      final angle = i * 2.31 + phase * 0.4;
      final distance = radius * (0.2 + (i % 3) * 0.22);
      final craterRadius = radius * (0.035 + (i % 3) * 0.018);
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * distance,
        craterRadius,
        crater,
      );
      if (radius >= 13 && i.isEven) {
        canvas.drawCircle(
          center + Offset(math.cos(angle), math.sin(angle)) * distance,
          craterRadius * 1.18,
          rim,
        );
      }
    }
  }

  void _drawCorona(
    Canvas canvas,
    Offset center,
    double radius,
    List<Color> colours,
  ) {
    final ray = Paint()
      ..strokeCap = StrokeCap.round
      ..color = colours.first.withValues(alpha: 0.16);
    final seed = body.id.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
    final rayCount = radius < 12 ? 8 : 18;
    for (var i = 0; i < rayCount; i++) {
      final angle = i / rayCount * math.pi * 2 + phase * 0.12;
      final variation = 0.12 + ((i * 29 + seed) % 22) / 100;
      final start =
          center + Offset(math.cos(angle), math.sin(angle)) * radius * 1.02;
      final end =
          center +
          Offset(math.cos(angle), math.sin(angle)) * radius * (1.1 + variation);
      ray.strokeWidth = math.max(0.45, radius * (i.isEven ? 0.016 : 0.01));
      canvas.drawLine(start, end, ray);
    }
  }

  void _drawStarTexture(Canvas canvas, Offset center, double radius) {
    final texture = Paint();
    for (var i = 0; i < 24; i++) {
      final angle = i * 2.399 + phase * math.pi * 0.7;
      final distance = radius * (0.12 + (i % 6) * 0.13);
      texture.color = (i % 3 == 0 ? Colors.black : Colors.white).withValues(
        alpha: i % 3 == 0 ? 0.055 : 0.12,
      );
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * distance,
        radius * (0.018 + (i % 3) * 0.012),
        texture,
      );
    }
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.68),
      phase * math.pi * 2,
      math.pi * 0.58,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.65, radius * 0.022)
        ..color = Colors.white.withValues(alpha: 0.09),
    );
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

      if (body.id == 'halley') {
        canvas.drawCircle(
          center,
          radius * 1.15,
          Paint()
            ..shader =
                RadialGradient(
                  colors: <Color>[
                    const Color(0xFFE9FCFF).withValues(alpha: 0.42),
                    const Color(0xFF76CDE4).withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ).createShader(
                  Rect.fromCircle(center: center, radius: radius * 1.15),
                ),
        );
        _drawRockLobe(canvas, center, radius * 0.52, const <Color>[
          Color(0xFFDCE9E8),
          Color(0xFF66777B),
          Color(0xFF20282C),
        ], seed: 76);
        canvas.drawCircle(
          center + Offset(-radius * 0.12, -radius * 0.14),
          math.max(0.65, radius * 0.09),
          Paint()..color = const Color(0xFFF4FFFF),
        );
        return;
      }
    }

    if (body.id == '67p') {
      _drawRockLobe(
        canvas,
        center + Offset(-radius * 0.24, radius * 0.08),
        radius * 0.72,
        colours,
        seed: 67,
      );
      _drawRockLobe(
        canvas,
        center + Offset(radius * 0.38, -radius * 0.18),
        radius * 0.54,
        colours,
        seed: 91,
      );
      return;
    }

    _drawRockLobe(
      canvas,
      center,
      radius,
      colours,
      seed: body.id.codeUnits.fold<int>(0, (sum, unit) => sum + unit),
    );

    if (body.id == 'vesta') {
      canvas.drawOval(
        Rect.fromCenter(
          center: center + Offset(radius * 0.18, radius * 0.44),
          width: radius * 0.72,
          height: radius * 0.42,
        ),
        Paint()..color = Colors.black.withValues(alpha: 0.24),
      );
    } else if (body.id == 'bennu') {
      final boulder = Paint()..color = Colors.white.withValues(alpha: 0.13);
      for (var i = 0; i < 11; i++) {
        final angle = i * 2.17 + phase * 0.3;
        final distance = radius * (0.18 + (i % 4) * 0.17);
        canvas.drawCircle(
          center + Offset(math.cos(angle), math.sin(angle)) * distance,
          radius * (0.025 + (i % 3) * 0.012),
          boulder,
        );
      }
    }
  }

  void _drawRockLobe(
    Canvas canvas,
    Offset center,
    double radius,
    List<Color> colours, {
    required int seed,
  }) {
    final path = Path();
    for (var i = 0; i < 14; i++) {
      final angle = i / 14 * math.pi * 2;
      var variation = 0.76 + ((i * 47 + seed * 13) % 31) / 100;
      if (body.id == 'bennu') {
        variation *= 0.86 + 0.22 * math.cos(angle).abs();
      }
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

  void _drawAsteroidField(
    Canvas canvas,
    Offset center,
    double radius,
    List<Color> colours,
  ) {
    final orbit = Rect.fromCenter(
      center: center,
      width: radius * 2.5,
      height: radius * 1.05,
    );
    canvas.drawOval(
      orbit,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.7, radius * 0.035)
        ..color = colours.first.withValues(alpha: 0.22),
    );
    for (var i = 0; i < 34; i++) {
      final angle = i * 2.399 + phase * 0.08;
      final spread = 0.78 + ((i * 19) % 23) / 100;
      final point = Offset(
        center.dx + math.cos(angle) * orbit.width * 0.5 * spread,
        center.dy + math.sin(angle) * orbit.height * 0.5 * spread,
      );
      canvas.drawCircle(
        point,
        radius * (i % 7 == 0 ? 0.045 : 0.022),
        Paint()..color = colours[i % colours.length].withValues(alpha: 0.82),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BodyPainter oldDelegate) =>
      oldDelegate.body.id != body.id ||
      oldDelegate.phase != phase ||
      oldDelegate.glow != glow;
}
