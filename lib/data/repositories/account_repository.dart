import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

typedef AccountDocuments = Map<String, Map<String, Map<String, dynamic>>>;

class AccountSnapshot {
  const AccountSnapshot(
    this.documents, {
    required this.fromCache,
    required this.pending,
  });
  final AccountDocuments documents;
  final bool fromCache;
  final bool pending;
}

/// A household has one owner and explicit entity documents. Only this class
/// knows collection paths. Each mutation sends just changed documents.
class AccountRepository {
  AccountRepository(this.firestore);
  final FirebaseFirestore firestore;
  static const collections = [
    'guardians',
    'children',
    'vaccinationRecords',
    'doctors',
    'hospitals',
    'appointments',
    'reminders',
    'notifications',
    'healthTips',
    'settings',
  ];
  DocumentReference<Map<String, dynamic>> account(String uid) =>
      firestore.collection('users').doc(uid);
  void validateUid(String uid) {
    if (uid.isEmpty || uid.contains('/')) throw ArgumentError('Invalid UID');
  }

  Stream<AccountSnapshot> watch(String uid) {
    validateUid(uid);
    late StreamController<AccountSnapshot> controller;
    final subscriptions = <StreamSubscription>[];
    final documents = <String, Map<String, Map<String, dynamic>>>{};
    final cached = <String, bool>{};
    final pending = <String, bool>{};
    controller = StreamController<AccountSnapshot>(
      onListen: () {
        for (final collection in collections) {
          subscriptions.add(
            _watchCollection(account(uid).collection(collection)).listen((
              snapshot,
            ) {
              documents[collection] = {
                for (final doc in snapshot.docs)
                  doc.id: {...doc.data(), 'id': doc.id},
              };
              cached[collection] = snapshot.fromCache;
              pending[collection] = snapshot.pending;
              if (documents.length == collections.length) {
                final archivedChildren = (documents['children'] ?? {}).entries
                    .where((entry) => entry.value['archived'] == true)
                    .map((entry) => entry.key)
                    .toSet();
                controller.add(
                  AccountSnapshot(
                    {
                      for (final entry in documents.entries)
                        entry.key: {
                          for (final doc in entry.value.entries)
                            if (!(entry.key == 'children' &&
                                    archivedChildren.contains(doc.key)) &&
                                !archivedChildren.contains(
                                  doc.value['childId'],
                                ))
                              doc.key: doc.value,
                        },
                    },
                    fromCache: cached.values.any((v) => v),
                    pending: pending.values.any((v) => v),
                  ),
                );
              }
            }, onError: controller.addError),
          );
        }
      },
      onCancel: () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      },
    );
    return controller.stream;
  }

  /// Discover deterministic document-ID ranges in bounded pages, then keep
  /// each disjoint range live. The open tail grows into a new range at 100
  /// documents. Complete household state is retained for medical summaries.
  Stream<_CollectionSnapshot> _watchCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) {
    if (collection.id == 'settings') {
      return collection
          .snapshots(includeMetadataChanges: true)
          .map(
            (snapshot) => _CollectionSnapshot(
              snapshot.docs,
              fromCache: snapshot.metadata.isFromCache,
              pending: snapshot.metadata.hasPendingWrites,
            ),
          );
    }
    const pageSize = 100;
    late StreamController<_CollectionSnapshot> output;
    final subscriptions =
        <int, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>{};
    final pages = <int, QuerySnapshot<Map<String, dynamic>>>{};
    final partitioned = <int>{};
    var tailReady = false;
    var cancelled = false;
    void emit() {
      if (!tailReady || cancelled) return;
      output.add(
        _CollectionSnapshot(
          [for (final page in pages.values) ...page.docs],
          fromCache: pages.values.any((p) => p.metadata.isFromCache),
          pending: pages.values.any((p) => p.metadata.hasPendingWrites),
        ),
      );
    }

    void attach(int page, String? after, {String? end}) {
      Query<Map<String, dynamic>> query = collection.orderBy('id');
      if (after != null) query = query.startAfter([after]);
      query = end == null ? query.limit(pageSize) : query.endAt([end]);
      subscriptions[page] = query.snapshots(includeMetadataChanges: true).listen(
        (snapshot) {
          if (cancelled) return;
          pages[page] = snapshot;
          if (end == null &&
              snapshot.docs.length == pageSize &&
              partitioned.add(page)) {
            // Close this range so inserts/deletes cannot shift page boundaries.
            final boundary = snapshot.docs.last.id;
            tailReady = false;
            final prior = subscriptions.remove(page);
            unawaited(
              Future<void>(() async {
                await prior?.cancel();
                if (cancelled) return;
                attach(page, after, end: boundary);
                attach(page + 1, boundary);
              }),
            );
          } else if (end == null && !partitioned.contains(page)) {
            tailReady = true;
          }
          emit();
        },
        onError: output.addError,
      );
    }

    output = StreamController<_CollectionSnapshot>(
      onListen: () => attach(0, null),
      onCancel: () async {
        cancelled = true;
        for (final subscription in subscriptions.values) {
          await subscription.cancel();
        }
      },
    );
    return output.stream;
  }

  Future<void> applyChanges(
    String uid,
    AccountDocuments before,
    AccountDocuments after,
  ) async {
    validateUid(uid);
    final batch = firestore.batch();
    var writes = 0;
    const equality = DeepCollectionEqualityCompat();
    final archivedChildren = (before['children'] ?? {}).keys
        .where((id) => !(after['children'] ?? {}).containsKey(id))
        .toSet();
    for (final collection in collections) {
      final old = before[collection] ?? {};
      final next = after[collection] ?? {};
      for (final id in old.keys.where((id) => !next.containsKey(id))) {
        if (collection == 'children') {
          // Keep an owned tombstone and its medical relationships. This also
          // safely hides concurrent records without requiring a global scan.
          batch.update(account(uid).collection(collection).doc(id), {
            'archived': true,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          writes++;
        } else if (!archivedChildren.contains(old[id]?['childId'])) {
          batch.delete(account(uid).collection(collection).doc(id));
          writes++;
        }
      }
      for (final entry in next.entries) {
        if (equality.equals(old[entry.key], entry.value)) continue;
        final reference = account(uid).collection(collection).doc(entry.key);
        final value = {
          ...entry.value,
          'ownerUid': uid,
          'schemaVersion': 1,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (old.containsKey(entry.key)) {
          batch.update(reference, value);
        } else {
          batch.set(reference, {
            ...value,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        writes++;
      }
    }
    if (writes > 450) throw StateError('Too many changes in one save.');
    if (writes != 0) await batch.commit();
  }
}

class DeepCollectionEqualityCompat {
  const DeepCollectionEqualityCompat();
  bool equals(dynamic a, dynamic b) {
    if (a is Map && b is Map) {
      return a.length == b.length &&
          a.keys.every((key) => b.containsKey(key) && equals(a[key], b[key]));
    }
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (!equals(a[i], b[i])) return false;
      }
      return true;
    }
    return a == b;
  }
}

class _CollectionSnapshot {
  const _CollectionSnapshot(
    this.docs, {
    required this.fromCache,
    required this.pending,
  });
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
  final bool fromCache;
  final bool pending;
}
