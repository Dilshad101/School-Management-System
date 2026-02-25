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
    apiKey: 'AIzaSyBNRgI3Bu9m66Xx9NWvaUI_vntiay0ZZS8',
    appId: '1:986005050127:web:7a8646c49a9b437671247a',
    messagingSenderId: '986005050127',
    projectId: 'waad-8dd52',
    authDomain: 'waad-8dd52.firebaseapp.com',
    storageBucket: 'waad-8dd52.firebasestorage.app',
    measurementId: 'G-70MCJK5VL6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCV-Z5ZiCMwyfnANyLTfQUWefzKCReCHlI',
    appId: '1:986005050127:android:fc2d0d877a21717771247a',
    messagingSenderId: '986005050127',
    projectId: 'waad-8dd52',
    storageBucket: 'waad-8dd52.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBAgFrcRX8G7BCMagMMfjE-Epu7K94CpU4',
    appId: '1:986005050127:ios:2c92f676d8a4ad9c71247a',
    messagingSenderId: '986005050127',
    projectId: 'waad-8dd52',
    storageBucket: 'waad-8dd52.firebasestorage.app',
    iosBundleId: 'com.waad.schoolManagementSystem',
  );

  // TODO: Add macOS configuration when needed
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: '986005050127',
    projectId: 'waad-8dd52',
    storageBucket: 'waad-8dd52.firebasestorage.app',
    iosBundleId: 'com.waad.schoolManagementSystem',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBNRgI3Bu9m66Xx9NWvaUI_vntiay0ZZS8',
    appId: '1:986005050127:web:7a8646c49a9b437671247a',
    messagingSenderId: '986005050127',
    projectId: 'waad-8dd52',
    authDomain: 'waad-8dd52.firebaseapp.com',
    storageBucket: 'waad-8dd52.firebasestorage.app',
    measurementId: 'G-70MCJK5VL6',
  );
}
