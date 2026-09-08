import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_system_explorer/app/solar_system_app.dart';

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
}
