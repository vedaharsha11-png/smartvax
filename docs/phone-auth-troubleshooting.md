# SmartVax persistent Phone Authentication investigation

Date: 12 October 2026 (India). This report distinguishes verified source/configuration defects from the installed handset's unobserved exception.

## Current result

**Exact exception code from the failing handset: not captured. Actual root cause of that handset's verification failure: not yet established.** The screenshots show only the application's generic message. No Android device is connected, and the owner confirmed that no device connection is available. A successful build is not evidence of successful authentication.

The verified application defect was loss of diagnostic evidence: `verificationFailed` and initiation/sign-in catch handlers converted SDK exceptions into generic wording and discarded their code/message. That defect is corrected. An additional source defect was that an automatic-retrieval timeout retained a verification ID but did not expose manual OTP entry; that state transition is corrected. Neither is claimed as proof of the cause of the initial verification failure.

## Diagnostics and focused changes

- `lib/core/firebase/auth_diagnostics.dart`: structured events, sanitization and a testable logging sink. Logs redact known verification IDs, phone numbers, submitted codes, API keys, JWTs, bearer credentials, credential assignments/JSON fields, current UIDs, emails and URLs. Arbitrary exception objects, request payloads and tokens are not logged.
- `lib/data/repositories/auth_repository.dart`: logs invocation, each of the four Firebase verification callbacks, initiation exceptions and manual/automatic credential sign-in. Captures `FirebaseAuthException.code`/sanitized message and `PlatformException.code`/sanitized message. Logs safe format facts instead of the full phone, OTP, resend token or verification ID. Handles provider/region, browser, billing and configuration errors specifically. Serializes competing automatic/manual sign-in attempts. Retains genuine Firebase credential authentication and session observation.
- `lib/features/auth/login_screen.dart`: a small `kDebugMode`-only diagnostic text displays the actual captured code and sanitized SDK message. The release-mode screen retains normal friendly messages; release logcat still contains the sanitized diagnostic events.
- `lib/core/firebase/firebase_initializer.dart`: logs initialization and non-secret application identity, never the API key or serialized Firebase options.
- `lib/main.dart`: verifies that the Firebase Auth instance belongs to the initialized Firebase app before constructing the repository.
- `test/auth_diagnostics_test.dart`: tests log sanitization, debug-only UI details, failure/exception codes, sign-in error details, timeout/manual entry and diagnostic-sink failures.

Existing animations, branding, Firestore models, sample seed logic, named database, rules and unrelated features were not edited. No verification bypass, forced testing credential, disabled app verification or emulator authentication was added to application code.

Event prefix: **`SmartVaxAuth`**. Invocation records only `e164Valid`, `countryCode`, timeout and resend booleans. Credential success records `uidPresent` and `verifiedPhonePresent`, not their values. A request sequence number correlates callbacks without logging credential identifiers.

## Configuration consistency: verified

| Item | Result |
| --- | --- |
| Project | `smartvax-e3956`; project number `533480028801` |
| Android app ID | `1:533480028801:android:3c7d2b6fe6320e1aa0ab80` |
| Package / namespace / MainActivity | `com.veda.smartvax` consistently |
| API key | Android JSON and Google Services generated release resources match; key belongs to the intended project. Its value is not included in this report. |
| `firebase_options.dart` | Absent intentionally; Android initialization uses generated native Google Services options. No fabricated Dart options were introduced. |
| FirebaseAuth | Created using `FirebaseAuth.instanceFor(app: initializedApp)`; runtime app-name and app-ID consistency is checked. |
| Named Firestore | Central provider still selects `smartvax`; unchanged |
| Phone input | `7893427676` and `+917893427676` normalize to `+917893427676`. Double country codes and malformed inputs are rejected. |
| Phone provider / test number | Enabled; designated testing number present, checked without logging its configured OTP |
| Authorized domain | `smartvax-e3956.firebaseapp.com` present |
| Identity Toolkit API | Enabled |
| Secure Token API | Enabled |
| Certificate registration | Both actual debug-key certificate fingerprints registered; no missing-SHA assumption |
| Android Activity | Standard `FlutterActivity`; installed FlutterFire plugin is Activity-aware and calls the native phone API's `setActivity` when attached |
| Browser callback | Merged APK manifest includes Firebase `RecaptchaActivity`, `GenericIdpActivity` and browsable intent filters |

