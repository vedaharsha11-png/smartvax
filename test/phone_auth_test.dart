import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartvax/data/repositories/auth_repository.dart';

class ControlledPhoneAuth extends MockFirebaseAuth {
  ControlledPhoneAuth()
    : super(
        mockUser: MockUser(uid: 'verified', phoneNumber: '+917893427676'),
      );
  int requests = 0;
  String? requestedPhone;
  int? requestedToken;
  PhoneCodeSent? sent;
  PhoneVerificationFailed? failed;
  PhoneVerificationCompleted? completed;
  PhoneCodeAutoRetrievalTimeout? timedOut;
  FirebaseAuthException? credentialFailure;
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
    requests++;
    requestedPhone = phoneNumber;
    requestedToken = forceResendingToken;
    sent = codeSent;
    failed = verificationFailed;
    completed = verificationCompleted;
    timedOut = codeAutoRetrievalTimeout;
  }

  @override
  Future<UserCredential> signInWithCredential(AuthCredential? credential) {
    if (credentialFailure != null) throw credentialFailure!;
    return super.signInWithCredential(credential);
  }
}

void main() {
  test(
    'OTP requests normalize number, prevent duplicates, and use resend token',
    () async {
      final firebase = ControlledPhoneAuth();
      final repo = AuthRepository(firebase);
      addTearDown(repo.dispose);
      await repo.send('7893427676');
      await repo.send('7893427676');
      expect(firebase.requests, 1);
      expect(firebase.requestedPhone, '+917893427676');
      expect(repo.busy, isTrue);
      firebase.sent!('verification', 42);
      expect(repo.codeSent, isTrue);
      expect(repo.busy, isFalse);
      await repo.send('7893427676', resend: true);
      expect(firebase.requests, 1);
      repo.resendAfter = DateTime(2000);
      await repo.send('7893427676', resend: true);
      expect(firebase.requestedToken, 42);
      repo.changeNumber();
      expect(repo.verificationId, isNull);
      expect(repo.resendToken, isNull);
      firebase.sent!('stale', 99);
      expect(repo.verificationId, isNull);
    },
  );
  test('wrong and expired codes fail; Firebase credential succeeds', () async {
    final firebase = ControlledPhoneAuth();
    final repo = AuthRepository(firebase);
    addTearDown(repo.dispose);
    await repo.verify('123');
    expect(repo.error, 'Enter all 6 digits to continue.');
    await repo.verify('123456');
    expect(repo.error, 'Request a verification code first.');
    await repo.send('7893427676');
    firebase.sent!('verification', null);
    firebase.credentialFailure = FirebaseAuthException(
      code: 'invalid-verification-code',
    );
    await repo.verify('654321');
    expect(repo.error, 'Invalid verification code.');
    expect(firebase.currentUser, isNull);
    firebase.credentialFailure = FirebaseAuthException(code: 'session-expired');
    await repo.verify('654321');
    expect(repo.error, contains('expired'));
    firebase.credentialFailure = null;
    await repo.verify('654321');
    expect(firebase.currentUser?.uid, 'verified');
    expect(repo.busy, isFalse);
  });
  test('automatic verification uses Firebase credentials', () async {
    final firebase = ControlledPhoneAuth();
    final repo = AuthRepository(firebase);
    addTearDown(repo.dispose);
    await repo.send('7893427676');
    firebase.completed!(
      PhoneAuthProvider.credential(verificationId: 'auto', smsCode: '654321'),
    );
    await Future<void>.delayed(Duration.zero);
    expect(firebase.currentUser?.uid, 'verified');
    expect(repo.busy, isFalse);
  });
  for (final code in [
    'network-request-failed',
    'too-many-requests',
    'captcha-check-failed',
    'invalid-phone-number',
  ]) {
    test(
      'verification failure $code clears loading and allows retry',
      () async {
        final firebase = ControlledPhoneAuth();
        final repo = AuthRepository(firebase);
        addTearDown(repo.dispose);
        await repo.send('7893427676');
        firebase.failed!(FirebaseAuthException(code: code));
        expect(repo.busy, isFalse);
        expect(repo.error, isNotNull);
        await repo.send('7893427676');
        expect(firebase.requests, 2);
      },
    );
  }
  test(
    'auto-retrieval timeout retains manual verification identifier',
    () async {
      final firebase = ControlledPhoneAuth();
      final repo = AuthRepository(firebase);
      addTearDown(repo.dispose);
      await repo.send('7893427676');
      firebase.timedOut!('manual');
      expect(repo.verificationId, 'manual');
      expect(repo.busy, isFalse);
      expect(repo.error, contains('timed out'));
    },
  );
}
