# SmartVax Firebase implementation and migration report

Report date: 12 October 2026 (India).

| Configuration | Verified result |
| --- | --- |
| Firebase project | `smartvax-e3956`; local JSON and live database API match |
| Firestore database | `smartvax`; explicitly injected from the central named provider |
| Region | `asia-south1` (Mumbai), verified through the live API |
| Android package / display name | `com.veda.smartvax` / `SmartVax`, verified in the compiled APK |
| Firebase Android JSON | Present and matches package/project/application registration |
| Auth provider | Firebase Phone Authentication implemented; device verification pending |
| Test phone | `+917893427676`, checked from Firebase's authenticated User by the importer caller |
| Seed / schema version | 1 / 1 |
| Source dataset | Entire `lib/data/sample_data.dart` factory, including its original Sharma IDs/relationships; factory reference frozen at 11 October 2026, 12:00 local time |
| Actual live import | **Not attempted. No authenticated end-user UID or live write was verified.** |
| Live rules | Deployed with explicit owner approval; live named-database source exactly matches tested ownership rules. Existing deny-all source retained for review. |
| Android fingerprints | Actual debug key/APK fingerprints match; Firebase registration has no hashes |
| Device/emulator availability | No Android device or configured Android emulator available |

## Dataset counts

Counts were calculated from the real Dart sample factory and checked against stored emulator/fake account documents. They are **prepared/emulator-imported counts, not live-account import claims**.

| Entity | Prepared and verified locally | Live imported |
| --- | ---: | --- |
| Guardians | 2 | Not verified |
| Children | 3 | Not verified |
| Vaccination records | 32 | Not verified |
| Schedule entries | 5 (included in the 32 records) | Not verified |
| Doctors | 3 | Not verified |
| Hospitals | 3 | Not verified |
| Appointments | 4 | Not verified |
| Reminders | 20 | Not verified |
| Notifications | 8 | Not verified |
| Health tips | 8 | Not verified |
| Settings documents | 1 | Not verified |
| Vaccine catalog | 8 bundled read-only entries | No cloud import required |

The atomic seed creates 84 entity documents plus the UID root and completion marker (86 writes). All deterministic targets are read before any transaction write. First local import skipped zero existing records. Repeated local login skips the entire seed using its completion marker; edited/deleted records remain edited/deleted. **Live skipped-record count is unknown**, because no live import was attempted.

An existing root without a seed marker is preserved, and orphan subcollections stop automatic seeding with a reconciliation error. A second verified phone gets an empty child household and two basic editable informational guardian profiles, with none of the Sharma children's medical data. Parent persona switching remains household information only and cannot change Firebase identity.

## Implemented behavior

Real OTP request, manual/automatic credential sign-in, resend-token handling, cooldown, timeouts, error messages, loading and duplicate-request prevention replace the old arbitrary-code screen. Firebase Auth sessions restore on startup. Data loading and snapshot subscriptions are generation-scoped and cleared on logout. Navigator state resets across UIDs.

The central account repository targets the injected named database. Explicit model codecs cover all current entities. Profiles, records/schedules, directories, visits, reminders, notifications, checklists and settings load from account documents. Controller changes produce ordered, atomic batches of changed entities; confirmation and pending states are distinct. Failed writes retain the latest desired state for retry. Account collections use stable entity-ID ranges discovered in pages of 100 and remain live without polling.

Child removal is a confirmed archive: the owned child document and associated medical history remain stored, active screens hide them, and new clinical/visit/reminder writes to archived children are rejected. Standalone record deletion uses the existing confirmation and permanent deletion. New-account profile/visit forms handle missing children/providers without sample-address leakage or empty-list crashes.

Original branding, theme, splash, layouts, catalog, sample doctors/centers, relationships and navigation are retained. Cloud reset is unavailable; the isolated model fixture exists only for tests and is not reachable through application authentication.

## Verification

- `flutter pub get`: passed.
- `dart format .`: completed.
- `flutter analyze`: no issues.
- **45 Flutter tests passed**; includes phone callbacks/errors, normalization, codecs, seed counts/idempotence/conflicts, UID separation, persistent edits/restart, retry, pending/offline indicators, malformed documents, archival, automatic pagination and original layout/boot/navigation checks.
- Firebase Emulator Suite: **18 security tests passed**, including all requested ownership/isolation cases, malformed/invalid writes, date bounds, trusted-field injection, full real-factory atomic seed and archival restrictions.
- Android debug build: **final build passed**. Package and signer were independently inspected with Android build tools.
- Physical-device OTP, Play Integrity/reCAPTCHA, live account seed, real cold restart and network recovery: **pending**, not inferred from compilation or mocks.

Rules tests ran against the emulator's fictional project. The Android named-provider signature was checked against installed `cloud_firestore 6.10.0`; runtime app data never uses `FirebaseFirestore.instance`. Installed compatible Firebase packages are `firebase_core 4.15.0`, `firebase_auth 6.7.0`, and `cloud_firestore 6.10.0`.

## Remaining owner actions and practical limits

1. Rules deployment completed with owner approval, only for `smartvax-e3956` / `smartvax`. Existing remote indexes were not deployed or modified.
2. Register the documented debug SHA-1/SHA-256 and download updated Android configuration if Firebase changes it.
3. Install the new package, verify the configured phone code on-device, inspect the seed marker/counts under the real UID and run restart/isolation/network tests.
4. If the designated test number is real and active, use normal SMS instead of registering it as a fictional Firebase test number.

Disk medical-data cache is disabled. Previously loaded data and queued edits exist in memory while the process runs; a cold offline start needs connectivity and unsynchronized edits do not survive process termination. Wait for server-confirmed save before closing/signing out. The UI explains these states. Complete household state remains in controller memory even though reads are paged; very large archives need a separate aggregate/history design. A single mutation over 450 documents fails visibly rather than splitting an unsafe partial batch.

The Android build emits a future-compatibility warning about Firebase plugins' Kotlin Gradle Plugin use with newer Flutter/AGP. The current selected versions compile successfully; unrelated dependency upgrades were avoided. In-app persistence does not schedule push/device notifications or obtain hospital booking confirmation.

Final checks completed: analyzer has no issues, 45 Flutter tests passed, 18 emulator rules tests passed, and the final debug APK built successfully. Live ownership rules were deployed with explicit approval and their exact source was verified after deployment. No live household data was written.

## Approved live rules deployment

The pre-deployment check confirmed the project, named database, Mumbai location and unchanged deny-all baseline. The rules-only CLI deployment succeeded. The live release is `projects/smartvax-e3956/releases/cloud.firestore/smartvax`, referencing `projects/smartvax-e3956/rulesets/61c1cc5c-d366-4144-aded-a333111e89cc`. Updated at `2026-10-12T10:01:06.069849Z` (UTC). A subsequent independent API read confirmed that the live source exactly matches `firestore.smartvax.rules` and is attached to `databases/smartvax`. Only rules were included; no indexes, other databases, authentication users, hosting, functions or storage were modified. Verification metadata is in `smartvax-rules-deployment.json`. Actual phone verification and end-user sample import remain pending.
