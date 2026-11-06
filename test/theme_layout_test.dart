import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartvax/app/root.dart';
import 'package:smartvax/core/theme/app_theme.dart';
import 'package:smartvax/features/app_pages.dart';
import 'package:smartvax/state/smartvax_controller.dart';

const _capture = bool.fromEnvironment('CAPTURE_UI');
final _previewKey = GlobalKey();

Future<void> _preview(WidgetTester tester, String name) async {
  if (!_capture) return;
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
  });
  await tester.pump();
  await tester.runAsync(() async {
    final boundary =
        _previewKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('build/ui_previews')
      ..createSync(recursive: true);
    await File(
      '${directory.path}/$name.png',
    ).writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

void _viewport(WidgetTester tester, double width, double scale) {
  tester.view.physicalSize = Size(width, 880);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader('Nunito')
      ..addFont(rootBundle.load('assets/fonts/Nunito.ttf'));
    await loader.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });

  for (final size in <(double, double)>[
    (320, 1),
    (360, 1),
    (393, 1),
    (430, 1),
    (320, 1.5),
    (393, 2),
  ]) {
    testWidgets('five tabs fit ${size.$1}dp at ${size.$2} text scale', (
      tester,
    ) async {
      _viewport(tester, size.$1, size.$2);
      final controller = SmartVaxController.fixture(
        clock: () => DateTime(2026, 10, 11, 12),
      );
      addTearDown(controller.dispose);
      controller.signInFixture('9876543210');
      await tester.pumpWidget(
        RepaintBoundary(
          key: _previewKey,
          child: SmartVaxRoot(controller: controller, showSplash: false),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (size == (393.0, 1.0)) await _preview(tester, 'home');
      for (final tab in ['Schedule', 'Records', 'Alerts', 'Profile']) {
        await tester.tap(find.text(tab).last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$tab first view');
        final scroller = find.byType(SingleChildScrollView).hitTestable().first;
        await tester.drag(scroller, const Offset(0, -550));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$tab scrolled view');
      }
      expect(controller.selectedChildId, 'child_aarav');
    });
  }

  for (final size in <(double, double)>[
    (320, 1),
    (393, 1),
    (320, 1.5),
    (393, 2),
  ]) {
    testWidgets(
      'profile and visit layouts fit ${size.$1}dp at ${size.$2} text scale',
      (tester) async {
        _viewport(tester, size.$1, size.$2);
        final controller = SmartVaxController.fixture(
          clock: () => DateTime(2026, 10, 11, 12),
        );
        addTearDown(controller.dispose);
        controller.signInFixture('9876543210');
        for (final entry in <(String, Widget)>[
          (
            'child_profile',
            ChildProfilePage(controller: controller, childId: 'child_aarav'),
          ),
          ('family_visits', AppointmentsPage(controller: controller)),
        ]) {
          await tester.pumpWidget(
            RepaintBoundary(
              key: _previewKey,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: buildTheme(),
                home: entry.$2,
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: entry.$1);
          if (size == (393.0, 1.0)) await _preview(tester, entry.$1);
          final scroller = find.byType(SingleChildScrollView).first;
          for (var i = 0; i < 3; i++) {
            await tester.drag(scroller, const Offset(0, -500));
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '${entry.$1} lower content',
            );
          }
          await tester.pumpWidget(const SizedBox.shrink());
        }
      },
    );
  }

  testWidgets('visit filter and attended action update the displayed visits', (
    tester,
  ) async {
    _viewport(tester, 393, 1);
    final controller = SmartVaxController.fixture(
      clock: () => DateTime(2026, 10, 11, 12),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: AppointmentsPage(controller: controller),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Previous child health visit'), findsNothing);
    final completedBefore = controller.records
        .where((r) => r.administeredAt != null)
        .length;
    await tester.tap(find.byTooltip('Appointment actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark attended'));
    await tester.pumpAndSettle();
    expect(find.text('Upcoming visits (2)'), findsOneWidget);
    expect(
      controller.records.where((r) => r.administeredAt != null).length,
      completedBefore,
    );
    await tester.tap(find.text('Previous visits (2)'));
    await tester.pumpAndSettle();
    expect(find.text('Previous child health visit'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('branded splash finishes and login fits with the keyboard', (
    tester,
  ) async {
    _viewport(tester, 320, 1.5);
    final controller = SmartVaxController.fixture(
      clock: () => DateTime(2026, 10, 11),
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      RepaintBoundary(
        key: _previewKey,
        child: SmartVaxRoot(controller: controller),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1800));
    expect(find.byType(SmartVaxSplash), findsOneWidget);
    await _preview(tester, 'splash');
    await tester.pump(const Duration(milliseconds: 2200));
    await tester.pumpAndSettle();
    expect(find.text('Enter mobile number'), findsOneWidget);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(
      find.text('Firebase authentication is unavailable.'),
      findsOneWidget,
    );
    expect(controller.isLoggedIn, isFalse);
    expect(tester.takeException(), isNull);
  });
}
