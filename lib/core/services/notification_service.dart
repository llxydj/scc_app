import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../data/local/database_helper.dart';
import '../../core/services/auth_service.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final AuthService _authService = AuthService();

  Future<void> initialize() async {
    try {
      // Request permission
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get token
      String? token = await _fcm.getToken();
      if (token != null) {
        // Save token to database
        await _saveFCMToken(token);
        debugPrint('FCM Token: $token');
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final context = navigatorKey.currentContext;
        if (context != null) {
          showInAppAlert(
            context,
            message.notification?.title ?? 'Notification',
            message.notification?.body ?? '',
          );
        }
      });

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // Handle navigation
      });
    } catch (e) {
      // Firebase might not be configured, continue without notifications
      debugPrint('FCM initialization error: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  void showInAppAlert(
    BuildContext context,
    String title,
    String message, {
    String? action,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 5),
        action: action != null && onAction != null
            ? SnackBarAction(
                label: action,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }

  Future<void> _saveFCMToken(String token) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        final db = await _dbHelper.database;
        await db.update(
          'users',
          {
            'fcm_token': token,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [user.id],
        );
      }
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }
}

