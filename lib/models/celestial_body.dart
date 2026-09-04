enum BodyType { star, planet, dwarfPlanet, moon, asteroid, comet, region }

extension BodyTypeLabel on BodyType {
  String get label => switch (this) {
    BodyType.star => 'Star',
    BodyType.planet => 'Planet',
    BodyType.dwarfPlanet => 'Dwarf planet',
    BodyType.moon => 'Moon',
    BodyType.asteroid => 'Asteroid',
    BodyType.comet => 'Comet',
    BodyType.region => 'Solar system region',
  };

  String get pluralLabel => switch (this) {
    BodyType.star => 'Stars',
    BodyType.planet => 'Planets',
    BodyType.dwarfPlanet => 'Dwarf planets',
    BodyType.moon => 'Moons',
    BodyType.asteroid => 'Asteroids',
    BodyType.comet => 'Comets',
    BodyType.region => 'Regions',
  };
}

class BodyFact {
  const BodyFact(this.label, this.value);

  final String label;
  final String value;
}

class CelestialBody {
  const CelestialBody({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.palette,
    required this.facts,
    this.diameterKm,
    this.mass,
    this.gravity,
    this.temperature,
    this.distanceFromSun,
    this.distanceFromEarth,
    this.orbitalPeriod,
    this.rotationPeriod,
    this.moonCount,
    this.atmosphere,
    this.composition,
    this.surface,
    this.discovery,
    this.parentId,
    this.sizeIsApproximate = false,
    this.sizeNote,
  });

  final String id;
  final String name;
  final BodyType type;
  final String description;
  final double? diameterKm;
  final String? mass;
  final String? gravity;
  final String? temperature;
  final String? distanceFromSun;
  final String? distanceFromEarth;
  final String? orbitalPeriod;
  final String? rotationPeriod;
  final int? moonCount;
  final String? atmosphere;
  final String? composition;
  final String? surface;
  final String? discovery;
  final String? parentId;
  final bool sizeIsApproximate;
  final String? sizeNote;
  final List<int> palette;
  final List<String> facts;

  bool get canCompare => diameterKm != null && diameterKm! > 0;
  bool get isStar => type == BodyType.star;

  List<BodyFact> get quickFacts => <BodyFact>[
    if (diameterKm case final diameter?)
      BodyFact(
        sizeIsApproximate ? 'Approx. diameter' : 'Diameter',
        _formatKilometres(diameter),
      ),
    if (mass case final value?) BodyFact('Mass', value),
    if (gravity case final value?) BodyFact('Gravity', value),
    if (temperature case final value?) BodyFact('Temperature', value),
    if (distanceFromSun case final value?) BodyFact('From the Sun', value),
    if (distanceFromEarth case final value?) BodyFact('From Earth', value),
    if (orbitalPeriod case final value?) BodyFact('Orbital period', value),
    if (rotationPeriod case final value?) BodyFact('Rotation / day', value),
    if (moonCount case final value?) BodyFact('Known moons', '$value'),
    if (atmosphere case final value?) BodyFact('Atmosphere', value),
    if (composition case final value?) BodyFact('Composition', value),
    if (surface case final value?) BodyFact('Surface', value),
    if (discovery case final value?) BodyFact('Discovery', value),
  ];

  static String _formatKilometres(double value) {
    final String digits = value >= 100
        ? value.toStringAsFixed(0)
        : value >= 10
        ? value.toStringAsFixed(1)
        : value.toStringAsFixed(3);
    final parts = digits.split('.');
    final whole = parts.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '${parts.length == 2 ? '$whole.${parts.last}' : whole} km';
  }
}
