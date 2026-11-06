import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app/root.dart';
import 'core/theme/app_theme.dart';
import 'core/firebase/firebase_initializer.dart';
import 'core/firebase/firestore_provider.dart';
import 'data/repositories/account_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'state/smartvax_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final app = await FirebaseInitializer.initialize();
    final repository = AccountRepository(FirestoreProvider.create(app));
    final firebaseAuth = FirebaseAuth.instanceFor(app: app);
    if (firebaseAuth.app.name != app.name ||
        firebaseAuth.app.options.appId != app.options.appId) {
      throw StateError('Firebase Auth app mismatch');
    }
    final auth = AuthRepository(firebaseAuth);
    runApp(
      SmartVaxRoot(
        controller: SmartVaxController(
          authRepository: auth,
          accountRepository: repository,
        ),
      ),
    );
  } catch (error) {
    debugPrint('SmartVax initialization failed (${error.runtimeType})');
    runApp(
      MaterialApp(
        title: 'SmartVax',
        theme: buildTheme(),
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 48),
                const Text('Unable to initialize the application'),
                const Text('Check application configuration and connection.'),
                TextButton(onPressed: main, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
