import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../animations/space_background.dart';
import '../app/app_theme.dart';
import '../app/routes.dart';
import '../data/celestial_catalog.dart';
import '../models/celestial_body.dart';
import '../widgets/body_card.dart';

enum _CatalogFilter { all, planets, dwarfPlanets, moons, smallBodies }

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  _CatalogFilter _filter = _CatalogFilter.all;
  String _query = '';

  static const _labels = <_CatalogFilter, String>{
    _CatalogFilter.all: 'All',
    _CatalogFilter.planets: 'Planets',
    _CatalogFilter.dwarfPlanets: 'Dwarf planets',
    _CatalogFilter.moons: 'Moons',
    _CatalogFilter.smallBodies: 'Small bodies',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CelestialBody> get _results {
    final candidates = CelestialCatalog.bodies.where((body) {
      if (body.type == BodyType.star) return false;
      return switch (_filter) {
        _CatalogFilter.all => true,
        _CatalogFilter.planets => body.type == BodyType.planet,
        _CatalogFilter.dwarfPlanets => body.type == BodyType.dwarfPlanet,
        _CatalogFilter.moons => body.type == BodyType.moon,
        _CatalogFilter.smallBodies =>
          body.type == BodyType.asteroid ||
              body.type == BodyType.comet ||
              body.type == BodyType.region,
      };
    });
    if (_query.trim().isEmpty) return candidates.toList(growable: false);
    final normalized = _query.trim().toLowerCase();
    return candidates
        .where(
          (body) =>
              body.name.toLowerCase().contains(normalized) ||
              body.type.label.toLowerCase().contains(normalized) ||
              body.description.toLowerCase().contains(normalized),
        )
        .toList(growable: false);
  }

  void _open(CelestialBody body) {
    Navigator.of(
      context,
    ).push(bodyDetailsRoute(body, heroTag: 'explore-${body.id}'));
  }

  void _clearSearch() {
    _searchController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final results = _results;
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = math.max(16.0, (viewportWidth - 1280) / 2);
    return SpaceBackground(
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                      'LOCAL CELESTIAL CATALOG',
                      style: TextStyle(
                        color: AppColors.cyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Explore worlds',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Planets, dwarf planets, ocean worlds, rocky remnants and icy visitors.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Semantics(
                      textField: true,
                      label: 'Search celestial catalog',
                      child: TextField(
                        key: const Key('catalog-search'),
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        onSubmitted: (_) => FocusScope.of(context).unfocus(),
                        onChanged: (value) => setState(() => _query = value),
                        decoration: InputDecoration(
                          hintText: 'Search Europa, Mars, Halley…',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  onPressed: _clearSearch,
                                  icon: const Icon(Icons.close),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          for (final filter in _CatalogFilter.values)
                            Padding(
                              padding: const EdgeInsets.only(right: 7),
                              child: ChoiceChip(
                                label: Text(_labels[filter]!),
                                selected: _filter == filter,
                                onSelected: (_) =>
                                    setState(() => _filter = filter),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Semantics(
                      liveRegion: true,
                      label: '${results.length} search results',
                      child: Text(
                        '${results.length} ${results.length == 1 ? 'destination' : 'destinations'}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (results.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.travel_explore,
                          color: AppColors.muted,
                          size: 42,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No celestial body matches “$_query”.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          key: const Key('clear-empty-search'),
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Clear search'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
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
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final body = results[index];
                    return BodyCard(
                      key: ValueKey(body.id),
                      body: body,
                      heroTag: 'explore-${body.id}',
                      onTap: () => _open(body),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
