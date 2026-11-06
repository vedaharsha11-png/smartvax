import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Diagnostic messages never contain request payloads, credentials or user IDs.
String sanitizeAuthDiagnostic(
  String? message, {
  Iterable<String> secrets = const [],
}) {
  var result = message ?? '';
  final values = secrets.where((value) => value.isNotEmpty).toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  for (final value in values) {
    result = result.replaceAll(value, '[redacted]');
  }
  result = result.replaceAll(
    RegExp(r'https?://\S+', caseSensitive: false),
    '[redacted-url]',
  );
  result = result.replaceAll(RegExp(r'AIza[\w-]{20,}'), '[redacted-key]');
  result = result.replaceAll(
    RegExp(r'\beyJ[\w-]+\.[\w-]+\.[\w-]+\b'),
    '[redacted-token]',
  );
  result = result.replaceAll(
    RegExp(r'\bBearer\s+\S+', caseSensitive: false),
    'Bearer [redacted]',
  );
  result = result.replaceAll(
    RegExp(
      r"""(?:[\"'])?(?:[a-z]*token|sessionInfo|verificationId|smsCode|otp|credential|password|authorization|apiKey|uid|localId)(?:[\"'])?\s*[:=]\s*(?:\"[^\"]*\"|'[^']*'|[^\s,;}]+)""",
      caseSensitive: false,
    ),
    '[redacted-credential]',
  );
  result = result.replaceAll(
    RegExp(r'[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}'),
    '[redacted-email]',
  );
  result = result.replaceAll(
    RegExp(r'\+?\d[\d ()-]{8,}\d'),
    '[redacted-phone]',
  );
  result = result.replaceAll(RegExp(r'\b\d{6,}\b'), '[redacted-number]');
  result = result.replaceAll(RegExp(r'[\r\n\t\x00-\x1f]'), ' ');
  return result.length > 512 ? '${result.substring(0, 512)}…' : result;
}

String safeAuthErrorCode(String value) =>
    RegExp(r'^[a-zA-Z0-9_.-]{1,100}$').hasMatch(value)
    ? value
    : 'unrecognized-error';

class AuthDiagnostic {
  AuthDiagnostic({
    required this.event,
    required this.request,
    this.code,
    this.message,
    this.details = const {},
  }) : time = DateTime.now().toUtc();
  final DateTime time;
  final String event;
  final int request;
  final String? code;
  final String? message;
  final Map<String, Object?> details;
  Map<String, Object?> toMap() => {
    'time': time.toIso8601String(),
    'event': event,
    'request': request,
    if (code != null) 'code': code,
    if (message != null) 'message': message,
    ...details,
  };
}

typedef AuthDiagnosticSink = void Function(AuthDiagnostic event);

// Intentionally available in release logcat; the UI diagnostic is debug-only.
void logAuthDiagnostic(AuthDiagnostic event) {
  debugPrint('SmartVaxAuth ${jsonEncode(event.toMap())}');
}
