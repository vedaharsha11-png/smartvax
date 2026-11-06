import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../core/firebase/auth_diagnostics.dart';

String normalizeIndianPhone(String input) {
  var value = input.trim().replaceAll(RegExp(r'[\s()-]'), '');
  if (value.startsWith('+91')) value = value.substring(3);
  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
    throw const FormatException('Enter a valid 10-digit mobile number.');
  }
  return '+91$value';
}

String authMessage(Object error) {
  if (error is FormatException) return error.message.toString();
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-verification-code' => 'Invalid verification code.',
      'session-expired' ||
      'invalid-verification-id' => 'Verification expired. Request a new code.',
      'network-request-failed' => 'Network connection unavailable. Try again.',
      'too-many-requests' ||
      'quota-exceeded' => 'Too many verification attempts. Try again later.',
      'invalid-phone-number' => 'Enter a valid mobile number.',
      'operation-not-allowed' =>
        'Phone verification is not permitted. Check the provider and SMS region policy.',
      'billing-not-enabled' =>
        'Phone verification is unavailable. Check Firebase billing configuration.',
      'missing-activity' || 'missing-activity-for-recaptcha' =>
        'Unable to open application verification. Reopen SmartVax and try again.',
      'invalid-api-key' || 'api-key-not-valid' =>
        'Application verification configuration is invalid.',
      'web-context-cancelled' =>
        'Application verification was cancelled. Try again.',
      'web-network-request-failed' || 'web-internal-error' =>
        'Unable to complete browser verification. Check your connection and try again.',
      'app-not-authorized' ||
      'invalid-app-credential' ||
      'missing-client-identifier' ||
      'captcha-check-failed' =>
        'Unable to verify this application. Check Android Firebase setup.',
      _ => 'Unable to verify mobile number. Try again.',
    };
  }
  return 'Unable to verify mobile number. Try again.';
}

class AuthRepository extends ChangeNotifier {
  AuthRepository(this.auth, {AuthDiagnosticSink? diagnosticSink})
    : _diagnosticSink = diagnosticSink ?? logAuthDiagnostic {
    // Runtime options can be unavailable in lightweight unit-test FirebaseApps.
    try {
      _record(
        'repository.initialized',
        details: {
          'appName': auth.app.name,
          'projectId': auth.app.options.projectId,
          'appId': auth.app.options.appId,
          'apiKeyPresent': auth.app.options.apiKey.isNotEmpty,
        },
      );
    } catch (_) {
      // No raw Firebase options or credentials are ever logged.
    }
  }
  final AuthDiagnosticSink _diagnosticSink;
  String? diagnosticErrorCode;
  String? diagnosticErrorMessage;
  bool _signingIn = false;

  List<String> get _secrets {
    final values = <String>[
      ?phone,
      if (phone?.startsWith('+91') ?? false) phone!.substring(3),
      ?verificationId,
    ];
    final uid = auth.currentUser?.uid;
    if (uid != null) values.add(uid);
    try {
      values.add(auth.app.options.apiKey);
    } catch (_) {
      /* Unit-test apps may not provide options. */
    }
    return values;
  }

  void _record(
    String event, {
    Object? failure,
    Iterable<String> secrets = const [],
    Map<String, Object?> details = const {},
  }) {
    String? code;
    String? message;
    if (failure is FirebaseException) {
      code = safeAuthErrorCode(failure.code);
      message = failure.message;
    } else if (failure is PlatformException) {
      code = safeAuthErrorCode(failure.code);
      message = failure.message;
    } else if (failure is FormatException) {
      code = 'invalid-phone-input';
      message = failure.message.toString();
    } else if (failure != null) {
      code = 'unexpected-error';
      message = 'Verification failed (${failure.runtimeType}).';
    }
    final safeMessage = message == null
        ? null
        : sanitizeAuthDiagnostic(message, secrets: [..._secrets, ...secrets]);
    if (failure != null) {
      diagnosticErrorCode = code;
      diagnosticErrorMessage = safeMessage;
    }
    try {
      _diagnosticSink(
        AuthDiagnostic(
          event: event,
          request: _generation,
          code: code,
          message: safeMessage,
          details: details,
        ),
      );
    } catch (_) {
      /* Diagnostics must not interrupt authentication. */
    }
  }

  void _clearDiagnosticError() {
    diagnosticErrorCode = null;
    diagnosticErrorMessage = null;
  }

