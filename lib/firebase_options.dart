import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'This app targets Android. Web is not configured.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are only configured for Android.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAIaEJ1T9aylf7he74lqSPNgW0xIcAJUzw',
    appId: '1:412392186753:android:be84fb4a996dd42721fe80',
    messagingSenderId: '412392186753',
    projectId: 'campus-incident-reporter-lisa',
    storageBucket: 'campus-incident-reporter-lisa.firebasestorage.app',
  );
}
