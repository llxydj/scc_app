import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../data/local/database_helper.dart';
import '../../data/models/activity_log_model.dart';
import '../utils/device_info.dart';

class ActivityLogService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> logEvent({
    required String userId,
    String? quizId,
    required String eventType,
    Map<String, dynamic>? eventData,
  }) async {
    try {
      final db = await _dbHelper.database;
      final deviceInfo = await DeviceInfo.getDeviceInfo();
      
      final logData = {
        'user_id': userId,
        'quiz_id': quizId,
        'event_type': eventType,
        'event_data': eventData != null ? jsonEncode({
          ...eventData,
          'device_model': deviceInfo['model'],
          'os_version': deviceInfo['osVersion'],
        }) : jsonEncode({
          'device_model': deviceInfo['model'],
          'os_version': deviceInfo['osVersion'],
        }),
        'timestamp': DateTime.now().toIso8601String(),
        'is_synced': 0,
      };

      await db.insert('activity_logs', logData);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<List<ActivityLog>> getLogsForQuiz(String userId, String quizId) async {
    try {
      final db = await _dbHelper.database;
      final logs = await db.query(
        'activity_logs',
        where: 'user_id = ? AND quiz_id = ?',
        whereArgs: [userId, quizId],
        orderBy: 'timestamp ASC',
      );

      return logs.map((data) {
        return ActivityLog(
          id: data['id'] as int?,
          userId: data['user_id'] as String,
          quizId: data['quiz_id'] as String?,
          eventType: data['event_type'] as String,
          eventData: data['event_data'] != null
              ? Map<String, dynamic>.from(
                  jsonDecode(data['event_data'] as String) as Map)
              : null,
          timestamp: DateTime.parse(data['timestamp'] as String),
          isSynced: data['is_synced'] as int? ?? 0,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}

