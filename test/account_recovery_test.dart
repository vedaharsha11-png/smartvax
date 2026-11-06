import 'dart:async';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartvax/data/migration/sample_data_migration.dart';
import 'package:smartvax/data/repositories/account_repository.dart';
import 'package:smartvax/data/repositories/auth_repository.dart';
import 'package:smartvax/state/smartvax_controller.dart';

class RecoveryRepository extends AccountRepository {
  RecoveryRepository(super.firestore);
  bool reject = false;
  bool offline = false;
  Completer<void>? hold;
  @override
  Stream<AccountSnapshot> watch(String uid) => super
      .watch(uid)
      .map(
        (s) => AccountSnapshot(
          s.documents,
          fromCache: offline,
          pending: s.pending,
        ),
      );
  @override
  Future<void> applyChanges(
    String uid,
    AccountDocuments before,
    AccountDocuments after,
  ) async {
    if (reject) throw StateError('Write rejected');
    if (hold != null) await hold!.future;
    await super.applyChanges(uid, before, after);
  }
}

Future<void> until(bool Function() condition) async {
  for (var i = 0; i < 200; i++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  fail('State change timed out');
}

void main() {
  test(
    'failed sequential saves retry the latest desired state without replaying stale edits',
    () async {
      final repo = RecoveryRepository(FakeFirebaseFirestore());
      final auth = AuthRepository(
        MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(
            uid: 'a',
            phoneNumber: SampleDataMigration.testPhone,
          ),
        ),
      );
      final controller = SmartVaxController(
        authRepository: auth,
        accountRepository: repo,
      );
      addTearDown(controller.dispose);
      addTearDown(auth.dispose);
      await until(() => controller.isLoggedIn);
      repo.reject = true;
      controller.saveChild(
        controller.children.first.copyWith(notes: 'First edit'),
      );
      controller.saveChild(
        controller.children.first.copyWith(notes: 'Latest edit'),
      );
      await until(() => controller.accountError != null);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(controller.pendingWrites, isTrue);
      repo.reject = false;
      await controller.retryAccount();
      await until(() => !controller.pendingWrites);
      expect(
        (await repo
                .account('a')
                .collection('children')
                .doc('child_aarav')
                .get())
            .data()!['notes'],
        'Latest edit',
      );
    },
  );
  test(
    'pending offline changes remain visibly pending until write completion',
    () async {
      final repo = RecoveryRepository(FakeFirebaseFirestore())..offline = true;
      final auth = AuthRepository(
        MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(
            uid: 'a',
            phoneNumber: SampleDataMigration.testPhone,
          ),
        ),
      );
      final controller = SmartVaxController(
        authRepository: auth,
        accountRepository: repo,
      );
      addTearDown(controller.dispose);
      addTearDown(auth.dispose);
      await until(() => controller.isLoggedIn);
      expect(controller.fromCache, isTrue);
      repo.hold = Completer<void>();
      controller.selectChild('child_diya');
      expect(controller.pendingWrites, isTrue);
      expect(controller.syncMessage, contains('waiting'));
      repo.hold!.complete();
      await until(() => !controller.pendingWrites);
    },
  );
  test(
    'switching authenticated UIDs never exposes previous household state',
    () async {
      final repo = RecoveryRepository(FakeFirebaseFirestore());
      final firebase = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(
          uid: 'a',
          phoneNumber: SampleDataMigration.testPhone,
        ),
      );
      final auth = AuthRepository(firebase);
      final controller = SmartVaxController(
        authRepository: auth,
        accountRepository: repo,
      );
      addTearDown(controller.dispose);
      addTearDown(auth.dispose);
      await until(() => controller.isLoggedIn);
      expect(controller.children.length, 3);
      controller.logout();
      expect(controller.children, isEmpty);
      await until(() => firebase.currentUser == null);
      firebase.mockUser = MockUser(uid: 'b', phoneNumber: '+919123456789');
      await firebase.signInWithCredential(null);
      await until(() => controller.currentUid == 'b' && controller.isLoggedIn);
      expect(controller.children, isEmpty);
      expect(controller.records, isEmpty);
      expect(controller.activeGuardian?.name, 'Parent');
    },
  );
  test(
    'malformed cloud document fails gracefully without opening household UI',
    () async {
      final repo = RecoveryRepository(FakeFirebaseFirestore());
      await SampleDataMigration(
        repo,
      ).prepare('a', SampleDataMigration.testPhone);
      await repo.account('a').collection('children').doc('child_aarav').update({
        'dob': 'invalid',
      });
      final auth = AuthRepository(
        MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(
            uid: 'a',
            phoneNumber: SampleDataMigration.testPhone,
          ),
        ),
      );
      final controller = SmartVaxController(
        authRepository: auth,
        accountRepository: repo,
      );
      addTearDown(controller.dispose);
      addTearDown(auth.dispose);
      await until(() => controller.accountError != null);
      expect(controller.isLoggedIn, isFalse);
    },
  );
  test(
    'archiving a child hides related data and preserves private medical history',
    () async {
      final repo = RecoveryRepository(FakeFirebaseFirestore());
      final auth = AuthRepository(
        MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(
            uid: 'a',
            phoneNumber: SampleDataMigration.testPhone,
          ),
        ),
      );
      final controller = SmartVaxController(
        authRepository: auth,
        accountRepository: repo,
      );
      addTearDown(controller.dispose);
      addTearDown(auth.dispose);
      await until(() => controller.isLoggedIn);
      final count = controller.recordsFor('child_aarav').length;
      expect(controller.removeChild('child_aarav'), isTrue);
      await until(() => !controller.pendingWrites);
      expect(controller.childById('child_aarav'), isNull);
      expect(controller.recordsFor('child_aarav'), isEmpty);
      final child = await repo
          .account('a')
          .collection('children')
          .doc('child_aarav')
          .get();
      expect(child.data()!['archived'], isTrue);
      final history = await repo
          .account('a')
          .collection('vaccinationRecords')
          .where('childId', isEqualTo: 'child_aarav')
          .get();
      expect(history.docs.length, count);
      await SampleDataMigration(
        repo,
      ).prepare('a', SampleDataMigration.testPhone);
      expect((await child.reference.get()).data()!['archived'], isTrue);
    },
  );
  test(
    'live account pages retain every document across stable range boundaries',
    () async {
      final repo = RecoveryRepository(FakeFirebaseFirestore());
      final collection = repo.account('paged').collection('notifications');
      final batch = repo.firestore.batch();
      for (var i = 0; i < 250; i++) {
        batch.set(collection.doc('n${i.toString().padLeft(3, '0')}'), {
          'id': 'n${i.toString().padLeft(3, '0')}',
          'title': 'Notice',
        });
      }
      await batch.commit();
      AccountSnapshot? latest;
      final subscription = repo
          .watch('paged')
          .listen((snapshot) => latest = snapshot);
      addTearDown(subscription.cancel);
      await until(() => latest?.documents['notifications']?.length == 250);
      await collection.doc('n005a').set({
        'id': 'n005a',
        'title': 'Inserted within closed range',
      });
      await until(() => latest?.documents['notifications']?.length == 251);
      await collection.doc('n001').delete();
      await until(() => latest?.documents['notifications']?.length == 250);
      await collection.doc('n999').set({
        'id': 'n999',
        'title': 'Inserted in open tail',
      });
      await until(() => latest?.documents['notifications']?.length == 251);
      expect(latest!.documents['notifications']!.containsKey('n005a'), isTrue);
      expect(latest!.documents['notifications']!.containsKey('n999'), isTrue);
      expect(latest!.documents['notifications']!.containsKey('n001'), isFalse);
    },
  );
}
