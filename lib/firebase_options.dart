// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyANqviJHZLJ-sdRsBAA-aN55M0zJtZ2VdQ',
    appId: '1:196290393572:web:ee22f4b095ce3baad943f1',
    messagingSenderId: '196290393572',
    projectId: 'sigongan-3f44b',
    authDomain: 'sigongan-3f44b.firebaseapp.com',
    databaseURL: 'https://sigongan-3f44b-default-rtdb.firebaseio.com',
    storageBucket: 'sigongan-3f44b.appspot.com',
    measurementId: 'G-VF8H94QX76',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCj3uibAPbfnKPnBeaZLbAjSK4b-AX2rcE',
    appId: '1:196290393572:android:f7f4478705d31fb7d943f1',
    messagingSenderId: '196290393572',
    projectId: 'sigongan-3f44b',
    databaseURL: 'https://sigongan-3f44b-default-rtdb.firebaseio.com',
    storageBucket: 'sigongan-3f44b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBC0JXPFzBOOaP8-C-w2R5Luyz3RROYrz4',
    appId: '1:196290393572:ios:4bc683d2776c41e0d943f1',
    messagingSenderId: '196290393572',
    projectId: 'sigongan-3f44b',
    databaseURL: 'https://sigongan-3f44b-default-rtdb.firebaseio.com',
    storageBucket: 'sigongan-3f44b.appspot.com',
    iosClientId:
        '196290393572-ckopb2h8q1lc8cbika952rn29qsr4t21.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterFirebase',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBC0JXPFzBOOaP8-C-w2R5Luyz3RROYrz4',
    appId: '1:196290393572:ios:4bc683d2776c41e0d943f1',
    messagingSenderId: '196290393572',
    projectId: 'sigongan-3f44b',
    databaseURL: 'https://sigongan-3f44b-default-rtdb.firebaseio.com',
    storageBucket: 'sigongan-3f44b.appspot.com',
    iosClientId:
        '196290393572-ckopb2h8q1lc8cbika952rn29qsr4t21.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterFirebase',
  );
}
