import 'package:flutter_test/flutter_test.dart';
import 'package:solar_system_explorer/core/comparison_engine.dart';
import 'package:solar_system_explorer/data/celestial_catalog.dart';

void main() {
  group('ComparisonEngine', () {
    test('Earth to Moon diameter ratio uses physical diameters', () {
      final ratio = ComparisonEngine.diameterRatio(
        CelestialCatalog.byId('earth'),
        CelestialCatalog.byId('moon'),
      );

      expect(ratio, closeTo(3.671, 0.002));
    });

    test('Betelgeuse representative diameter is 1000 Suns', () {
      final ratio = ComparisonEngine.diameterRatio(
        CelestialCatalog.byId('betelgeuse'),
        CelestialCatalog.byId('sun'),
      );

      expect(ratio, 1000);
    });

    test('Jupiter to Earth ratio matches equatorial diameter data', () {
      final ratio = ComparisonEngine.diameterRatio(
        CelestialCatalog.byId('jupiter'),
        CelestialCatalog.byId('earth'),
      );

      expect(ratio, closeTo(11.209, 0.002));
    });

    test('true-scale layout preserves the exact ratio', () {
      final betelgeuse = CelestialCatalog.byId('betelgeuse');
      final sun = CelestialCatalog.byId('sun');
      final layout = ComparisonEngine.layout(
        first: betelgeuse,
        second: sun,
        mode: ComparisonMode.trueScale,
        maximumDiameter: 300,
      );

      expect(layout.firstDiameter / layout.secondDiameter, 1000);
      expect(layout.isTrueScale, isTrue);
    });

    test('readable layout deliberately enforces a visible minimum', () {
      final layout = ComparisonEngine.layout(
        first: CelestialCatalog.byId('earth'),
        second: CelestialCatalog.byId('bennu'),
        mode: ComparisonMode.readable,
        maximumDiameter: 240,
        readableMinimumDiameter: 52,
      );

      expect(layout.secondDiameter, 52);
      expect(layout.isTrueScale, isFalse);
    });

    test('regions without a physical diameter cannot be compared', () {
      expect(
        () => ComparisonEngine.diameterRatio(
          CelestialCatalog.byId('asteroid-belt'),
          CelestialCatalog.byId('earth'),
        ),
        throwsArgumentError,
      );
    });
  });
}
