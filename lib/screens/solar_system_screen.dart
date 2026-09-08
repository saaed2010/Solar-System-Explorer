import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../animations/space_background.dart';
import '../app/app_theme.dart';
import '../app/routes.dart';
import '../data/celestial_catalog.dart';
import '../models/celestial_body.dart';
import '../widgets/celestial_body_visual.dart';
import '../widgets/glass_panel.dart';

class SolarSystemScreen extends StatefulWidget {
  const SolarSystemScreen({super.key});

  @override
  State<SolarSystemScreen> createState() => _SolarSystemScreenState();
}

class _SolarSystemScreenState extends State<SolarSystemScreen>
    with SingleTickerProviderStateMixin {
  static const _speeds = <double>[0.5, 1, 2, 4];
  static const _visualSizes = <double>[13, 16, 17, 15, 29, 31, 23, 23];
  static const _orbitRates = <double>[
    4.15,
    1.62,
    1,
    0.80,
    0.44,
    0.33,
    0.23,
    0.18,
  ];

  late final AnimationController _orbitController;
  CelestialBody? _selected;
  Offset _cameraOffset = Offset.zero;
  bool _playing = true;
  double _speed = 1;
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 34),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (reduced == _reducedMotion) return;
    _reducedMotion = reduced;
    if (reduced) {
      _orbitController.stop();
    } else if (_playing) {
      _orbitController.repeat();
    }
  }

  @override
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() => _playing = !_playing);
    if (_playing && !_reducedMotion) {
      _orbitController.repeat();
    } else {
      _orbitController.stop();
    }
  }

  void _setSpeed(double speed) {
    if (_speed == speed) return;
    final currentValue = _orbitController.value;
    setState(() => _speed = speed);
    _orbitController.duration = Duration(milliseconds: (34000 / speed).round());
    _orbitController.value = currentValue;
    if (_playing && !_reducedMotion) _orbitController.repeat();
  }

  void _focus(CelestialBody body, {Offset cameraOffset = Offset.zero}) {
    final clearFocus = _selected?.id == body.id;
    setState(() {
      _selected = clearFocus ? null : body;
      _cameraOffset = clearFocus ? Offset.zero : cameraOffset;
    });
  }

  void _open(CelestialBody body) {
    Navigator.of(
      context,
    ).push(bodyDetailsRoute(body, heroTag: 'solar-${body.id}'));
  }

  @override
  Widget build(BuildContext context) {
    return SpaceBackground(
      dense: true,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'LIVE ORBIT LAB',
                              style: TextStyle(
                                color: AppColors.cyan,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                letterSpacing: 1.7,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Solar System',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.panelSoft,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          child: Text(
                            _reducedMotion
                                ? '◌  REDUCED MOTION'
                                : _playing
                                ? '●  SIMULATING'
                                : 'Ⅱ  PAUSED',
                            style: TextStyle(
                              color: _playing && !_reducedMotion
                                  ? AppColors.cyan
                                  : AppColors.muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Orbital spacing is visualized for exploration—not distance scale.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) => _buildStage(
                        Size(constraints.maxWidth, constraints.maxHeight),
                      ),
                    ),
                  ),
                  _MotionControls(
                    playing: _playing && !_reducedMotion,
                    speed: _speed,
                    reducedMotion: _reducedMotion,
                    speeds: _speeds,
                    onToggle: _togglePlayback,
                    onSpeed: _setSpeed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStage(Size size) {
    final planets = CelestialCatalog.planets;
    final orbitAreaHeight = math.max(150.0, size.height - 112);
    final maxRadius = math.max(
      62.0,
      math.min((size.width - 20) / 2, orbitAreaHeight / 1.25),
    );
    final center = Offset(size.width / 2, orbitAreaHeight * 0.49);
    final sun = CelestialCatalog.byId('sun');

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned.fill(
          child: _CameraMotion(
            offset: _cameraOffset,
            focused: _selected != null,
            reducedMotion: _reducedMotion,
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _SolarOrbitsPainter(
                        center: center,
                        maximumRadius: maxRadius,
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _orbitController,
                  builder: (context, _) {
                    final phase = _orbitController.value;
                    return Stack(
                      children: <Widget>[
                        for (var index = 0; index < planets.length; index++)
                          _orbitingPlanet(
                            body: planets[index],
                            index: index,
                            phase: phase,
                            center: center,
                            maximumRadius: maxRadius,
                          ),
                        _comet(phase, size, orbitAreaHeight),
                      ],
                    );
                  },
                ),
                Positioned(
                  left: center.dx - 31,
                  top: center.dy - 31,
                  child: _FocusTarget(
                    selected: _selected == null || _selected?.id == sun.id,
                    scale: _selected?.id == sun.id ? 1.2 : 1,
                    label: 'Focus on the Sun',
                    onTap: () => _focus(sun),
                    child: Hero(
                      tag: 'solar-sun',
                      child: CelestialBodyVisual(
                        body: sun,
                        size: 62,
                        phase: _orbitController.value,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 6,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            child: _selected == null
                ? _TapHint(key: const ValueKey('hint'))
                : _FocusedBodyPanel(
                    key: ValueKey(_selected!.id),
                    body: _selected!,
                    onExplore: () => _open(_selected!),
                    onClose: () => _focus(_selected!),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _orbitingPlanet({
    required CelestialBody body,
    required int index,
    required double phase,
    required Offset center,
    required double maximumRadius,
  }) {
    final normalizedRadius = 0.19 + index * 0.11;
    final radius = maximumRadius * normalizedRadius;
    final angle = phase * math.pi * 2 * _orbitRates[index] + index * 0.77;
    final position =
        center +
        Offset(math.cos(angle) * radius, math.sin(angle) * radius * 0.59);
    final visualSize = _visualSizes[index];

    return Positioned(
      left: position.dx - 24,
      top: position.dy - 24,
      child: _FocusTarget(
        key: ValueKey('focus-${body.id}'),
        selected: _selected == null || _selected?.id == body.id,
        scale: _selected?.id == body.id ? 1.38 : 1,
        label: 'Focus on ${body.name}',
        onTap: () => _focus(body, cameraOffset: (center - position) * 0.16),
        child: Hero(
          tag: 'solar-${body.id}',
          child: CelestialBodyVisual(
            body: body,
            size: visualSize,
            phase: (phase * (index + 1) * 0.7) % 1,
            glow: false,
          ),
        ),
      ),
    );
  }

  Widget _comet(double phase, Size size, double orbitAreaHeight) {
    final comet = CelestialCatalog.byId('halley');
    final progress = (phase * 1.35) % 1;
    return Positioned(
      left: -12 + progress * (size.width + 4),
      top: orbitAreaHeight * (0.12 + progress * 0.36),
      child: Opacity(
        opacity: _selected == null ? 0.8 : 0.2,
        child: Transform.rotate(
          angle: 0.45,
          child: CelestialBodyVisual(
            body: comet,
            size: 30,
            phase: phase,
            glow: false,
          ),
        ),
      ),
    );
  }
}

class _CameraMotion extends StatelessWidget {
  const _CameraMotion({
    required this.offset,
    required this.focused,
    required this.reducedMotion,
    required this.child,
  });

  final Offset offset;
  final bool focused;
  final bool reducedMotion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = reducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 560);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: focused ? 1.055 : 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, scale, scaledChild) {
        return Transform.scale(
          scale: scale,
          child: TweenAnimationBuilder<Offset>(
            tween: Tween<Offset>(end: offset),
            duration: duration,
            curve: Curves.easeOutCubic,
            builder: (context, value, translatedChild) {
              return Transform.translate(offset: value, child: translatedChild);
            },
            child: scaledChild,
          ),
        );
      },
      child: RepaintBoundary(child: child),
    );
  }
}

class _FocusTarget extends StatelessWidget {
  const _FocusTarget({
    required this.child,
    required this.selected,
    required this.scale,
    required this.label,
    required this.onTap,
    super.key,
  });

  final Widget child;
  final bool selected;
  final double scale;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: 48,
          child: Center(
            child: AnimatedOpacity(
              opacity: selected ? 1 : 0.22,
              duration: const Duration(milliseconds: 300),
              child: AnimatedScale(
                scale: scale,
                duration: const Duration(milliseconds: 460),
                curve: Curves.easeOutCubic,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SolarOrbitsPainter extends CustomPainter {
  const _SolarOrbitsPainter({
    required this.center,
    required this.maximumRadius,
  });

  final Offset center;
  final double maximumRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final orbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = AppColors.line.withValues(alpha: 0.62);
    for (var index = 0; index < 8; index++) {
      final radius = maximumRadius * (0.19 + index * 0.11);
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2,
          height: radius * 1.18,
        ),
        orbit,
      );
    }

    final dust = Paint()
      ..color = const Color(0xFFBDA487).withValues(alpha: 0.42);
    for (var i = 0; i < 90; i++) {
      final angle = i * 2.399;
      final radius = maximumRadius * (0.575 + ((i * 17) % 31) / 1000);
      canvas.drawCircle(
        center +
            Offset(math.cos(angle) * radius, math.sin(angle) * radius * 0.59),
        i % 8 == 0 ? 1.15 : 0.55,
        dust,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SolarOrbitsPainter oldDelegate) =>
      oldDelegate.center != center ||
      oldDelegate.maximumRadius != maximumRadius;
}

class _FocusedBodyPanel extends StatelessWidget {
  const _FocusedBodyPanel({
    required this.body,
    required this.onExplore,
    required this.onClose,
    super.key,
  });

  final CelestialBody body;
  final VoidCallback onExplore;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  body.type.label.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.cyan,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(body.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(
                  body.quickFacts
                      .take(2)
                      .map((fact) => '${fact.label}: ${fact.value}')
                      .join('  •  '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Clear focus',
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 20),
          ),
          FilledButton.tonalIcon(
            onPressed: onExplore,
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text('Explore'),
          ),
        ],
      ),
    );
  }
}

class _TapHint extends StatelessWidget {
  const _TapHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.panelSoft,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.line),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Text(
            'Tap a world to focus',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

class _MotionControls extends StatelessWidget {
  const _MotionControls({
    required this.playing,
    required this.speed,
    required this.reducedMotion,
    required this.speeds,
    required this.onToggle,
    required this.onSpeed,
  });

  final bool playing;
  final double speed;
  final bool reducedMotion;
  final List<double> speeds;
  final VoidCallback onToggle;
  final ValueChanged<double> onSpeed;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      borderRadius: 20,
      child: Row(
        children: <Widget>[
          IconButton.filledTonal(
            key: const Key('orbit-play-pause'),
            tooltip: playing ? 'Pause orbital motion' : 'Play orbital motion',
            onPressed: reducedMotion ? null : onToggle,
            icon: Icon(
              playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  for (final value in speeds)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(
                          '${value % 1 == 0 ? value.toInt() : value}×',
                        ),
                        selected: speed == value,
                        onSelected: reducedMotion
                            ? null
                            : (_) => onSpeed(value),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (reducedMotion)
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Tooltip(
                message: 'Motion reduced by system accessibility setting',
                child: Icon(
                  Icons.motion_photos_off_outlined,
                  color: AppColors.muted,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
