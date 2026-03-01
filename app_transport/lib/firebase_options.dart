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
    apiKey: 'AIzaSyBZKOH97aKwLTOyqI4PT5dR54rgG2N4udw',
    appId: '1:83204859004:web:xxxxxxxxxxxxxxxx',
    messagingSenderId: '83204859004',
    projectId: 'transit-app-307ac',
    authDomain: 'transit-app-307ac.firebaseapp.com',
    storageBucket: 'transit-app-307ac.firebasestorage.app',
    databaseURL: 'https://transit-app-307ac-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBZKOH97aKwLTOyqI4PT5dR54rgG2N4udw',
    appId: '1:83204859004:android:d96f126d7228f17071d5f9',
    messagingSenderId: '83204859004',
    projectId: 'transit-app-307ac',
    storageBucket: 'transit-app-307ac.firebasestorage.app',
    databaseURL: 'https://transit-app-307ac-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBZKOH97aKwLTOyqI4PT5dR54rgG2N4udw',
    appId: '1:83204859004:ios:xxxxxxxxxxxxxxxx',
    messagingSenderId: '83204859004',
    projectId: 'transit-app-307ac',
    storageBucket: 'transit-app-307ac.firebasestorage.app',
    databaseURL: 'https://transit-app-307ac-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBZKOH97aKwLTOyqI4PT5dR54rgG2N4udw',
    appId: '1:83204859004:ios:xxxxxxxxxxxxxxxx',
    messagingSenderId: '83204859004',
    projectId: 'transit-app-307ac',
    storageBucket: 'transit-app-307ac.firebasestorage.app',
    databaseURL: 'https://transit-app-307ac-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBZKOH97aKwLTOyqI4PT5dR54rgG2N4udw',
    appId: '1:83204859004:windows:xxxxxxxxxxxxxxxx',
    messagingSenderId: '83204859004',
    projectId: 'transit-app-307ac',
    storageBucket: 'transit-app-307ac.firebasestorage.app',
    databaseURL: 'https://transit-app-307ac-default-rtdb.firebaseio.com',
  );
}
