import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:smartvax/data/repositories/account_repository.dart';
import 'package:smartvax/data/repositories/auth_repository.dart';
import 'package:smartvax/features/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartvax/app/root.dart';
import 'package:smartvax/core/widgets/glass.dart';
import 'package:smartvax/state/smartvax_controller.dart';

void main() {
  testWidgets(
    'unconfigured authentication blocks sign-in; model fixture preserves navigation',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = SmartVaxController.fixture(
        clock: () => DateTime(2026, 10, 11),
      );
      await tester.pumpWidget(
        SmartVaxRoot(controller: controller, showSplash: false),
      );
      expect(find.byType(BrandMark), findsOneWidget);
      expect(find.text('Enter mobile number'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(
        find.text('Firebase authentication is unavailable.'),
        findsOneWidget,
      );
      expect(controller.isLoggedIn, isFalse);
      controller.signInFixture('9876543210');
      await tester.pumpAndSettle();
      expect(find.text('Hello, Priya!'), findsOneWidget);
      expect(find.text('Schedule'), findsWidgets);
      expect(controller.isLoggedIn, isTrue);

      await tester.tap(find.text('Diya'));
      await tester.pumpAndSettle();
      expect(controller.selectedChildId, 'child_diya');
      expect(find.text('Diya Sharma'), findsWidgets);

      await tester.tap(find.text('Schedule').last);
      await tester.pumpAndSettle();
      expect(find.text('Vaccination schedule'), findsOneWidget);
      await tester.tap(find.text('Records').last);
      await tester.pumpAndSettle();
      expect(find.text('Vaccination records'), findsOneWidget);
      expect(find.text('Diya Sharma'), findsWidgets);
      await tester.tap(find.text('Alerts').last);
      await tester.pumpAndSettle();
      expect(find.text('Alerts & tips'), findsOneWidget);
      await tester.tap(find.text('Profile').last);
      await tester.pumpAndSettle();
      expect(find.text('Family profile'), findsOneWidget);
      controller.dispose();
    },
  );
  testWidgets('new authenticated household has empty children and safe forms', (
    tester,
  ) async {
    final auth = AuthRepository(
      MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'new-user', phoneNumber: '+919123456789'),
      ),
    );
    final controller = SmartVaxController(
      authRepository: auth,
      accountRepository: AccountRepository(FakeFirebaseFirestore()),
    );
    addTearDown(controller.dispose);
    addTearDown(auth.dispose);
    await tester.pumpWidget(
      SmartVaxRoot(controller: controller, showSplash: false),
    );
    for (var i = 0; i < 30 && !controller.isLoggedIn; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    await tester.pumpAndSettle();
    expect(find.text('No child selected'), findsOneWidget);
    expect(controller.children, isEmpty);
    expect(find.textContaining('Sharma'), findsNothing);
    await tester.tap(find.text('Add child'));
    await tester.pumpAndSettle();
    final address = tester.widget<TextFormField>(
      find.widgetWithText(TextFormField, 'Family address'),
    );
    expect(address.controller?.text, '');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(
      MaterialApp(home: AppointmentFormPage(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Visit details unavailable'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