The current API key service allowlist includes `identitytoolkit.googleapis.com`, `securetoken.googleapis.com` and `fpnv.googleapis.com`. Read-only `/v1/projects` requests with the actual APK package/SHA-1 headers and with browser-style headers both returned HTTP 200 and the intended project. This provides **no evidence of an API-key restriction blocking those requests**. It does not prove that all native verification requests from the handset succeed. No API-key restrictions were widened or removed.

Read-only configuration results are in `phone-auth-config-check.json` and local generated-resource comparisons in `phone-auth-local-config-check.json`. These files contain no API key, OAuth token, verification code or medical data.

## Confirmed configuration issue and Console actions

The live SMS region policy is `{"allowlistOnly": {}}`: no allowed regions are listed. For **normal SMS to India**, review Firebase Console → Authentication → Settings → SMS region policy and allow **India (`IN`)**. Restrict the policy to the regions the application needs. This policy was not changed during the investigation.

**It is not established that this policy caused the configured test-number failure.** Test numbers do not receive SMS; the handset exception and backend message are still needed to distinguish region/provider restrictions from reCAPTCHA, app verification, network, billing/quota or device issues.

No API-key restriction change is currently justified by the observed evidence. If device diagnostics specifically report an API-key/app/referrer block, inspect that specific key and request restriction before making a targeted change. A sideloaded APK can require reCAPTCHA fallback; Firebase documents that the key must permit the project's Firebase auth domain for that flow. Play Integrity is managed by Firebase; this task did not enable extra services or disable security checks.

Primary references:

- [Firebase Android Phone Authentication](https://firebase.google.com/docs/auth/android/phone-auth)
- [Firebase API-key restrictions and required services](https://firebase.google.com/docs/projects/api-keys)
- [SMS region policy](https://docs.cloud.google.com/identity-platform/docs/admin/sms-regions)

## Obtaining the missing handset evidence without a USB connection

Install the **diagnostic debug APK** at `build/app/outputs/flutter-apk/app-debug.apk`. It uses the same application ID and registered debug signing key. Press Continue and read the **Verification error** code and sanitized message beneath the friendly error. This diagnostic display is not included in the release UI. Do not disclose the OTP or copy unrelated device logs.

The release APK at `build/app/outputs/flutter-apk/app-release.apk` also logs sanitized events. If a device connection becomes available later, capture only those events:

```sh
adb logcat -v time | rg 'SmartVaxAuth'
```

A `verificationFailed` event identifies a request failure. A `verifyPhoneNumber.exception` event identifies initiation failure. A `signInCredential.failure` event identifies credential verification failure. `codeSent` establishes that Firebase supplied a verification ID and the OTP UI is ready. `signInCredential.success` with UID/verified-phone booleans establishes SDK sign-in completion, while household loading/import is a separate subsequent operation.

No live end-user sign-in, UID creation, SMS request or sample import was performed from this workstation. OTP authentication and Firestore sample import remain **pending actual-device verification**. The current evidence cannot support a claim that the persistent authentication failure is fixed.

## Final verification and artifacts

`flutter analyze` passed with no issues. All **52 Flutter tests passed**. `flutter build apk --release` and the supplemental diagnostic debug build succeeded. Both resulting APK signatures were verified and both actual certificate fingerprints match the live Firebase registration. Both merged manifests include the Firebase reCAPTCHA Activity. Artifact details are in `phone-auth-build.json`.

- Release APK: `/Users/puppalavedaharsha/Desktop/smart child vacination/build/app/outputs/flutter-apk/app-release.apk`; 60,760,381 bytes; file SHA-256 `0fda3e89dd41cec0904f3f0d162e08e016fde59be1bf36378da8cc4f3589e758`.
- Debug APK: `/Users/puppalavedaharsha/Desktop/smart child vacination/build/app/outputs/flutter-apk/app-debug.apk`; 174,788,815 bytes; file SHA-256 `2538a51d40d2aeb3cc4f82c8464110094c08385411a7844b49cb253eec6243f1`.

Both APKs remain debug-key-signed private-testing builds. No production keystore was created. APK contents changed because of this diagnostic implementation, so these checksums supersede the prior release-build artifact checksum. Firestore schema/seed/rules and Firebase configuration were not changed.
