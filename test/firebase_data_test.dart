import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartvax/core/firebase/firestore_provider.dart';
import 'package:smartvax/data/migration/sample_data_migration.dart';
import 'package:smartvax/data/model_codec.dart';
import 'package:smartvax/data/models.dart';
import 'package:smartvax/data/repositories/account_repository.dart';
import 'package:smartvax/data/repositories/auth_repository.dart';
import 'package:smartvax/state/smartvax_controller.dart';

Future<void> waitFor(bool Function() condition) async {
  for (var i = 0; i < 100; i++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Account did not reach expected state');
}

void main() {
  test('central provider explicitly targets requested named database', () {
    expect(FirestoreProvider.projectId, 'smartvax-e3956');
    expect(FirestoreProvider.databaseId, 'smartvax');
    final source = File(
      'lib/core/firebase/firestore_provider.dart',
    ).readAsStringSync();
    expect(source, contains('FirebaseFirestore.instanceFor('));
    expect(source, contains('databaseId: databaseId'));
  });

  test(
    'phone normalization accepts Indian input and rejects invalid phones',
    () {
      expect(normalizeIndianPhone('7893427676'), '+917893427676');
      expect(normalizeIndianPhone('+91 78934 27676'), '+917893427676');
      expect(() => normalizeIndianPhone('123'), throwsFormatException);
      expect(
        () => normalizeIndianPhone('+447893427676'),
        throwsFormatException,
      );
    },
  );

  test(
    'every sample model round trips typed Firestore dates and relationships',
    () {
      final data = SampleDataMigration.dataset();
      for (final value in data['children']!.values) {
        expect(
          ModelCodec.encodeChildProfile(ModelCodec.decodeChildProfile(value)),
          value,
        );
        expect(value['dob'], isA<Timestamp>());
      }
      for (final value in data['vaccinationRecords']!.values) {
        expect(
          ModelCodec.encodeVaccinationRecord(
            ModelCodec.decodeVaccinationRecord(value),
          ),
          value,
        );
      }
      for (final value in data['appointments']!.values) {
        expect(
          ModelCodec.encodeAppointment(ModelCodec.decodeAppointment(value)),
          value,
        );
      }
      expect(ModelCodec.decodeGuardian({'id': 'legacy'}).name, '');
      expect(
        () => ModelCodec.decodeChildProfile({'dob': 'invalid'}),
        throwsFormatException,
      );
      expect(ModelCodec.decodeVaccinationRecord({'id': 'old'}).notes, '');
      expect(
        ModelCodec.decodeVaccinationRecord({'id': 'old'}).status,
        RecordStatus.pending,
      );
      expect(
        () => ModelCodec.decodeVaccinationRecord({'status': 'completed'}),
        throwsFormatException,
      );
    },
  );

  test(
    'seed is atomic, complete, stable and does not restore deleted edits',
    () async {
      final db = FakeFirebaseFirestore();
      final repo = AccountRepository(db);
      final migration = SampleDataMigration(repo);
      expect(
        await migration.prepare('owner', SampleDataMigration.testPhone),
        'imported',
      );
      final source = SampleDataMigration.dataset();
      for (final entity in source.entries) {
        final stored = await repo.account('owner').collection(entity.key).get();
        expect(stored.docs.length, entity.value.length);
        for (final doc in stored.docs) {
          expect(doc.data()['ownerUid'], 'owner');
        }
      }
      final child = repo
          .account('owner')
          .collection('children')
          .doc('child_aarav');
      await child.update({'notes': 'Permanent edit'});
      final record = repo
          .account('owner')
          .collection('vaccinationRecords')
          .doc(source['vaccinationRecords']!.keys.first);
      await record.delete();
      expect(
        await migration.prepare('owner', SampleDataMigration.testPhone),
        'already-seeded',
      );
      expect((await child.get()).data()!['notes'], 'Permanent edit');
      expect((await record.get()).exists, isFalse);
      final marker =
          (await repo.account('owner').collection('metadata').doc('seed').get())
              .data()!;
      expect(marker['seedVersion'], 1);
      expect(marker['seedStatus'], 'complete');
      final counts = {
        for (final entry in source.entries) entry.key: entry.value.length,
      };
      final schedules = source['vaccinationRecords']!.values
          .where((r) => r['status'] != 'completed')
          .length;
      // ignore: avoid_print
      print('Sample dataset counts: $counts; schedule entries: $schedules');
      // Export the actual Dart factory to exercise its entire atomic seed against
      // real emulator rules with timestamp values preserved.
      dynamic jsonValue(dynamic value) {
        if (value is Timestamp) {
          return {'__timestamp': value.toDate().toUtc().toIso8601String()};
        }
        if (value is Map) return value.map((k, v) => MapEntry(k, jsonValue(v)));
        if (value is List) return value.map(jsonValue).toList();
        return value;
      }

      File(
        'security-test/sample-dataset.json',
      ).writeAsStringSync(jsonEncode(jsonValue(source)));
    },
  );

  test(
    'existing root without metadata is preserved; partial orphan seed conflicts',
    () async {
      final repo = AccountRepository(FakeFirebaseFirestore());
      final migration = SampleDataMigration(repo);
      await repo.account('existing').set({'name': 'Existing family'});
      expect(
        await migration.prepare('existing', SampleDataMigration.testPhone),
        'existing-account-preserved',
      );
      expect(
        (await repo.account('existing').collection('children').get()).docs,
        isEmpty,
      );
      await repo.account('partial').collection('children').doc('other').set({
        'name': 'Keep me',
      });
      await expectLater(
        migration.prepare('partial', SampleDataMigration.testPhone),
        throwsA(isA<MigrationConflict>()),
      );
      expect(
        (await repo.account('partial').collection('metadata').doc('seed').get())
            .exists,
        isFalse,
      );
    },
  );

  test(
    'other verified phone receives an empty household, isolated by UID',
    () async {
      final repo = AccountRepository(FakeFirebaseFirestore());
      final migration = SampleDataMigration(repo);
      await migration.prepare('a', SampleDataMigration.testPhone);
      await migration.prepare('b', '+919123456789');
      expect(
        (await repo.account('b').collection('children').get()).docs,
        isEmpty,
      );
      expect(
        (await repo.account('a').collection('children').get()).docs.length,
        3,
      );
      expect(() => repo.validateUid('a/children'), throwsArgumentError);
    },
  );

  test(
    'authenticated controller persists child, record, appointment, alert and selection across restart',
    () async {
      final db = FakeFirebaseFirestore();
      final repo = AccountRepository(db);
      final auth = AuthRepository(
        MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(
            uid: 'owner',
            phoneNumber: SampleDataMigration.testPhone,
          ),
        ),
      );
      var controller = SmartVaxController(
        accountRepository: repo,
        authRepository: auth,
        clock: () => DateTime(2026, 10, 12, 12),
      );
      await waitFor(
        () => controller.isLoggedIn || controller.accountError != null,
      );
      expect(controller.accountError, isNull);
      expect(controller.signInFixture('9876543210'), isFalse);
      expect(controller.activeGuardian?.name, 'Priya Sharma');
      expect(
        controller.guardianById(controller.children.first.motherId)?.name,
        'Priya Sharma',
      );
      controller.selectChild('child_diya');
      controller.saveChild(
        controller.childById('child_aarav')!.copyWith(notes: 'Cloud edit'),
      );
      final record = VaccinationRecord(
        id: 'added',
        childId: 'child_aarav',
        vaccineId: 'bcg',
        dose: 'Additional verified dose',
        status: RecordStatus.completed,
        administeredAt: DateTime(2026, 10, 12),
        doctorId: null,
        hospitalId: null,
      );
      expect(controller.saveRecord(record), isTrue);
      controller.markAllRead();
      controller.updateAppointmentStatus(
        controller.appointments.first.id,
        AppointmentStatus.cancelled,
      );
      await waitFor(
        () => !controller.pendingWrites || controller.accountError != null,
      );
      expect(controller.accountError, isNull);
      controller.dispose();
      final restoredAuth = AuthRepository(
        MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(
            uid: 'owner',
            phoneNumber: SampleDataMigration.testPhone,
          ),
        ),
      );
      controller = SmartVaxController(
        accountRepository: repo,
        authRepository: restoredAuth,
        clock: () => DateTime(2026, 10, 12, 12),
      );
      await waitFor(
        () => controller.isLoggedIn || controller.accountError != null,
      );
      expect(controller.accountError, isNull);
      expect(controller.childById('child_aarav')!.notes, 'Cloud edit');
      expect(controller.recordById('added'), isNotNull);
      expect(controller.selectedChildId, 'child_diya');
      expect(controller.unreadCount, 0);
      expect(
        controller.appointments.any(
          (a) => a.status == AppointmentStatus.cancelled,
        ),
        isTrue,
      );
      expect(controller.saveRecord(record.copyWith(notes: 'Updated')), isTrue);
      await waitFor(
        () => !controller.pendingWrites || controller.accountError != null,
      );
      expect(controller.accountError, isNull);
      expect(controller.deleteRecord('added'), isTrue);
      await waitFor(
        () => !controller.pendingWrites || controller.accountError != null,
      );
      expect(controller.accountError, isNull);
      expect(
        (await repo
                .account('owner')
                .collection('vaccinationRecords')
                .doc('added')
                .get())
            .exists,
        isFalse,
      );
      controller.logout();
      expect(controller.children, isEmpty);
      expect(controller.records, isEmpty);
      expect(controller.currentUid, isNull);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(controller.isLoggedIn, isFalse);
      controller.dispose();
      auth.dispose();
      restoredAuth.dispose();
    },
  );
}