  Future<void> _signIn(
    PhoneAuthCredential credential,
    int generation,
    String source, {
    Iterable<String> secrets = const [],
  }) async {
    if (_signingIn || generation != _generation) {
      _record('signInCredential.ignored', details: {'source': source});
      return;
    }
    _signingIn = true;
    busy = true;
    _requestTimer?.cancel();
    _record('signInCredential.start', details: {'source': source});
    notifyListeners();
    try {
      final result = await auth.signInWithCredential(credential);
      if (generation != _generation) return;
      _clearDiagnosticError();
      error = null;
      _record(
        'signInCredential.success',
        details: {
          'source': source,
          'uidPresent': result.user?.uid.isNotEmpty ?? false,
          'verifiedPhonePresent': result.user?.phoneNumber != null,
        },
      );
    } catch (e) {
      if (generation != _generation) return;
      _record(
        'signInCredential.failure',
        failure: e,
        secrets: secrets,
        details: {'source': source},
      );
      error = authMessage(e);
    } finally {
      _signingIn = false;
      if (generation == _generation) {
        busy = false;
        notifyListeners();
      }
    }
  }

  final FirebaseAuth auth;
  Stream<User?> get changes => auth.authStateChanges();
  String? verificationId;
  int? resendToken;
  String? error;
  String? phone;
  bool busy = false;
  bool codeSent = false;
  int _generation = 0;
  Timer? _requestTimer;
  DateTime? resendAfter;
  bool get canResend =>
      !busy && (resendAfter == null || !DateTime.now().isBefore(resendAfter!));

  Future<void> send(String input, {bool resend = false}) async {
    if (busy || (resend && !canResend)) {
      _record(
        'verifyPhoneNumber.ignored',
        details: {'busy': busy, 'resend': resend},
      );
      return;
    }
    final generation = ++_generation;
    try {
      phone = normalizeIndianPhone(input);
      busy = true;
      error = null;
      _clearDiagnosticError();
      _record(
        'verifyPhoneNumber.invoke',
        details: {
          'countryCode': '+91',
          'e164Valid': RegExp(r'^\+91[6-9]\d{9}$').hasMatch(phone!),
          'resend': resend,
          'resendTokenPresent': resend && resendToken != null,
          'timeoutSeconds': 60,
        },
      );
      notifyListeners();
      _requestTimer?.cancel();
      _requestTimer = Timer(const Duration(seconds: 65), () {
        if (generation != _generation) return;
        busy = false;
        diagnosticErrorCode = 'request-timeout';
        _record('verifyPhoneNumber.requestTimeout');
        error = 'Verification timed out. Request a new code.';
        notifyListeners();
      });
      await auth.verifyPhoneNumber(
        phoneNumber: phone!,
        timeout: const Duration(seconds: 60),
        forceResendingToken: resend ? resendToken : null,
        verificationCompleted: (credential) async {
          _record(
            'verificationCompleted',
            details: {'activeRequest': generation == _generation},
          );
          if (generation != _generation) return;
          await _signIn(
            credential,
            generation,
            'automatic',
            secrets: [
              if (credential.smsCode != null) credential.smsCode!,
              if (credential.verificationId != null) credential.verificationId!,
            ],
          );
        },
        verificationFailed: (failure) {
          if (generation != _generation) return;
          _record('verificationFailed', failure: failure);
          _requestTimer?.cancel();
          busy = false;
          error = authMessage(failure);
          notifyListeners();
        },
        codeSent: (id, token) {
          if (generation != _generation) return;
          _requestTimer?.cancel();
          verificationId = id;
          _clearDiagnosticError();
          error = null;
          _record(
            'codeSent',
            details: {
              'verificationIdPresent': id.isNotEmpty,
              'resendTokenPresent': token != null,
            },
          );
          resendToken = token;
          resendAfter = DateTime.now().add(const Duration(seconds: 60));
          codeSent = true;
          busy = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (id) {
          if (generation != _generation) return;
          _requestTimer?.cancel();
          verificationId = id;
          codeSent = id.isNotEmpty;
          _record(
            'codeAutoRetrievalTimeout',
            details: {'manualVerificationAvailable': id.isNotEmpty},
          );
          busy = false;
          error =
              'Automatic verification timed out. Enter your code or resend.';
          notifyListeners();
        },
      );
    } catch (e) {
      if (generation != _generation) return;
      _record('verifyPhoneNumber.exception', failure: e);
      _requestTimer?.cancel();
      busy = false;
      error = authMessage(e);
      notifyListeners();
    }
  }

  Future<void> verify(String code) async {
    if (busy) return;
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      error = 'Enter all 6 digits to continue.';
      notifyListeners();
      return;
    }
    if (verificationId == null) {
      error = 'Request a verification code first.';
      notifyListeners();
      return;
    }
    final generation = _generation;
    error = null;
    _clearDiagnosticError();
    await _signIn(
      PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: code,
      ),
      generation,
      'manual',
      secrets: [code],
    );
  }

  void changeNumber() {
    _generation++;
    _record('changeNumber');
    _clearDiagnosticError();
    _requestTimer?.cancel();
    verificationId = null;
    resendToken = null;
    resendAfter = null;
    phone = null;
    busy = false;
    codeSent = false;
    error = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    changeNumber();
    await auth.signOut();
  }

  @override
  void dispose() {
    _generation++;
    _requestTimer?.cancel();
    super.dispose();
  }
}
