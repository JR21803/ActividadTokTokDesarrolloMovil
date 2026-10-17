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
    apiKey: 'AIzaSyDYjwpjiunvRFForNNHrw2nvzm9aw47a7A',
    appId: '1:730917719105:web:6145b8d70556132532cac0',
    messagingSenderId: '730917719105',
    projectId: 'toktok-bc09f',
    authDomain: 'toktok-bc09f.firebaseapp.com',
    storageBucket: 'toktok-bc09f.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCRUUWxYOfFk60TNbjH8WmJ7GE3iigs1q4',
    appId: '1:730917719105:android:80e9fc376d1fabac32cac0',
    messagingSenderId: '730917719105',
    projectId: 'toktok-bc09f',
    storageBucket: 'toktok-bc09f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAdXmIkmS5KH1cQ_TYtceMWHNbmv9t_-aY',
    appId: '1:730917719105:ios:ce6aafb38279126032cac0',
    messagingSenderId: '730917719105',
    projectId: 'toktok-bc09f',
    storageBucket: 'toktok-bc09f.firebasestorage.app',
    iosClientId: '730917719105-nf3c6rhq0qrjv13q921ufohq55clco1n.apps.googleusercontent.com',
    iosBundleId: 'com.example.toktok',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAdXmIkmS5KH1cQ_TYtceMWHNbmv9t_-aY',
    appId: '1:730917719105:ios:ce6aafb38279126032cac0',
    messagingSenderId: '730917719105',
    projectId: 'toktok-bc09f',
    storageBucket: 'toktok-bc09f.firebasestorage.app',
    iosClientId: '730917719105-nf3c6rhq0qrjv13q921ufohq55clco1n.apps.googleusercontent.com',
    iosBundleId: 'com.example.toktok',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDYjwpjiunvRFForNNHrw2nvzm9aw47a7A',
    appId: '1:730917719105:web:0f32598a43e3623f32cac0',
    messagingSenderId: '730917719105',
    projectId: 'toktok-bc09f',
    authDomain: 'toktok-bc09f.firebaseapp.com',
    storageBucket: 'toktok-bc09f.firebasestorage.app',
  );
}
