import 'package:flutter/material.dart';

import '../app/app_theme.dart';
import '../models/celestial_body.dart';
import 'celestial_body_visual.dart';
import 'glass_panel.dart';

class BodyCard extends StatelessWidget {
  const BodyCard({
    required this.body,
    required this.onTap,
    required this.heroTag,
    super.key,
    this.subtitle,
  });

  final CelestialBody body;
  final VoidCallback onTap;
  final String heroTag;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Explore ${body.name}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: GlassPanel(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Hero(
                    tag: heroTag,
                    child: CelestialBodyVisual(body: body, size: 104),
                  ),
                ),
              ),
              Text(
                body.type.label.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.cyan,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.25,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                body.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle ?? _sizeLabel(body),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _sizeLabel(CelestialBody body) {
    if (body.diameterKm == null) {
      return body.distanceFromSun ?? 'Explore region';
    }
    final prefix = body.sizeIsApproximate ? '≈ ' : '';
    final value = body.diameterKm! >= 1000
        ? body.diameterKm!.toStringAsFixed(0)
        : body.diameterKm!.toStringAsFixed(1);
    return '$prefix$value km diameter';
  }
}
