import '../models/celestial_body.dart';

enum ComparisonMode { trueScale, readable }

class ComparisonLayout {
  const ComparisonLayout({
    required this.firstDiameter,
    required this.secondDiameter,
    required this.mode,
  });

  final double firstDiameter;
  final double secondDiameter;
  final ComparisonMode mode;

  bool get isTrueScale => mode == ComparisonMode.trueScale;
}

class ComparisonEngine {
  const ComparisonEngine._();

  static double diameterRatio(CelestialBody first, CelestialBody second) {
    _validate(first);
    _validate(second);
    return first.diameterKm! / second.diameterKm!;
  }

  static ComparisonLayout layout({
    required CelestialBody first,
    required CelestialBody second,
    required ComparisonMode mode,
    required double maximumDiameter,
    double readableMinimumDiameter = 52,
  }) {
    _validate(first);
    _validate(second);
    if (maximumDiameter <= 0) {
      throw ArgumentError.value(maximumDiameter, 'maximumDiameter');
    }

    final maxKm = first.diameterKm! > second.diameterKm!
        ? first.diameterKm!
        : second.diameterKm!;
    final scale = maximumDiameter / maxKm;
    var firstPixels = first.diameterKm! * scale;
    var secondPixels = second.diameterKm! * scale;

    if (mode == ComparisonMode.readable) {
      firstPixels = firstPixels.clamp(readableMinimumDiameter, maximumDiameter);
      secondPixels = secondPixels.clamp(
        readableMinimumDiameter,
        maximumDiameter,
      );
    }

    return ComparisonLayout(
      firstDiameter: firstPixels,
      secondDiameter: secondPixels,
      mode: mode,
    );
  }

  static String ratioLabel(CelestialBody first, CelestialBody second) {
    final ratio = diameterRatio(first, second);
    if (ratio == 1) return '${first.name} and ${second.name}: equal diameter';
    final larger = ratio > 1 ? first : second;
    final smaller = ratio > 1 ? second : first;
    final magnitude = ratio > 1 ? ratio : 1 / ratio;
    final formatted = magnitude >= 100
        ? magnitude.toStringAsFixed(0)
        : magnitude >= 10
        ? magnitude.toStringAsFixed(1)
        : magnitude.toStringAsFixed(2);
    return '${larger.name} diameter ≈ $formatted × ${smaller.name}';
  }

  static void _validate(CelestialBody body) {
    if (!body.canCompare) {
      throw ArgumentError('${body.name} has no comparable physical diameter.');
    }
  }
}
