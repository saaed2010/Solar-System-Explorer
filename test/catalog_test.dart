import 'package:flutter_test/flutter_test.dart';
import 'package:solar_system_explorer/data/celestial_catalog.dart';
import 'package:solar_system_explorer/models/celestial_body.dart';

void main() {
  test('catalog contains unique identifiers', () {
    final ids = CelestialCatalog.bodies.map((body) => body.id).toSet();
    expect(ids.length, CelestialCatalog.bodies.length);
  });

  test('catalog includes all requested content groups', () {
    expect(CelestialCatalog.planets.length, 8);
    expect(CelestialCatalog.dwarfPlanets.length, greaterThanOrEqualTo(5));
    expect(CelestialCatalog.moons.length, greaterThanOrEqualTo(10));
    expect(CelestialCatalog.stars.length, greaterThanOrEqualTo(12));
    expect(CelestialCatalog.ofType(BodyType.asteroid), isNotEmpty);
    expect(CelestialCatalog.ofType(BodyType.comet), isNotEmpty);
    expect(CelestialCatalog.ofType(BodyType.region), isNotEmpty);
  });

  test('every comparable body has a positive physical diameter', () {
    for (final body in CelestialCatalog.comparableBodies) {
      expect(body.diameterKm, greaterThan(0), reason: body.name);
    }
  });

  test('requested major stars are present', () {
    const required = <String>{
      'Sun',
      'Proxima Centauri',
      'Sirius A',
      'Vega',
      'Polaris',
      'Arcturus',
      'Aldebaran',
      'Rigel',
      'Betelgeuse',
      'Antares',
      'Deneb',
      'UY Scuti',
    };
    expect(
      CelestialCatalog.stars.map((star) => star.name).toSet(),
      containsAll(required),
    );
  });
}
