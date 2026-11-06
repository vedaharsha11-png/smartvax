import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreProvider {
  static const projectId = 'smartvax-e3956';
  static const databaseId = 'smartvax';
  static FirebaseFirestore create(FirebaseApp app) {
    if (app.options.projectId != projectId) {
      throw StateError('Unexpected Firebase project');
    }
    final firestore = FirebaseFirestore.instanceFor(
      app: app,
      databaseId: databaseId,
    );
    // Child health data is never retained on disk across account changes.
    // Memory cache still supports queued writes while this process is alive.
    firestore.settings = const Settings(persistenceEnabled: false);
    return firestore;
  }
}
