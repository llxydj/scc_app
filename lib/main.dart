import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'core/services/notification_service.dart';
import 'core/services/sample_data_service.dart';
import 'core/services/analytics_service.dart';
import 'core/config/firebase_config.dart';

// Note: For firebase_options.dart support, users should generate it via:
// dart pub global activate flutterfire_cli
// flutterfire configure
// Then uncomment the import below and use DefaultFirebaseOptions as fallback

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('Environment variables loaded from .env');
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
    debugPrint('Falling back to firebase_options.dart if available');
  }
  
  // Initialize Firebase
  try {
    // Priority 1: Try to use secure environment variables from .env
    try {
      SecureFirebaseOptions.validate();
      await Firebase.initializeApp(
        options: SecureFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully from environment variables');
    } catch (envError) {
      // Priority 2: Try without options (will use platform config files like google-services.json)
      // This works if Firebase is configured via platform-specific config files
      try {
        await Firebase.initializeApp();
        debugPrint('Firebase initialized using platform config files (google-services.json/GoogleService-Info.plist)');
        debugPrint('Note: Consider using .env file for better security in production');
      } catch (platformError) {
        // Firebase not configured at all
        debugPrint('Firebase initialization failed: $platformError');
        debugPrint('Note: Set up Firebase using one of these methods:');
        debugPrint('  1. Create .env file with Firebase credentials (recommended)');
        debugPrint('  2. Run "flutterfire configure" to generate firebase_options.dart');
        debugPrint('  3. Add google-services.json (Android) or GoogleService-Info.plist (iOS)');
      }
    }
  } catch (e) {
    // Firebase might not be configured, continue without it
    debugPrint('Firebase initialization error: $e');
    debugPrint('App will continue without Firebase features');
  }
  
  // Initialize sample data (badges, sample questions)
  try {
    final sampleDataService = SampleDataService();
    await sampleDataService.initializeSampleData();
  } catch (e) {
    debugPrint('Sample data initialization error: $e');
  }
  
  // Initialize analytics service
  try {
    await AnalyticsService().initialize();
  } catch (e) {
    debugPrint('Analytics initialization error: $e');
  }
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
