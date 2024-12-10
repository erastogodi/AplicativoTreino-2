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
        return ios;
      case TargetPlatform.macOS:
        return macos;
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
    apiKey: 'AIzaSyDow4SemQzYdQXj8d_KiuZEgyA8ACmkmxw',
    appId: '1:828444205123:web:0a7080041a36d281d234f6',
    messagingSenderId: '828444205123',
    projectId: 'fusionfitness-bf17d',
    authDomain: 'fusionfitness-bf17d.firebaseapp.com',
    storageBucket: 'fusionfitness-bf17d.firebasestorage.app',
    measurementId: 'G-RW8B6WMY3K',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAhXiM-iBzrLxpLyfzldroJRzscctGhvfU',
    appId: '1:828444205123:android:b7c3d7e5d65ad9f5d234f6',
    messagingSenderId: '828444205123',
    projectId: 'fusionfitness-bf17d',
    storageBucket: 'fusionfitness-bf17d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCaHdy1hPmRPxGPu8GLHymdrAG6Z7txNvY',
    appId: '1:828444205123:ios:7d575b68c9fa2c2cd234f6',
    messagingSenderId: '828444205123',
    projectId: 'fusionfitness-bf17d',
    storageBucket: 'fusionfitness-bf17d.firebasestorage.app',
    iosBundleId: 'com.example.treinoApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCaHdy1hPmRPxGPu8GLHymdrAG6Z7txNvY',
    appId: '1:828444205123:ios:7d575b68c9fa2c2cd234f6',
    messagingSenderId: '828444205123',
    projectId: 'fusionfitness-bf17d',
    storageBucket: 'fusionfitness-bf17d.firebasestorage.app',
    iosBundleId: 'com.example.treinoApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDow4SemQzYdQXj8d_KiuZEgyA8ACmkmxw',
    appId: '1:828444205123:web:595836f8bfeb686bd234f6',
    messagingSenderId: '828444205123',
    projectId: 'fusionfitness-bf17d',
    authDomain: 'fusionfitness-bf17d.firebaseapp.com',
    storageBucket: 'fusionfitness-bf17d.firebasestorage.app',
    measurementId: 'G-1J6RNVQV2J',
  );
}