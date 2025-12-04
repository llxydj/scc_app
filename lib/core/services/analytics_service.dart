import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics? _analytics;

  Future<void> initialize() async {
    try {
      _analytics = FirebaseAnalytics.instance;
    } catch (e) {
      debugPrint('Analytics initialization failed: $e');
    }
  }

  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    try {
      await _analytics?.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      debugPrint('Analytics log failed: $e');
    }
  }

  Future<void> logLogin(String loginMethod) async {
    await logEvent('login', {'method': loginMethod});
  }

  Future<void> logQuizStarted(String subject, int gradeLevel) async {
    await logEvent('quiz_started', {
      'subject': subject,
      'grade_level': gradeLevel,
    });
  }

  Future<void> logQuizCompleted(String subject, int score, int total) async {
    await logEvent('quiz_completed', {
      'subject': subject,
      'score': score,
      'total': total,
      'percentage': (score / total * 100).round(),
    });
  }

  Future<void> logBadgeUnlocked(String badgeName) async {
    await logEvent('badge_unlocked', {'badge_name': badgeName});
  }

  Future<void> logContentCreated(String contentType) async {
    await logEvent('content_created', {'content_type': contentType});
  }

  Future<void> logFileUploaded(String fileType, int itemCount) async {
    await logEvent('file_uploaded', {
      'file_type': fileType,
      'item_count': itemCount,
    });
  }

  Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics?.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('Set user property failed: $e');
    }
  }
}

