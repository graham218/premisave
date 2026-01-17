import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // You can add support for web/macOS later if needed
    return android; // or ios depending on platform
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    appId: '1:1234567890:android:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'premisave-flutter',
    storageBucket: 'premisave-flutter.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyYYYYYYYYYYYYYYYYYYYYYYYYYYYYY',
    appId: '1:1234567890:ios:abcdef1234567890',
    messagingSenderId: '1234567890',
    projectId: 'premisave-flutter',
    storageBucket: 'premisave-flutter.appspot.com',
    iosBundleId: 'com.premisave.premisaveFlutter',
  );
}