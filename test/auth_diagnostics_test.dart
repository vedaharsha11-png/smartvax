import 'package:flutter/material.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:smartvax/app/root.dart';
import 'package:smartvax/data/repositories/account_repository.dart';
import 'package:smartvax/state/smartvax_controller.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartvax/core/firebase/auth_diagnostics.dart';
import 'package:smartvax/data/repositories/auth_repository.dart';
import 'phone_auth_test.dart' show ControlledPhoneAuth;

void main() {
  testWidgets(
    'debug login exposes sanitized failure details without OTP or phone',
    (tester) async {
      final firebase = ControlledPhoneAuth();
      final repo = AuthRepository(firebase, diagnosticSink: (_) {});
      final controller = SmartVaxController(
        authRepository: repo,
        accountRepository: AccountRepository(FakeFirebaseFirestore()),
      );
      addTearDown(controller.dispose);
      addTearDown(repo.dispose);
      await tester.pumpWidget(
        SmartVaxRoot(controller: controller, showSplash: false),
      );
      await tester.enterText(find.byType(TextField).first, '7893427676');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      firebase.failed!(
        FirebaseAuthException(
          code: 'operation-not-allowed',
          message: 'SMS_REGION_POLICY phone +917893427676 OTP 654321',
        ),
      );
      await tester.pumpAndSettle();
      final diagnostic = tester.widget<Text>(
        find.byKey(const ValueKey('phone-auth-diagnostic')),
      );
      expect(diagnostic.data, contains('operation-not-allowed'));
      expect(diagnostic.data, contains('SMS_REGION_POLICY'));
      expect(diagnostic.data, isNot(contains('7893427676')));
      expect(diagnostic.data, isNot(contains('654321')));
      expect(tester.takeException(), isNull);
    },
  );
  test(
    'sanitizer preserves backend cause and removes credentials and contact data',
    () {
      const key = 'AIzaExampleSecretKey12345678901234567890';
      const message =
          'An internal error [ BILLING_NOT_ENABLED ] phone +91 78934 27676 '
          'OTP 654321 apiKey=$key verificationId=private-id token=private-token '
          'email parent@example.com https://example.com?token=secret '
          'eyJabc.eyJdef.signature\nBearer secret-bearer uid-private-known';
      final safe = sanitizeAuthDiagnostic(
        message,
        secrets: [key, 'uid-private-known'],
      );
      expect(safe, contains('BILLING_NOT_ENABLED'));
      for (final secret in [
        key,
        '78934',
        '27676',
        '654321',
        'private-id',
        'private-token',
        'parent@example.com',
        'example.com',
        'secret-bearer',
        'eyJabc',
        'uid-private-known',
      ]) {
        expect(safe, isNot(contains(secret)));
      }
      expect(safe, isNot(contains('\n')));
      expect(
        sanitizeAuthDiagnostic(
          '{"idToken":"opaque-secret","localId":"private-uid"}',
        ),
        isNot(contains('opaque-secret')),
      );
      expect(
        sanitizeAuthDiagnostic('{"localId":"private-uid"}'),
        isNot(contains('private-uid')),
      );
      expect(sanitizeAuthDiagnostic('x' * 900).length, 513);
    },
  );
  test(
    'diagnostics capture callback code/message and never log phone or token values',
    () async {
      final firebase = ControlledPhoneAuth();
      final events = <AuthDiagnostic>[];
      final repo = AuthRepository(firebase, diagnosticSink: events.add);
      addTearDown(repo.dispose);
      await repo.send('7893427676');
      firebase.sent!('secret-verification-id', 123456);
      firebase.failed!(
        FirebaseAuthException(
          code: 'operation-not-allowed',
          message:
              'SMS_REGION_POLICY blocked +917893427676 sessionInfo=private-token',
        ),
      );
      expect(repo.diagnosticErrorCode, 'operation-not-allowed');
      expect(repo.diagnosticErrorMessage, contains('SMS_REGION_POLICY'));
      expect(repo.error, contains('SMS region policy'));
      final output = jsonEncode(events.map((e) => e.toMap()).toList());
      for (final secret in [
        '7893427676',
        'secret-verification-id',
        '123456',
        'private-token',
      ]) {
        expect(output, isNot(contains(secret)));
      }
      expect(
        events.map((e) => e.event),
        containsAll([
          'verifyPhoneNumber.invoke',
          'codeSent',
          'verificationFailed',
        ]),
      );
      expect(events.first.details['e164Valid'], isTrue);
      repo.changeNumber();
      expect(repo.diagnosticErrorCode, isNull);
    },
  );
  test('initiation exceptions preserve platform error codes safely', () async {
    final firebase = ThrowingPhoneAuth();
    final events = <AuthDiagnostic>[];
    final repo = AuthRepository(firebase, diagnosticSink: events.add);
    addTearDown(repo.dispose);
    await repo.send('7893427676');
    expect(repo.busy, isFalse);
    expect(repo.diagnosticErrorCode, 'network-error');
    expect(events.last.event, 'verifyPhoneNumber.exception');
    expect(events.last.message, isNot(contains('654321')));
  });
  test(
    'credential errors preserve SDK code and sanitize submitted code and verification ID',
    () async {
      final firebase = ControlledPhoneAuth();
      final events = <AuthDiagnostic>[];
      final repo = AuthRepository(firebase, diagnosticSink: events.add);
      addTearDown(repo.dispose);
      await repo.send('+917893427676');
      firebase.sent!('private-verification', null);
      firebase.credentialFailure = FirebaseAuthException(
        code: 'invalid-verification-code',
        message: 'Code 654321 failed verificationId=private-verification',
      );
      await repo.verify('654321');
      expect(repo.diagnosticErrorCode, 'invalid-verification-code');
      expect(events.last.event, 'signInCredential.failure');
      expect(
        jsonEncode(events.map((e) => e.toMap()).toList()),
        isNot(contains('654321')),
      );
      firebase.credentialFailure = null;
      await repo.verify('654321');
      expect(repo.diagnosticErrorCode, isNull);
      expect(events.last.event, 'signInCredential.success');
      expect(events.last.details['uidPresent'], isTrue);
    },
  );
  test(
    'timeout exposes manual OTP state and double country codes are rejected',
    () async {
      final firebase = ControlledPhoneAuth();
      final events = <AuthDiagnostic>[];
      final repo = AuthRepository(firebase, diagnosticSink: events.add);
      addTearDown(repo.dispose);
      await repo.send('7893427676');
      firebase.timedOut!('manual-only');
      expect(repo.codeSent, isTrue);
      expect(events.last.event, 'codeAutoRetrievalTimeout');
      expect(
        () => normalizeIndianPhone('+91+917893427676'),
        throwsFormatException,
      );
      expect(() => normalizeIndianPhone('917893427676'), throwsFormatException);
    },
  );
  test('a failing diagnostic sink cannot interrupt verification', () async {
    final firebase = ControlledPhoneAuth();
    final repo = AuthRepository(
      firebase,
      diagnosticSink: (_) => throw StateError('sink'),
    );
    addTearDown(repo.dispose);
    await repo.send('7893427676');
    firebase.sent!('verification', null);
    await repo.verify('654321');
    expect(firebase.currentUser?.uid, 'verified');
  });
}

class ThrowingPhoneAuth extends ControlledPhoneAuth {
  @override
  Future<void> verifyPhoneNumber({
    String? phoneNumber,
    PhoneMultiFactorInfo? multiFactorInfo,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    String? autoRetrievedSmsCodeForTesting,
    Duration timeout = const Duration(seconds: 30),
    int? forceResendingToken,
    Object? multiFactorSession,
  }) async {
    throw PlatformException(
      code: 'network-error',
      message: 'Network failure smsCode=654321',
    );
  }
}
