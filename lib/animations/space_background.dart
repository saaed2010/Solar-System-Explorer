import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/app_theme.dart';

class SpaceBackground extends StatefulWidget {
  const SpaceBackground({required this.child, super.key, this.dense = false});

  final Widget child;
  final bool dense;

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 48),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0.28;
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
    return ColoredBox(
      color: AppColors.voidBlack,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const RepaintBoundary(
            child: CustomPaint(painter: _SpaceEnvironmentPainter()),
          ),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _StarFieldPainter(
                  phase: _controller.value,
                  count: widget.dense ? 118 : 82,
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _SpaceEnvironmentPainter extends CustomPainter {
  const _SpaceEnvironmentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final background = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.65, -0.7),
        radius: 1.25,
        colors: <Color>[Color(0xFF111D36), AppColors.voidBlack],
        stops: <double>[0, 0.78],
      ).createShader(rect);
    canvas.drawRect(rect, background);

    final haze = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.9, 0.15),
        radius: 0.75,
        colors: <Color>[
          AppColors.violet.withValues(alpha: 0.07),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, haze);
  }

  @override
  bool shouldRepaint(covariant _SpaceEnvironmentPainter oldDelegate) => false;
}

class _StarFieldPainter extends CustomPainter {
  const _StarFieldPainter({required this.phase, required this.count});

  final double phase;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    for (var i = 0; i < count; i++) {
      final depth = 0.25 + ((i * 37) % 73) / 100;
      final rawX = ((i * 83) % 997) / 997;
      final rawY = ((i * 149 + 47) % 991) / 991;
      final drift = phase * size.width * (0.006 + depth * 0.018);
      final x = (rawX * size.width + drift) % size.width;
      final y = rawY * size.height;
      final pulse = 0.55 + 0.45 * math.sin(phase * math.pi * 2 + i * 1.71);
      final radius = 0.35 + depth * 1.05;
      final star = Paint()
        ..color = (i % 11 == 0 ? const Color(0xFFBBD8FF) : Colors.white)
            .withValues(alpha: (0.18 + depth * 0.55) * pulse);
      canvas.drawCircle(Offset(x, y), radius, star);
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.count != count;
}
