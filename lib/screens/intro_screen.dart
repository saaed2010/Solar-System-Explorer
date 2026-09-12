import 'dart:async';

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

class _IntroScreenState extends State<IntroScreen> with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  Timer? _failSafe;
  Timer? _disposeVideoTimer;
  bool _showVideo = false;
  bool _finished = false;

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.enabled && _isAndroid && IntroSession.consume()) {
      _showVideo = true;
      unawaited(_initializeVideo());
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
      await controller.play();
      final duration = controller.value.duration;
      _failSafe = Timer(duration + const Duration(seconds: 2), _finish);
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

  void _finish() {
    if (_finished || !mounted) return;
    _finished = true;
    _failSafe?.cancel();
    final controller = _controller;
    unawaited(controller?.pause());
    setState(() => _showVideo = false);
    _disposeVideoTimer = Timer(const Duration(milliseconds: 360), () {
      controller?.removeListener(_handleVideoState);
      unawaited(controller?.dispose());
      if (identical(_controller, controller)) _controller = null;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _finished) {
      return;
    }
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(controller.play());
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        unawaited(controller.pause());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _failSafe?.cancel();
    _disposeVideoTimer?.cancel();
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
  const _CinematicVideo({required this.controller, super.key});

  final VideoPlayerController? controller;

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
          ],
        ),
      ),
    );
  }
}
