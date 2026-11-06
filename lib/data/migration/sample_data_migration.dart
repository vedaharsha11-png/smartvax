import 'package:cloud_firestore/cloud_firestore.dart';
import '../models.dart';
import '../sample_data.dart';
import '../model_codec.dart';
import '../repositories/account_repository.dart';

class MigrationConflict implements Exception {
  const MigrationConflict(this.message);
  final String message;
}

class SampleDataMigration {
  SampleDataMigration(this.repository);
  final AccountRepository repository;
  static const testPhone = '+917893427676';
  static const seedVersion = 1;
  // Freeze the existing application's reference date, not each login's date.
  static final datasetDate = DateTime(2026, 10, 11, 12);

  static AccountDocuments dataset() {
    final children = SampleData.children(datasetDate);
    final records = SampleData.records(datasetDate, children);
    final reminders = [
      for (final record in records.where(
        (r) => r.status == RecordStatus.planned,
      ))
        for (final days in const [7, 3, 1, 0])
          Reminder(
            id: 'rem_${record.id}_$days',
            childId: record.childId,
            recordId: record.id,
            daysBefore: days,
            enabled: true,
          ),
    ];
    return {
      'guardians': {
        for (final x in SampleData.guardians())
          x.id: ModelCodec.encodeGuardian(x),
      },
      'children': {
        for (final x in children) x.id: ModelCodec.encodeChildProfile(x),
      },
      'vaccinationRecords': {
        for (final x in records) x.id: ModelCodec.encodeVaccinationRecord(x),
      },
      'doctors': {
        for (final x in SampleData.doctors())
          x.id: ModelCodec.encodeDoctorProfile(x),
      },
      'hospitals': {
        for (final x in SampleData.hospitals())
          x.id: ModelCodec.encodeHospitalProfile(x),
      },
      'appointments': {
        for (final x in SampleData.appointments(datasetDate))
          x.id: ModelCodec.encodeAppointment(x),
      },
      'reminders': {
        for (final x in reminders)
          x.id: ModelCodec.encodeReminder(
            x,
            targetDate: records
                .firstWhere((r) => r.id == x.recordId)
                .plannedFor
                ?.subtract(Duration(days: x.daysBefore)),
          ),
      },
      'notifications': {
        for (final x in SampleData.notifications(datasetDate))
          x.id: ModelCodec.encodeNotificationItem(x),
      },
      'healthTips': {
        for (final x in SampleData.tips()) x.id: ModelCodec.encodeHealthTip(x),
      },
      'settings': {
        'main': {
          ...ModelCodec.encodeAppSettings(const AppSettings()),
          'selectedChildId': 'child_aarav',
          'activeGuardianId': 'g_mother',
          'visitChecklists': <String, dynamic>{},
        },
      },
    };
  }

  Future<String> prepare(String uid, String? verifiedPhone) async {
    repository.validateUid(uid);
    final account = repository.account(uid);
    final marker = account.collection('metadata').doc('seed');
    final existingMarker = await marker.get(
      const GetOptions(source: Source.server),
    );
    if (existingMarker.data()?['seedStatus'] == 'complete') {
      return 'already-seeded';
    }
    final existing = await account.get(const GetOptions(source: Source.server));
    if (existing.exists) {
      // An existing real household is loaded intact. Automatic reconciliation
      // never introduces deleted samples or overwrites customer edits.
      return 'existing-account-preserved';
    }
    for (final collection in AccountRepository.collections) {
      final found = await account
          .collection(collection)
          .limit(1)
          .get(const GetOptions(source: Source.server));
      if (found.docs.isNotEmpty) {
        throw const MigrationConflict(
          'Existing account records need reconciliation. No sample information was overwritten.',
        );
      }
    }
    final sample = verifiedPhone == testPhone;
    final documents = sample
        ? dataset()
        : <String, Map<String, Map<String, dynamic>>>{
            'guardians': {
              'g_mother': ModelCodec.encodeGuardian(
                Guardian(
                  id: 'g_mother',
                  name: 'Parent',
                  relation: 'Mother',
                  mobile: verifiedPhone?.replaceFirst('+91', '') ?? '',
                  avatar: '🙂',
                ),
              ),
              'g_father': ModelCodec.encodeGuardian(
                const Guardian(
                  id: 'g_father',
                  name: 'Linked parent',
                  relation: 'Father',
                  mobile: '',
                  avatar: '🙂',
                ),
              ),
            },
            'settings': {
              'main': {
                ...ModelCodec.encodeAppSettings(const AppSettings()),
                'selectedChildId': '',
                'activeGuardianId': 'g_mother',
                'visitChecklists': <String, dynamic>{},
              },
            },
          };
    return repository.firestore.runTransaction((transaction) async {
      final root = await transaction.get(account);
      final migration = await transaction.get(marker);
      if (migration.data()?['seedStatus'] == 'complete') {
        return 'already-seeded';
      }
      if (root.exists) return 'existing-account-preserved';
      // Read all deterministic targets before writing anything. A concurrent
      // creator forces a retry; any conflict is preserved rather than merged.
      final targets =
          <DocumentReference<Map<String, dynamic>>, Map<String, dynamic>>{};
      for (final collection in documents.entries) {
        for (final entry in collection.value.entries) {
          final ref = account.collection(collection.key).doc(entry.key);
          if ((await transaction.get(ref)).exists) {
            throw const MigrationConflict(
              'Existing records need reconciliation. Import was not applied.',
            );
          }
          targets[ref] = entry.value;
        }
      }
      transaction.set(account, {
        'ownerUid': uid,
        'phoneNumber': verifiedPhone,
        'schemaVersion': 1,
        'createdAt': FieldValue.serverTimestamp(),
        'datasetDate': Timestamp.fromDate(datasetDate),
      });
      for (final entry in targets.entries) {
        transaction.set(entry.key, {
          ...entry.value,
          'ownerUid': uid,
          'schemaVersion': 1,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      if (sample) {
        transaction.set(marker, {
          'seedVersion': seedVersion,
          'seedStatus': 'complete',
          'seededUid': uid,
          'ownerUid': uid,
          'datasetIdentifier': 'smartvax-sharma-v1',
          'schemaVersion': 1,
          'completedAt': FieldValue.serverTimestamp(),
          'counts': {for (final x in documents.entries) x.key: x.value.length},
          'skipped': 0,
        });
      }
      return sample ? 'imported' : 'empty-account-created';
    });
  }
}
