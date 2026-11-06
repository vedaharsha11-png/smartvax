# SmartVax Firestore schema and persistence

All private information lives beneath `users/{Firebase UID}` in the named `smartvax` database. The path UID, checked against `request.auth.uid`, owns the records. Guardian mobile numbers and displayed names provide no access authority.

| Path under account | Contents |
| --- | --- |
| account root | Verified phone, owner UID, schema version, creation time, dataset reference date |
| `guardians/{id}` | Names, relation, informational mobile, avatar |
| `children/{id}` | DOB timestamp, gender, card ID, blood group, guardian IDs, address, emergency contact, medical notes |
| `vaccinationRecords/{id}` | Child/vaccine/dose IDs, status, distinct administered/planned timestamps, doctor/hospital IDs, batch, notes, illustrative source flag |
| `doctors/{id}` / `hospitals/{id}` | Original account-owned fictional directory and associations; original avatar/illustration references |
| `appointments/{id}` | Child, doctor and hospital IDs; visit date, hour/minute, status, reason, notes |
| `reminders/{id}` | Owner, child, record, target timestamp derived from stored plan, days-before and enabled state |
| `notifications/{id}` | Timestamp, type, read state and optional child/reference IDs |
| `healthTips/{id}` | Original titles and bodies |
| `settings/main` | Reminder preferences, active informational guardian, selected child, appointment checklists |
| `metadata/seed` | Version 1, completion state/time, UID, dataset identifier, schema version, entity counts, skipped count |

The eight vaccine catalog entries remain bundled read-only Dart reference data. The five schedule entries are the planned records within `vaccinationRecords`; there is no duplicated `vaccineSchedule` collection. Child ages and overdue labels are derived from saved dates and the current clock. Calendar entries derive from saved records and visits.

`ModelCodec` contains explicit document mappers. Dates are Firestore timestamps; times are `{hour, minute}`; enums use their names. Missing optional fields get defaults. Malformed mandatory dates produce a recoverable account error. Widgets/icons/colors are never stored in Firestore. Every entity write has `ownerUid`, `schemaVersion: 1`, and a server `updatedAt`; new entities also have server `createdAt`. Updates preserve creation metadata.

The account repository combines ten user-scoped collection streams. Listeners start once per authenticated account and stop on logout/disposal. They do not scan the project or poll. The controller computes field/model changes and batches only changed/new/deleted entity documents. Writes execute in order, preventing older edits from replacing newer changes. Save errors keep the desired local state, block later saves, and offer a consolidated retry. Snapshot changes update all existing screens through the shared controller.

Growing collections use automatic entity-ID pagination: the repository discovers ranges in pages of 100, closes each completed range at a stable entity-ID boundary (the stored ID is validated to equal the document ID), and watches an open tail for new records. Inserts/deletions cannot shift records between pages and cause omissions. All pages remain live and the controller retains the complete household so dose counts, searches, calendar and archival are accurate. Initial range discovery can reread completed pages once when establishing their fixed listeners; listeners are reused thereafter. This is household-oriented, not a memory-bounded medical archive browser; very large production archives should add separate server summaries and an on-demand history view.

One UI mutation is limited to 450 changed documents and fails visibly above that limit. No composite index is required for the current account subcollection/entity-ID queries; the supplied indexes file intentionally has none.

Child removal uses an explicit archive confirmation. The child becomes an owned archived document; related medical records/visits/reminders/alerts remain stored and are filtered out of active screens. Guardian links and record references remain valid. This handles concurrently inserted related records safely: they also become hidden once the child's archive arrives. Rules prevent new vaccine/visit/reminder writes against an archived child, and disallow hard child deletion. Removing the final active child shows the existing empty state. The importer never unarchives a child or restores deleted records. Individual record deletion remains an explicit confirmed permanent deletion.

Record completion removes the corresponding planned dose and its reminders; attending appointments never completes vaccines. Client validation rejects future/before-birth administration dates and duplicate completed doses. Rules independently validate date bounds and owned references.

Disk Firestore persistence is disabled because this application stores child-health information and supports account switching. The in-process memory cache supports viewing already loaded screens and queued changes. A fresh launch/account initialization needs a server connection; offline edits are not durable across process termination. Wait for the synchronization indicator to confirm persistence before closing or logging out. Firebase Auth persists its authenticated session independently. No fallback sample account is used on failure.

Rules deny unauthenticated and cross-account reads/writes, unrecognized collections/fields, role injection, invalid statuses, malformed field types, missing parent/child/provider references, and invalid completed dates. The root profile and completed seed marker are immutable to clients. Metadata cannot authorize another UID. Sharing is intentionally not implemented. The rules' database wildcard is standard Firestore syntax; `firebase.json` explicitly binds this file to the named database only.
