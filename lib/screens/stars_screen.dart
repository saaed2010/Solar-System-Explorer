import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../animations/space_background.dart';
import '../app/app_theme.dart';
import '../app/routes.dart';
import '../core/comparison_engine.dart';
import '../data/celestial_catalog.dart';
import '../models/celestial_body.dart';
import '../widgets/body_card.dart';
import '../widgets/celestial_body_visual.dart';
import '../widgets/glass_panel.dart';

class StarsScreen extends StatelessWidget {
  const StarsScreen({super.key});

  void _open(BuildContext context, CelestialBody body, String source) {
    Navigator.of(
      context,
    ).push(bodyDetailsRoute(body, heroTag: '$source-${body.id}'));
  }

  @override
  Widget build(BuildContext context) {
    final stars = CelestialCatalog.stars;
    final sun = CelestialCatalog.byId('sun');
    final feature = CelestialCatalog.byId('betelgeuse');
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = math.max(16.0, (viewportWidth - 1280) / 2);

    return SpaceBackground(
      dense: true,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                18,
                horizontalPadding,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'STELLAR OBSERVATORY',
                      style: TextStyle(
                        color: AppColors.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Stars explorer',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'From a quiet red dwarf to stars large enough to swallow planetary orbits.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => _open(context, feature, 'stars-feature'),
                      child: GlassPanel(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: <Widget>[
                            Hero(
                              tag: 'stars-feature-${feature.id}',
                              child: SlowlyRotatingBody(
                                body: feature,
                                size: 116,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Text(
                                    'FEATURED SCALE',
                                    style: TextStyle(
                                      color: AppColors.amber,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    feature.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    ComparisonEngine.ratioLabel(feature, sun),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: AppColors.starlight),
                                  ),
                                  const SizedBox(height: 7),
                                  const Row(
                                    children: <Widget>[
                                      Text(
                                        'Explore star',
                                        style: TextStyle(
                                          color: AppColors.cyan,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: AppColors.cyan,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: <Widget>[
                        Text(
                          'KNOWN LIGHTS',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Text(
                          '${stars.length} stars',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                24,
              ),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemCount: stars.length,
                itemBuilder: (context, index) {
                  final star = stars[index];
                  final ratio = ComparisonEngine.diameterRatio(star, sun);
                  return BodyCard(
                    body: star,
                    heroTag: 'stars-grid-${star.id}',
                    subtitle: '≈ ${_formatRatio(ratio)} × Sun diameter',
                    onTap: () => _open(context, star, 'stars-grid'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatRatio(double ratio) {
    if (ratio >= 100) return ratio.toStringAsFixed(0);
    if (ratio >= 10) return ratio.toStringAsFixed(1);
    return ratio.toStringAsFixed(2);
  }
}
