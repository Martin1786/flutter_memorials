// File generated by FlutterFire CLI.
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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyDFu3ZLKsrvphGy1XT-SVGw2bGlwMs9I-U',
    appId: '1:197148401217:web:23b17bab1b059fb86a30c0',
    messagingSenderId: '197148401217',
    projectId: 'memorials-adc74',
    authDomain: 'memorials-adc74.firebaseapp.com',
    storageBucket: 'memorials-adc74.firebasestorage.app',
    measurementId: 'G-XYGKSZDVD8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyARL7aJYwUz5F9r21prJu6pGBccNeEZ_7o',
    appId: '1:197148401217:android:23de2aef26d5c7a86a30c0',
    messagingSenderId: '197148401217',
    projectId: 'memorials-adc74',
    storageBucket: 'memorials-adc74.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDFu3ZLKsrvphGy1XT-SVGw2bGlwMs9I-U',
    appId: '1:197148401217:web:6699ca05d5a359366a30c0',
    messagingSenderId: '197148401217',
    projectId: 'memorials-adc74',
    authDomain: 'memorials-adc74.firebaseapp.com',
    storageBucket: 'memorials-adc74.firebasestorage.app',
    measurementId: 'G-D7FTNW5H2M',
  );
}
