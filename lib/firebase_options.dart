// File generated manually from Firebase Console config
// (google-services.json / GoogleService-Info.plist), following the same
// structure produced by `flutterfire configure`. Only android and ios are
// populated — web/macos/windows/linux are out of scope for the MVP
// (ver docs/project/decisions.md DECISION-002).
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'web is out of scope for the MVP (DECISION-002).',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for '
          '$defaultTargetPlatform - only android and ios are supported '
          'in the MVP (DECISION-002).',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD1RL_PzTDrvMjwu7iLPVrW0v0GYquVPNU',
    appId: '1:803175500602:android:f9639ce0144e41f78bde03',
    messagingSenderId: '803175500602',
    projectId: 'lequinthotel-ca6ef',
    storageBucket: 'lequinthotel-ca6ef.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBdQzag7l-IDis72XiT4KTIsLfNUaf6tmc',
    appId: '1:803175500602:ios:bcfa244673127f4b8bde03',
    messagingSenderId: '803175500602',
    projectId: 'lequinthotel-ca6ef',
    storageBucket: 'lequinthotel-ca6ef.firebasestorage.app',
    iosBundleId: 'com.lequint.lequintmobile',
    iosClientId:
        '803175500602-njujt6uih4k27jvesmolm6kugm9dc6ob.apps.googleusercontent.com',
  );
}
