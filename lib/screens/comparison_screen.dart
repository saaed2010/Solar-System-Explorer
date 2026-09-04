import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../animations/space_background.dart';
import '../app/app_theme.dart';
import '../core/comparison_engine.dart';
import '../data/celestial_catalog.dart';
import '../models/celestial_body.dart';
import '../widgets/celestial_body_visual.dart';
import '../widgets/glass_panel.dart';

class ComparisonScreen extends StatefulWidget {
  const ComparisonScreen({
    super.key,
    this.initialFirst,
    this.initialSecond,
    this.showBackButton = false,
  });

  final CelestialBody? initialFirst;
  final CelestialBody? initialSecond;
  final bool showBackButton;

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  late CelestialBody _first;
  late CelestialBody _second;
  ComparisonMode _mode = ComparisonMode.trueScale;
  double _cameraZoom = 1;

  @override
  void initState() {
    super.initState();
    _first = widget.initialFirst ?? CelestialCatalog.byId('earth');
    _second = widget.initialSecond ?? CelestialCatalog.byId('moon');
  }

  void _swap() {
    setState(() {
      final oldFirst = _first;
      _first = _second;
      _second = oldFirst;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ratio = ComparisonEngine.diameterRatio(_first, _second);
    final uncertainty = _first.sizeIsApproximate || _second.sizeIsApproximate;
    return SpaceBackground(
      dense: true,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        if (widget.showBackButton)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: IconButton.filledTonal(
                              tooltip: 'Back',
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'SCALE LABORATORY',
                                style: TextStyle(
                                  color: AppColors.violet,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.6,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Compare worlds',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Every calculation uses physical diameter in kilometres.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _BodyPicker(
                            key: ValueKey('first-${_first.id}'),
                            label: 'BODY A',
                            value: _first,
                            onChanged: (body) => setState(() => _first = body),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: IconButton.filledTonal(
                            key: const Key('swap-comparison'),
                            tooltip: 'Swap bodies',
                            onPressed: _swap,
                            icon: const Icon(Icons.swap_horiz_rounded),
                          ),
                        ),
                        Expanded(
                          child: _BodyPicker(
                            key: ValueKey('second-${_second.id}'),
                            label: 'BODY B',
                            value: _second,
                            onChanged: (body) => setState(() => _second = body),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ComparisonMode>(
                        key: const Key('comparison-mode'),
                        segments: const <ButtonSegment<ComparisonMode>>[
                          ButtonSegment(
                            value: ComparisonMode.trueScale,
                            label: Text('True scale'),
                            icon: Icon(Icons.straighten_rounded),
                          ),
                          ButtonSegment(
                            value: ComparisonMode.readable,
                            label: Text('Readable'),
                            icon: Icon(Icons.visibility_outlined),
                          ),
                        ],
                        selected: <ComparisonMode>{_mode},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _mode = selection.first;
                            _cameraZoom = 1;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    GlassPanel(
                      padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                _mode == ComparisonMode.trueScale
                                    ? Icons.verified_outlined
                                    : Icons.info_outline,
                                color: _mode == ComparisonMode.trueScale
                                    ? AppColors.cyan
                                    : AppColors.amber,
                                size: 17,
                              ),
                              const SizedBox(width: 7),
                              Flexible(
                                child: Text(
                                  _mode == ComparisonMode.trueScale
                                      ? 'SAME PHYSICAL SCALE'
                                      : 'NOT TO SCALE — LEGIBILITY MODE',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _mode == ComparisonMode.trueScale
                                        ? AppColors.cyan
                                        : AppColors.amber,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                    letterSpacing: 1.15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 320,
                            child: _ComparisonStage(
                              first: _first,
                              second: _second,
                              mode: _mode,
                              cameraZoom: _cameraZoom,
                            ),
                          ),
                          if (_mode == ComparisonMode.trueScale) ...<Widget>[
                            Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.zoom_out,
                                  size: 18,
                                  color: AppColors.muted,
                                ),
                                Expanded(
                                  child: Slider(
                                    key: const Key('comparison-zoom'),
                                    min: 0.5,
                                    max: 3,
                                    divisions: 10,
                                    value: _cameraZoom,
                                    label: '${_cameraZoom.toStringAsFixed(1)}×',
                                    onChanged: (value) =>
                                        setState(() => _cameraZoom = value),
                                  ),
                                ),
                                const Icon(
                                  Icons.zoom_in,
                                  size: 18,
                                  color: AppColors.muted,
                                ),
                              ],
                            ),
                            Text(
                              'Camera zoom ${_cameraZoom.toStringAsFixed(1)}× — applied equally to both bodies',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    GlassPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'DIAMETER RATIO',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.3,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            ComparisonEngine.ratioLabel(_first, _second),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _relationship(ratio),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          if (uncertainty) ...<Widget>[
                            const SizedBox(height: 10),
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  Icons.science_outlined,
                                  color: AppColors.amber,
                                  size: 17,
                                ),
                                SizedBox(width: 7),
                                Expanded(
                                  child: Text(
                                    'At least one size is an observational estimate. The same calculation is used, but the underlying measurement is approximate.',
                                    style: TextStyle(
                                      color: AppColors.muted,
                                      height: 1.35,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _relationship(double ratio) {
    if (ratio == 1) return 'The selected diameters are equal.';
    if (ratio > 1) {
      return '${_first.name} is ${_formatRatio(ratio)} times wider than ${_second.name}.';
    }
    return '${_second.name} is ${_formatRatio(1 / ratio)} times wider than ${_first.name}.';
  }

  static String _formatRatio(double ratio) {
    if (ratio >= 100) return ratio.toStringAsFixed(0);
    if (ratio >= 10) return ratio.toStringAsFixed(1);
    return ratio.toStringAsFixed(2);
  }
}

class _BodyPicker extends StatelessWidget {
  const _BodyPicker({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final CelestialBody value;
  final ValueChanged<CelestialBody> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(12, 9, 8, 7),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<CelestialBody>(
              value: value,
              isExpanded: true,
              borderRadius: BorderRadius.circular(16),
              dropdownColor: AppColors.deepSpace,
              icon: const Icon(Icons.expand_more, size: 19),
              items: <DropdownMenuItem<CelestialBody>>[
                for (final body in CelestialCatalog.comparableBodies)
                  DropdownMenuItem<CelestialBody>(
                    value: body,
                    child: Text(
                      body.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (body) {
                if (body != null) onChanged(body);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonStage extends StatelessWidget {
  const _ComparisonStage({
    required this.first,
    required this.second,
    required this.mode,
    required this.cameraZoom,
  });

  final CelestialBody first;
  final CelestialBody second;
  final ComparisonMode mode;
  final double cameraZoom;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maximum = math.min(
          constraints.maxWidth * 0.42,
          constraints.maxHeight * 0.66,
        );
        final layout = ComparisonEngine.layout(
          first: first,
          second: second,
          mode: mode,
          maximumDiameter: maximum,
          readableMinimumDiameter: math.min(64, maximum * 0.54),
        );
        return ClipRect(
          child: Row(
            children: <Widget>[
              Expanded(
                child: _ScaledBody(
                  body: first,
                  diameter: layout.firstDiameter,
                  cameraZoom: cameraZoom,
                  trueScale: layout.isTrueScale,
                ),
              ),
              Container(
                width: 1,
                height: 210,
                color: AppColors.line.withValues(alpha: 0.65),
              ),
              Expanded(
                child: _ScaledBody(
                  body: second,
                  diameter: layout.secondDiameter,
                  cameraZoom: cameraZoom,
                  trueScale: layout.isTrueScale,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScaledBody extends StatelessWidget {
  const _ScaledBody({
    required this.body,
    required this.diameter,
    required this.cameraZoom,
    required this.trueScale,
  });

  final CelestialBody body;
  final double diameter;
  final double cameraZoom;
  final bool trueScale;

  @override
  Widget build(BuildContext context) {
    final effectiveDiameter = diameter * cameraZoom;
    final needsLocator = trueScale && effectiveDiameter < 5;
    return Column(
      children: <Widget>[
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                if (needsLocator)
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 620),
                  curve: Curves.easeInOutCubic,
                  width: math.max(0.1, effectiveDiameter),
                  height: math.max(0.1, effectiveDiameter),
                  child: CelestialBodyVisual(
                    body: body,
                    size: math.max(0.1, effectiveDiameter),
                    glow: false,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          body.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          '${body.sizeIsApproximate ? '≈ ' : ''}${_diameter(body.diameterKm!)} km',
          maxLines: 1,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
        ),
        SizedBox(
          height: 17,
          child: needsLocator
              ? const Text(
                  'locator ring',
                  style: TextStyle(color: AppColors.cyan, fontSize: 9),
                )
              : null,
        ),
      ],
    );
  }

  static String _diameter(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(2)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    if (value >= 10) return value.toStringAsFixed(1);
    return value.toStringAsFixed(3);
  }
}
