// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


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
    apiKey: 'AIzaSyDlISw9Omgjk3rsfw0ad-EqrBhLaCJiaME',
    appId: '1:888225267212:web:f2f4ea1e1479b9ee2af829',
    messagingSenderId: '888225267212',
    projectId: 'pawpartnerdevelopment',
    authDomain: 'pawpartnerdevelopment.firebaseapp.com',
    storageBucket: 'pawpartnerdevelopment.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBMi4wzOgZ2Lno1K93n0Fs4IKofs1h0jo0',
    appId: '1:888225267212:android:55f65299950a38122af829',
    messagingSenderId: '888225267212',
    projectId: 'pawpartnerdevelopment',
    storageBucket: 'pawpartnerdevelopment.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBPY-O2MZPBoXwQPcA4VIih0nrpmYyLEUc',
    appId: '1:888225267212:ios:ccf85fc768ff0bd62af829',
    messagingSenderId: '888225267212',
    projectId: 'pawpartnerdevelopment',
    storageBucket: 'pawpartnerdevelopment.appspot.com',
    iosBundleId: 'com.example.shelterPartner',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBPY-O2MZPBoXwQPcA4VIih0nrpmYyLEUc',
    appId: '1:888225267212:ios:ccf85fc768ff0bd62af829',
    messagingSenderId: '888225267212',
    projectId: 'pawpartnerdevelopment',
    storageBucket: 'pawpartnerdevelopment.appspot.com',
    iosBundleId: 'com.example.shelterPartner',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDlISw9Omgjk3rsfw0ad-EqrBhLaCJiaME',
    appId: '1:888225267212:web:69f45053224282872af829',
    messagingSenderId: '888225267212',
    projectId: 'pawpartnerdevelopment',
    authDomain: 'pawpartnerdevelopment.firebaseapp.com',
    storageBucket: 'pawpartnerdevelopment.appspot.com',
  );
}
