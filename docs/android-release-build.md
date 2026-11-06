# SmartVax optimized Android release APK

Built and verified on 12 October 2026. This is a **release-mode APK signed with the existing Android debug key for private testing**. It is **not production-ready**. No new keystore was created and no signing credentials were overwritten.

## Artifact

- Exact path: `/Users/puppalavedaharsha/Desktop/smart child vacination/build/app/outputs/flutter-apk/app-release.apk`
- Size: **60,662,077 bytes** (60.66 MB; 57.85 MiB).
- Application ID: `com.veda.smartvax`.
- Display name: `SmartVax`.
- Version: `1.1.0`, version code `2` (`1.1.0+2`).
- Minimum Android SDK: 24; target SDK: 36.
- Included ABIs: `arm64-v8a`, `armeabi-v7a`, `x86_64`.
- APK file SHA-256: `60a08241bf82d54008143c8dc774944770497e513e2b6d1debe115f1b7366bc6`.

## Actual signing certificate

Gradle's release signing report and the resulting APK independently agree:

```text
Configuration: debug
Keystore: /Users/puppalavedaharsha/.android/debug.keystore
Alias: AndroidDebugKey
Certificate subject: C=US, O=Android, CN=Android Debug

SHA-1:
6B:FF:04:F4:A0:BA:E5:8E:0E:4D:92:9D:38:29:8D:76:71:AC:49:87

SHA-256:
40:F3:DD:EB:5B:EF:EA:A8:01:14:BC:42:C7:E6:15:95:3C:A7:E8:6C:9D:B3:CC:80:BD:5E:CC:9C:E6:DF:FA:25
```

`apksigner verify --verbose --print-certs` passed with APK Signature Scheme v2. The fingerprints above identify the signing certificate; the artifact checksum identifies the APK file and is different.

The project has no configured production keystore or `android/key.properties`. Only the standard debug keystore was found in the inspected project/Android signing locations. For production signing, provide an existing secure keystore and its configuration, or explicitly authorize creation of a separate production keystore. Passwords must stay in local ignored properties or a secure build environment. Register the eventual production certificate with Firebase and rebuild. A differently signed production APK cannot update this debug-key-signed installation in place.

## Optimization and preservation

The requested `flutter build apk --release` succeeded. Dart is compiled AOT; the APK includes `libapp.so` and does not include a debug kernel snapshot. The manifest is not debuggable. R8 code shrinking and Android resource shrinking are explicitly enabled; optimizer mapping/resource outputs exist under `build/app/outputs/mapping/release`. Flutter tree-shook the Material Icons font by 99.2%.

No Dart feature, layout, navigation, Firebase data configuration, artwork, icon or animation was changed in this task. The declared bundled UI artwork was verified in the final APK. Signing credentials are excluded through `.gitignore`. Android Gradle changes are limited to explicit optimizer settings and identification of the existing private-testing signing fallback.

## Checks

- `flutter pub get`: passed.
- `flutter analyze`: no issues.
- `flutter test`: **45 tests passed**.
- `flutter build apk --release`: succeeded.
- APK package, display name, version, architecture and SDK metadata: verified with `aapt`.
- Release signing configuration: checked with Gradle `:app:signingReport`.
- Resulting APK signature and fingerprints: verified with `apksigner`.
- Firebase project remains `smartvax-e3956`; the central Firestore provider still explicitly selects database `smartvax`.
- Live read-only Firebase inspection confirmed **both actual APK certificate fingerprints are registered** on the matching Android application.
- Downloaded live SDK configuration was validated and is identical to the existing `android/app/google-services.json`; no configuration replacement was needed.
- Phone provider is enabled, the designated testing phone is present, and the expected Firebase authentication domain is authorized. The test code was not logged or saved.

No Firebase service was deployed, no production data was modified, and the app was not published.

## Remaining phone-authentication verification

No Android device or configured Android emulator is connected to this workspace, so actual on-device Phone Authentication has **not** been verified. The supplied screenshot shows a verification failure; this build alone does not establish its cause or prove it is resolved.

Read-only inspection reports SMS region configuration `{"allowlistOnly": {}}`, with no allowed regions listed. Review Firebase Console → Authentication → Settings → SMS region policy before sending real SMS to India. Do not assume this is the cause of the configured test-number failure: testing numbers do not receive SMS, and the native app verification flow still needs an on-device check. See [Google's SMS region policy documentation](https://docs.cloud.google.com/identity-platform/docs/admin/sms-regions) and [Firebase Android Phone Authentication documentation](https://firebase.google.com/docs/auth/android/phone-auth).

Install the private-testing release APK, repeat verification with the configured Console code, and inspect the Firebase Auth error code through device logs if it still fails. Do not share OTPs, authentication tokens or private health information in logs. Production signing and real-device authentication remain the outstanding requirements.

This earlier build report records the pre-diagnostics artifact. Its size/checksum is historical; use `phone-auth-build.json` for the current rebuilt APK and `phone-auth-troubleshooting.md` for current authentication findings.
