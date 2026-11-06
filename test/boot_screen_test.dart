import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartvax/app/root.dart';
import 'package:smartvax/state/smartvax_controller.dart';

void main() {
  for (final loggedIn in [false, true]) {
    testWidgets('four-second boot hands off with loggedIn=$loggedIn', (
      tester,
    ) async {
      final controller = SmartVaxController.fixture();
      addTearDown(controller.dispose);
      if (loggedIn) controller.signInFixture('9876543210');
      await tester.pumpWidget(SmartVaxRoot(controller: controller));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 3599));
      expect(find.byType(SmartVaxSplash), findsOneWidget);
      expect(
        find.text(loggedIn ? 'Hello, Priya!' : 'Enter mobile number'),
        findsNothing,
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(SmartVaxSplash), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.byType(SmartVaxSplash), findsNothing);
      expect(
        find.text(loggedIn ? 'Hello, Priya!' : 'Enter mobile number'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('reduced motion keeps four-second timing and disposes safely', (
    tester,
  ) async {
    var finished = false;
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: SmartVaxSplash(onCompleted: () => finished = true),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(finished, isFalse);
    await tester.pump(const Duration(seconds: 2));
    expect(finished, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving during boot cancels the animation callbacks', (
    tester,
  ) async {
    var callbacks = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: SmartVaxSplash(
          onReveal: () => callbacks++,
          onCompleted: () => callbacks++,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
    expect(callbacks, 0);
    expect(tester.takeException(), isNull);
  });
}
