// File generated by FlutterFire CLI.
// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  static const String _appIdKey = "APP_ID";
  static const String _iosApiKey = "IOS_API_KEY";
  static const String _androidApiKey = "ANDROID_API_KEY";
  static FirebaseOptions currentPlatform() {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android(
          apiKey: dotenv.get(_androidApiKey),
          appId: dotenv.get(
            _appIdKey,
          ),
        );
      case TargetPlatform.iOS:
        return ios(
          apiKey: dotenv.get(_iosApiKey),
          appId: dotenv.get(
            _appIdKey,
          ),
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions android(
          {required String apiKey, required String appId}) =>
      FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: '224943458926',
        projectId: 'bestwaytoproceed',
        storageBucket: 'bestwaytoproceed.appspot.com',
      );

  static FirebaseOptions ios({required String apiKey, required String appId}) =>
      FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: '224943458926',
        projectId: 'bestwaytoproceed',
        storageBucket: 'bestwaytoproceed.appspot.com',
        iosBundleId: 'com.example.bestwaytoproceedfront',
      );
}
