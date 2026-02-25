import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Placeholder Firebase options for Phase 2 wiring.
///
/// Replace this file by running:
/// `flutterfire configure --project=q4-board-prod`
/// and commit the generated `lib/firebase_options.dart`.
class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBnEZWP70yCDPM3ONchf9xeyPosIP42JAk',
    appId: '1:958578639713:web:42bd1e8cd574e3c8e9bb20',
    messagingSenderId: '958578639713',
    projectId: 'q4-board-prod',
    authDomain: 'q4-board-prod.firebaseapp.com',
    storageBucket: 'q4-board-prod.firebasestorage.app',
    measurementId: 'G-MKGE8YDZZ8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDum1DVgECpwQpAox4gsMUmtlSaiiX_D7s',
    appId: '1:958578639713:android:fbe5cdd83f53a299e9bb20',
    messagingSenderId: '958578639713',
    projectId: 'q4-board-prod',
    storageBucket: 'q4-board-prod.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FLUTTERFIRE_IOS_API_KEY',
    appId: 'REPLACE_WITH_FLUTTERFIRE_IOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_FLUTTERFIRE_SENDER_ID',
    projectId: 'q4-board-prod',
    storageBucket: 'REPLACE_WITH_FLUTTERFIRE_STORAGE_BUCKET',
    iosBundleId: 'dev.abdallahgaber.q4board',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBGxE62c9WJVpCoF8UU2Uxygn5r4ZliUUI',
    appId: '1:958578639713:ios:c86f4489bc2820dce9bb20',
    messagingSenderId: '958578639713',
    projectId: 'q4-board-prod',
    storageBucket: 'q4-board-prod.firebasestorage.app',
    androidClientId: '958578639713-n204uilj0evi6dbaiqcoagjncur8fpkv.apps.googleusercontent.com',
    iosClientId: '958578639713-rlj1tvsp3kv84c7qg32npfhe7qj6qqbf.apps.googleusercontent.com',
    iosBundleId: 'dev.abdallahgaber.q4board',
  );

}