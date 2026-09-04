import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../animations/space_background.dart';
import '../app/app_theme.dart';
import '../data/celestial_catalog.dart';
import '../models/celestial_body.dart';
import '../widgets/celestial_body_visual.dart';
import '../widgets/glass_panel.dart';
import 'comparison_screen.dart';

class BodyDetailsScreen extends StatefulWidget {
  const BodyDetailsScreen({
    required this.body,
    required this.heroTag,
    super.key,
  });

  final CelestialBody body;
  final String heroTag;

  @override
  State<BodyDetailsScreen> createState() => _BodyDetailsScreenState();
}

class _BodyDetailsScreenState extends State<BodyDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  CelestialBody get body => widget.body;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !MediaQuery.disableAnimationsOf(context)) {
        _entrance.forward();
      } else {
        _entrance.value = 1;
      }
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _openComparison() {
    final reference = body.isStar
        ? CelestialCatalog.byId('sun')
        : body.id == 'earth'
        ? CelestialCatalog.byId('moon')
        : CelestialCatalog.byId('earth');
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 520),
        pageBuilder: (context, animation, secondaryAnimation) =>
            ComparisonScreen(
              initialFirst: body,
              initialSecond: reference,
              showBackButton: true,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parent = body.parentId == null
        ? null
        : CelestialCatalog.byId(body.parentId!);
    return Scaffold(
      body: SpaceBackground(
        dense: body.isStar,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: <Widget>[
                      IconButton.filledTonal(
                        tooltip: 'Back',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const Spacer(),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.panelSoft,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Text(
                            body.type.label.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.cyan,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final size = math.min(
                            260.0,
                            constraints.maxWidth * 0.67,
                          );
                          return Center(
                            child: Hero(
                              tag: widget.heroTag,
                              child: SlowlyRotatingBody(body: body, size: size),
                            ),
                          );
                        },
                      ),
                      _Entrance(
                        animation: _entrance,
                        start: 0.08,
                        end: 0.55,
                        offset: const Offset(0, 0.12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (parent != null)
                              Text(
                                'ORBITING ${parent.name.toUpperCase()}',
                                style: const TextStyle(
                                  color: AppColors.amber,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            Text(
                              body.name,
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              body.description,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      if (body.sizeNote != null) ...<Widget>[
                        const SizedBox(height: 14),
                        _Entrance(
                          animation: _entrance,
                          start: 0.2,
                          end: 0.62,
                          child: GlassPanel(
                            padding: const EdgeInsets.all(12),
                            color: const Color(0xD9211C18),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Icon(
                                  Icons.science_outlined,
                                  color: AppColors.amber,
                                  size: 19,
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Text(
                                    body.sizeNote!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      _Entrance(
                        animation: _entrance,
                        start: 0.24,
                        end: 0.72,
                        offset: const Offset(0, 0.08),
                        child: Row(
                          children: <Widget>[
                            Text(
                              'Quick facts',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const Spacer(),
                            Text(
                              '${body.quickFacts.length} readings',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 11),
                      _Entrance(
                        animation: _entrance,
                        start: 0.3,
                        end: 0.82,
                        offset: const Offset(0, 0.06),
                        child: _FactsGrid(facts: body.quickFacts),
                      ),
                      if (body.canCompare) ...<Widget>[
                        const SizedBox(height: 14),
                        _Entrance(
                          animation: _entrance,
                          start: 0.45,
                          end: 0.88,
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              key: const Key('open-comparison'),
                              onPressed: _openComparison,
                              icon: const Icon(Icons.straighten_rounded),
                              label: Text(
                                body.isStar
                                    ? 'Compare with the Sun'
                                    : 'Open size comparison',
                              ),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _Entrance(
                        animation: _entrance,
                        start: 0.52,
                        end: 1,
                        offset: const Offset(0, 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Field notes',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 10),
                            for (
                              var index = 0;
                              index < body.facts.length;
                              index++
                            )
                              Padding(
                                padding: const EdgeInsets.only(bottom: 9),
                                child: GlassPanel(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: 25,
                                        height: 25,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: AppColors.cyan.withValues(
                                            alpha: 0.12,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: AppColors.cyan,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 11),
                                      Expanded(
                                        child: Text(
                                          body.facts[index],
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
      ),
    );
  }
}

class _FactsGrid extends StatelessWidget {
  const _FactsGrid({required this.facts});

  final List<BodyFact> facts;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 3 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            for (final fact in facts)
              SizedBox(
                width: width,
                child: GlassPanel(
                  padding: const EdgeInsets.all(13),
                  borderRadius: 17,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 66),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          fact.label.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.9,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          fact.value,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Entrance extends StatelessWidget {
  const _Entrance({
    required this.animation,
    required this.start,
    required this.end,
    required this.child,
    this.offset = Offset.zero,
  });

  final Animation<double> animation;
  final double start;
  final double end;
  final Widget child;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: offset,
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
