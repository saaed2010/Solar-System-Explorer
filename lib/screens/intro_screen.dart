import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Process-local state intentionally resets only when Android starts a new
/// Flutter process. It prevents lifecycle resumes and route rebuilds from
/// replaying the cinematic.
class IntroSession {
  IntroSession._();

  static bool _consumed = false;

  static bool consume() {
    if (_consumed) return false;
    _consumed = true;
    return true;
  }

  @visibleForTesting
  static void reset() => _consumed = false;
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({
    required this.destination,
    super.key,
    this.enabled = true,
  });

  final Widget destination;
  final bool enabled;

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  static const _startupArtwork = <String>[
    'sun',
    'mercury',
    'venus',
    'earth',
    'mars',
    'jupiter',
    'saturn',
    'uranus',
    'neptune',
  ];

  VideoPlayerController? _controller;
  late final AnimationController _loadingController;
  Timer? _failSafe;
  Timer? _disposeVideoTimer;
  bool _showVideo = false;
  bool _finished = false;
  bool _preloadStarted = false;
  bool _reduceMotion = false;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _lifecycleState =
        WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
    if (widget.enabled && _isAndroid && IntroSession.consume()) {
      _showVideo = true;
      unawaited(_initializeVideo());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_showVideo && !_finished) {
      if (_reduceMotion) {
        _loadingController
          ..stop()
          ..value = 0.2;
      } else if (_lifecycleState == AppLifecycleState.resumed &&
          !_loadingController.isAnimating) {
        _loadingController.repeat();
      }
    }
    if (_showVideo && !_preloadStarted) {
      _preloadStarted = true;
      unawaited(_preloadFirstScreen());
    }
  }

  Future<void> _preloadFirstScreen() async {
    try {
      await Future.wait<void>(
        _startupArtwork.map(
          (id) =>
              precacheImage(AssetImage('assets/celestial/$id.png'), context),
        ),
      );
    } on Object {
      // The app remains usable even if an individual cache warm-up fails.
    }
  }

  Future<void> _initializeVideo() async {
    final controller = VideoPlayerController.asset(
      'assets/video/solar_system_intro.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
    );
    _controller = controller;

    try {
      await controller.initialize().timeout(const Duration(seconds: 4));
      if (!mounted || _finished) return;
      await controller.setLooping(false);
      await controller.setVolume(1);
      controller.addListener(_handleVideoState);
      if (_lifecycleState == AppLifecycleState.resumed) {
        await controller.play();
        _scheduleFailSafe();
      }
      if (mounted && !_finished) setState(() {});
    } on Object {
      _finish();
    }
  }

  void _handleVideoState() {
    final value = _controller?.value;
    if (value == null) return;
    if (value.hasError || value.isCompleted) _finish();
  }

  void _scheduleFailSafe() {
    _failSafe?.cancel();
    final value = _controller?.value;
    if (value == null || !value.isInitialized) return;
    final remaining = value.duration - value.position;
    _failSafe = Timer(
      (remaining.isNegative ? Duration.zero : remaining) +
          const Duration(seconds: 2),
      _finish,
    );
  }

  void _finish() {
    if (_finished || !mounted) return;
    _finished = true;
    _failSafe?.cancel();
    final controller = _controller;
    unawaited(controller?.pause());
    _loadingController.stop();
    setState(() => _showVideo = false);
    _disposeVideoTimer = Timer(const Duration(milliseconds: 360), () {
      controller?.removeListener(_handleVideoState);
      unawaited(controller?.dispose());
      if (identical(_controller, controller)) _controller = null;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _finished) {
      return;
    }
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(controller.play());
        _scheduleFailSafe();
        if (!_reduceMotion && !_loadingController.isAnimating) {
          _loadingController.repeat();
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _failSafe?.cancel();
        unawaited(controller.pause());
        _loadingController.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _failSafe?.cancel();
    _disposeVideoTimer?.cancel();
    _loadingController.dispose();
    _controller?.removeListener(_handleVideoState);
    unawaited(_controller?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF02040B),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 520),
        reverseDuration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (currentChild, previousChildren) => Stack(
          fit: StackFit.expand,
          children: <Widget>[...previousChildren, ?currentChild],
        ),
        child: _showVideo
            ? _CinematicVideo(
                key: const ValueKey<String>('cinematic-intro'),
                controller: _controller,
                loadingAnimation: _loadingController,
              )
            : KeyedSubtree(
                key: const ValueKey<String>('solar-system-app'),
                child: widget.destination,
              ),
      ),
    );
  }
}

class _CinematicVideo extends StatelessWidget {
  const _CinematicVideo({
    required this.controller,
    required this.loadingAnimation,
    super.key,
  });

  final VideoPlayerController? controller;
  final Animation<double> loadingAnimation;

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    final initialized = controller?.value.isInitialized ?? false;

    return Semantics(
      label: 'Solar System Explorer cinematic introduction',
      image: true,
      child: ColoredBox(
        color: const Color(0xFF02040B),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(
              'assets/video/intro_poster.jpg',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
            ),
            if (initialized)
              ClipRect(
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: controller!.value.size.width,
                      height: controller.value.size.height,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 34,
              child: SafeArea(
                minimum: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: _OrbitLoadingIndicator(animation: loadingAnimation),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbitLoadingIndicator extends StatelessWidget {
  const _OrbitLoadingIndicator({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: 'Loading Solar System Explorer',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x8F050914),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x38DCEBFF)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox.square(
                dimension: 24,
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: animation,
                    builder: (context, _) => CustomPaint(
                      painter: _LoadingOrbitPainter(
                        phase: reduceMotion ? 0.2 : animation.value,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              const Text(
                'Loading…',
                style: TextStyle(
                  color: Color(0xFFE8F2FF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingOrbitPainter extends CustomPainter {
  const _LoadingOrbitPainter({required this.phase});

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final orbit = Rect.fromCenter(
      center: center,
      width: size.width * 0.86,
      height: size.height * 0.48,
    );
    canvas.drawOval(
      orbit,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = const Color(0x8296CFFF),
    );
    canvas.drawCircle(center, 2.8, Paint()..color = const Color(0xFFFFD58B));
    final angle = phase * math.pi * 2;
    final satellite = Offset(
      center.dx + orbit.width * 0.5 * math.cos(angle),
      center.dy + orbit.height * 0.5 * math.sin(angle),
    );
    canvas.drawCircle(satellite, 2.2, Paint()..color = const Color(0xFFD9F4FF));
  }

  @override
  bool shouldRepaint(covariant _LoadingOrbitPainter oldDelegate) =>
      oldDelegate.phase != phase;
}
