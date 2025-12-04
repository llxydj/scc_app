import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Secure Firebase configuration loaded from environment variables
/// 
/// This class reads Firebase configuration from .env file instead of
/// hardcoding API keys in the source code.
/// 
/// To use:
/// 1. Copy env.template to .env
/// 2. Fill in your Firebase credentials
/// 3. Load .env in main.dart before using this class
class SecureFirebaseOptions {
  /// Get Firebase options for the current platform
  /// 
  /// Reads from environment variables set in .env file
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
          'SecureFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'SecureFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Web Firebase configuration from environment variables
  static FirebaseOptions get web {
    return FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_WEB_API_KEY'] ?? '',
      appId: dotenv.env['FIREBASE_WEB_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['FIREBASE_WEB_MESSAGING_SENDER_ID'] ?? '',
      projectId: dotenv.env['FIREBASE_WEB_PROJECT_ID'] ?? '',
      authDomain: dotenv.env['FIREBASE_WEB_AUTH_DOMAIN'] ?? '',
      storageBucket: dotenv.env['FIREBASE_WEB_STORAGE_BUCKET'] ?? '',
      measurementId: dotenv.env['FIREBASE_WEB_MEASUREMENT_ID'],
    );
  }

  /// Android Firebase configuration from environment variables
  static FirebaseOptions get android {
    return FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '',
      appId: dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['FIREBASE_ANDROID_MESSAGING_SENDER_ID'] ?? '',
      projectId: dotenv.env['FIREBASE_ANDROID_PROJECT_ID'] ?? '',
      storageBucket: dotenv.env['FIREBASE_ANDROID_STORAGE_BUCKET'] ?? '',
    );
  }

  /// iOS Firebase configuration from environment variables
  static FirebaseOptions get ios {
    return FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_IOS_API_KEY'] ?? '',
      appId: dotenv.env['FIREBASE_IOS_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['FIREBASE_IOS_MESSAGING_SENDER_ID'] ?? '',
      projectId: dotenv.env['FIREBASE_IOS_PROJECT_ID'] ?? '',
      storageBucket: dotenv.env['FIREBASE_IOS_STORAGE_BUCKET'] ?? '',
      iosBundleId: dotenv.env['FIREBASE_IOS_BUNDLE_ID'],
    );
  }

  /// macOS Firebase configuration from environment variables
  static FirebaseOptions get macos {
    return FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_MACOS_API_KEY'] ?? dotenv.env['FIREBASE_IOS_API_KEY'] ?? '',
      appId: dotenv.env['FIREBASE_MACOS_APP_ID'] ?? dotenv.env['FIREBASE_IOS_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['FIREBASE_MACOS_MESSAGING_SENDER_ID'] ?? dotenv.env['FIREBASE_IOS_MESSAGING_SENDER_ID'] ?? '',
      projectId: dotenv.env['FIREBASE_MACOS_PROJECT_ID'] ?? dotenv.env['FIREBASE_IOS_PROJECT_ID'] ?? '',
      storageBucket: dotenv.env['FIREBASE_MACOS_STORAGE_BUCKET'] ?? dotenv.env['FIREBASE_IOS_STORAGE_BUCKET'] ?? '',
      iosBundleId: dotenv.env['FIREBASE_MACOS_BUNDLE_ID'] ?? dotenv.env['FIREBASE_IOS_BUNDLE_ID'],
    );
  }

  /// Windows Firebase configuration from environment variables
  static FirebaseOptions get windows {
    return FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_WINDOWS_API_KEY'] ?? dotenv.env['FIREBASE_WEB_API_KEY'] ?? '',
      appId: dotenv.env['FIREBASE_WINDOWS_APP_ID'] ?? dotenv.env['FIREBASE_WEB_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['FIREBASE_WINDOWS_MESSAGING_SENDER_ID'] ?? dotenv.env['FIREBASE_WEB_MESSAGING_SENDER_ID'] ?? '',
      projectId: dotenv.env['FIREBASE_WINDOWS_PROJECT_ID'] ?? dotenv.env['FIREBASE_WEB_PROJECT_ID'] ?? '',
      authDomain: dotenv.env['FIREBASE_WINDOWS_AUTH_DOMAIN'] ?? dotenv.env['FIREBASE_WEB_AUTH_DOMAIN'] ?? '',
      storageBucket: dotenv.env['FIREBASE_WINDOWS_STORAGE_BUCKET'] ?? dotenv.env['FIREBASE_WEB_STORAGE_BUCKET'] ?? '',
      measurementId: dotenv.env['FIREBASE_WINDOWS_MEASUREMENT_ID'] ?? dotenv.env['FIREBASE_WEB_MEASUREMENT_ID'],
    );
  }

  /// Validate that all required environment variables are set
  /// 
  /// Throws an exception if critical values are missing
  static void validate() {
    final platform = kIsWeb 
        ? 'web' 
        : defaultTargetPlatform.toString().split('.').last.toLowerCase();
    
    final requiredKeys = <String>[];
    
    if (kIsWeb || platform == 'windows') {
      requiredKeys.addAll([
        'FIREBASE_WEB_API_KEY',
        'FIREBASE_WEB_APP_ID',
        'FIREBASE_WEB_PROJECT_ID',
      ]);
    } else if (platform == 'android') {
      requiredKeys.addAll([
        'FIREBASE_ANDROID_API_KEY',
        'FIREBASE_ANDROID_APP_ID',
        'FIREBASE_ANDROID_PROJECT_ID',
      ]);
    } else if (platform == 'ios' || platform == 'macos') {
      requiredKeys.addAll([
        'FIREBASE_IOS_API_KEY',
        'FIREBASE_IOS_APP_ID',
        'FIREBASE_IOS_PROJECT_ID',
      ]);
    }
    
    final missingKeys = requiredKeys.where((key) {
      final value = dotenv.env[key];
      return value == null || value.isEmpty || value.contains('your_');
    }).toList();
    
    if (missingKeys.isNotEmpty) {
      throw Exception(
        'Missing required Firebase environment variables for $platform: '
        '${missingKeys.join(", ")}\n'
        'Please copy env.template to .env and fill in your Firebase credentials.',
      );
    }
  }
}

