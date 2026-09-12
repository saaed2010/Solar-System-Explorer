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

    test('Pluto to Earth ratio remains finite and physical', () {
      final ratio = ComparisonEngine.diameterRatio(
        CelestialCatalog.byId('pluto'),
        CelestialCatalog.byId('earth'),
      );

      expect(ratio, closeTo(0.1864, 0.0002));
      expect(ratio.isFinite, isTrue);
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

    test('true scale preserves the extreme UY Scuti to Sun ratio', () {
      final uyScuti = CelestialCatalog.byId('uy-scuti');
      final sun = CelestialCatalog.byId('sun');
      final layout = ComparisonEngine.layout(
        first: sun,
        second: uyScuti,
        mode: ComparisonMode.trueScale,
        maximumDiameter: 280,
      );

      expect(
        layout.secondDiameter / layout.firstDiameter,
        closeTo(ComparisonEngine.diameterRatio(uyScuti, sun), 0.000001),
      );
      expect(layout.firstDiameter, lessThan(1));
    });

    test('ratio label names the larger body for extreme reverse ratios', () {
      final label = ComparisonEngine.ratioLabel(
        CelestialCatalog.byId('sun'),
        CelestialCatalog.byId('uy-scuti'),
      );

      expect(label, startsWith('UY Scuti diameter'));
      expect(label, isNot(contains('0.00')));
      expect(label, contains('Sun'));
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
