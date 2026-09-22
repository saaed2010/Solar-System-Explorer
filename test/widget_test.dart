import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_system_explorer/app/app_theme.dart';
import 'package:solar_system_explorer/app/solar_system_app.dart';
import 'package:solar_system_explorer/data/celestial_catalog.dart';
import 'package:solar_system_explorer/screens/comparison_screen.dart';

void main() {
  testWidgets('main navigation opens every core experience', (tester) async {
    await tester.pumpWidget(const SolarSystemApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Solar System'), findsOneWidget);
    expect(find.byKey(const Key('orbit-play-pause')), findsOneWidget);

    await tester.tap(find.text('Stars'));
    await tester.pump(const Duration(milliseconds: 450));
    expect(find.text('Stars explorer'), findsOneWidget);
    expect(find.text('Betelgeuse'), findsWidgets);

    await tester.tap(find.text('Compare'));
    await tester.pump(const Duration(milliseconds: 450));
    expect(find.text('Compare worlds'), findsOneWidget);
    expect(find.text('SAME PHYSICAL SCALE'), findsOneWidget);
  });

  testWidgets('catalog search opens a real Europa details screen', (
    tester,
  ) async {
    await tester.pumpWidget(const SolarSystemApp());
    await tester.tap(find.text('Explore'));
    await tester.pump(const Duration(milliseconds: 450));

    await tester.enterText(find.byKey(const Key('catalog-search')), 'Europa');
    await tester.pump();
    expect(find.byKey(const ValueKey('europa')), findsOneWidget);

    await tester.ensureVisible(find.text('Europa').last);
    await tester.tap(find.text('Europa').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('Quick facts'), findsOneWidget);
    expect(find.text('Open size comparison'), findsOneWidget);
  });

  testWidgets('details comparison opens with a valid Material surface', (
    tester,
  ) async {
    await tester.pumpWidget(const SolarSystemApp());
    await tester.tap(find.text('Explore'));
    await tester.pump(const Duration(milliseconds: 450));

    await tester.enterText(find.byKey(const Key('catalog-search')), 'Earth');
    await tester.pump();
    await tester.tap(find.text('Earth').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.drag(
      find.byType(CustomScrollView).last,
      const Offset(0, -700),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byKey(const Key('open-comparison')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 650));

    expect(find.text('Compare worlds'), findsOneWidget);
    expect(find.text('SAME PHYSICAL SCALE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('readable comparison is explicitly marked not to scale', (
    tester,
  ) async {
    await tester.pumpWidget(const SolarSystemApp());
    await tester.tap(find.text('Compare'));
    await tester.pump(const Duration(milliseconds: 450));

    await tester.tap(find.text('Readable'));
    await tester.pump(const Duration(milliseconds: 650));
    expect(find.text('NOT TO SCALE — LEGIBILITY MODE'), findsOneWidget);
  });

  testWidgets('empty search offers a working reset action', (tester) async {
    await tester.pumpWidget(const SolarSystemApp());
    await tester.tap(find.text('Explore'));
    await tester.pump(const Duration(milliseconds: 450));

    await tester.enterText(
      find.byKey(const Key('catalog-search')),
      'no-such-celestial-body',
    );
    await tester.pump();
    expect(find.textContaining('No celestial body matches'), findsOneWidget);
    expect(find.byKey(const Key('clear-empty-search')), findsOneWidget);

    await tester.tap(find.byKey(const Key('clear-empty-search')));
    await tester.pump();
    expect(find.text('28 destinations'), findsOneWidget);
  });

  testWidgets('extreme comparison keeps true scale and readable disclosure', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: ComparisonScreen(
          initialFirst: CelestialCatalog.byId('sun'),
          initialSecond: CelestialCatalog.byId('uy-scuti'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('SAME PHYSICAL SCALE'), findsOneWidget);
    expect(find.text('locator ring'), findsOneWidget);
    expect(find.textContaining('UY Scuti diameter'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Readable'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('NOT TO SCALE — LEGIBILITY MODE'), findsOneWidget);
    expect(find.text('locator ring'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion stops orbital controls and explains the state', (
    tester,
  ) async {
    tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(
      tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue,
    );

    await tester.pumpWidget(const SolarSystemApp());
    await tester.pump();

    expect(find.text('◌  REDUCED MOTION'), findsOneWidget);
    final playButton = tester.widget<IconButton>(
      find.byKey(const Key('orbit-play-pause')),
    );
    expect(playButton.onPressed, isNull);
  });

  testWidgets('core screens adapt across phone tablet and desktop widths', (
    tester,
  ) async {
    final sizes = <Size>[
      const Size(320, 740),
      const Size(360, 740),
      const Size(390, 844),
      const Size(768, 1024),
      const Size(1440, 900),
    ];
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final size in sizes) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        KeyedSubtree(
          key: ValueKey('${size.width}×${size.height}'),
          child: const SolarSystemApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Solar System'), findsOneWidget, reason: '$size System');
      expect(tester.takeException(), isNull, reason: '$size System');

      await tester.tap(find.text('Explore'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.text('Explore worlds'),
        findsOneWidget,
        reason: '$size Explore',
      );
      expect(tester.takeException(), isNull, reason: '$size Explore');

      await tester.tap(find.text('Stars'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.text('Stars explorer'),
        findsOneWidget,
        reason: '$size Stars',
      );
      expect(tester.takeException(), isNull, reason: '$size Stars');

      await tester.tap(find.text('Compare'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.text('Compare worlds'),
        findsOneWidget,
        reason: '$size Compare',
      );
      final compareException = tester.takeException();
      expect(compareException, isNull, reason: '$size Compare');
    }
  });

  testWidgets('primary experiences support enlarged text on a phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.binding.platformDispatcher.textScaleFactorTestValue = 1.25;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue,
    );

    await tester.pumpWidget(const SolarSystemApp());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Solar System'), findsOneWidget);
    expect(tester.takeException(), isNull);

    for (final destination in <String>['Explore', 'Stars', 'Compare']) {
      await tester.tap(find.text(destination));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull, reason: destination);
    }

    await tester.tap(find.text('Explore'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byKey(const Key('catalog-search')), 'Earth');
    await tester.pump();
    await tester.tap(find.text('Earth').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('Quick facts'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'Details');
  });

  testWidgets('core controls fit a compact Android-sized viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SolarSystemApp());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Solar System'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('focus-earth')));
    await tester.pump(const Duration(milliseconds: 450));
    expect(find.text('Earth'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('solar system viewport supports bounded pinch zoom and pan', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SolarSystemApp());
    await tester.pump(const Duration(milliseconds: 100));

    final viewport = tester.widget<InteractiveViewer>(
      find.byKey(const Key('solar-system-viewport')),
    );
    expect(viewport.minScale, 1);
    expect(viewport.maxScale, 3);
    expect(viewport.panEnabled, isTrue);
    expect(viewport.scaleEnabled, isTrue);
  });
}
