# SmartVax

Smart Child Vaccination Tracking System retains its original splash, liquid glass theme, five-tab navigation, child avatars, catalog and health features. Android now uses Firebase Phone Authentication and account-owned Cloud Firestore persistence.

- Project: `smartvax-e3956`
- Database: **`smartvax`**, Mumbai (`asia-south1`), explicitly initialized with `FirebaseFirestore.instanceFor`
- Android package: `com.veda.smartvax`; display name: `SmartVax`
- Android configuration: verified `android/app/google-services.json`

Changing from `com.smartvax.app` creates a different Android installed application. The previous application’s in-memory edits cannot be recovered after its process exits. The complete bundled dataset is retained for the one-time migration.

```sh
flutter pub get
flutter run
flutter build apk --debug
```

APK: `build/app/outputs/flutter-apk/app-debug.apk`.

Read [Firebase setup and verification](docs/firebase-setup.md), [schema and behavior](docs/firestore-schema.md), and the [implementation and migration report](docs/firebase-migration-report.md) before live testing. Other platforms require their own valid Firebase registrations; Android configuration is not reused for web or iOS.

Enter a valid Indian number and use the code Firebase supplies. `+917893427676` uses the code configured in the Firebase Console; the code is never stored in this repository. No sample-login or arbitrary-code bypass exists in the application flow. Other verified accounts start with an empty child household and editable informational parent profiles.

Edits immediately show pending synchronization and are saved through the account repository. The Firestore write acknowledgement determines confirmed persistence. Sign-out clears user state, listeners and navigation. Informational parent switching does not change the authenticated UID or grant another account access.

Appointments are saved requests or local plans; a center has not confirmed them. Attending a visit does not create a vaccination record. Reminders and alerts are in-app information. There is no FCM, hospital booking integration or device notification scheduling.

```sh
flutter pub get
dart format .
flutter analyze
flutter test
npm ci --prefix security-test
firebase emulators:exec --only firestore --project demo-smartvax 'cd security-test && npm test'
flutter build apk --debug
```

Run Flutter tests before the rules tests: they export the actual sample factory as `security-test/sample-dataset.json` for the full atomic import rules check. Rules tests use only the emulator's fictional project and do not contact the live Firebase project.

Catalog descriptions remain informational references, not personalized eligibility or catch-up prescriptions. Sample vaccination records are not official certificates. Confirm dates and health decisions with an authorized clinician.

## Optimized Android release build

The private-testing release APK is `build/app/outputs/flutter-apk/app-release.apk`. It is compiled in release mode with shrinking, but signed with the existing debug key and is **not production-ready**. See [release artifact, signing fingerprints and verification](docs/android-release-build.md). No production keystore was created.

## Phone authentication diagnostics

See [the persistent phone-authentication investigation](docs/phone-auth-troubleshooting.md). The current debug APK displays sanitized Firebase exception details on the login screen. The release APK logs sanitized `SmartVaxAuth` events. The installed-device root cause and live sign-in/import remain unverified; artifact metadata is in [phone-auth-build.json](docs/phone-auth-build.json).
