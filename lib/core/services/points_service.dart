import 'package:sqflite/sqflite.dart';
import '../data/local/database_helper.dart';
import '../data/models/user_model.dart';
import '../data/models/badge_model.dart';
import 'analytics_service.dart';
import 'package:uuid/uuid.dart';

class PointsService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  // Calculate points for quiz
  int calculateQuizPoints({required int score, required int total}) {
    int points = score * 10; // 10 points per correct answer
    
    // Perfect score bonus
    if (score == total) {
      points += 100;
    }
    
    // Streak bonus (calculated separately)
    return points;
  }

  // Award points to user
  Future<void> awardPoints(String userId, int points) async {
    try {
      final db = await _dbHelper.database;
      
      // Get current user
      final users = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (users.isEmpty) return;

      final currentPoints = users.first['points'] as int? ?? 0;
      final newPoints = currentPoints + points;

      await db.update(
        'users',
        {
          'points': newPoints,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );

      // Check for badge unlocks
      await _checkBadgeUnlocks(userId, newPoints);
    } catch (e) {
      // Handle error silently or log
    }
  }

  // Update streak
  Future<void> updateStreak(String userId) async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now();
      
      final users = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (users.isEmpty) return;

      final lastActiveDate = users.first['last_active_date'] != null
          ? DateTime.parse(users.first['last_active_date'] as String)
          : null;
      final currentStreak = users.first['streak'] as int? ?? 0;

      int newStreak = currentStreak;

      if (lastActiveDate == null) {
        // First time
        newStreak = 1;
      } else {
        final daysDifference = now.difference(lastActiveDate).inDays;
        if (daysDifference == 0) {
          // Same day, keep streak
          newStreak = currentStreak;
        } else if (daysDifference == 1) {
          // Consecutive day
          newStreak = currentStreak + 1;
        } else {
          // Streak broken
          newStreak = 1;
        }
      }

      await db.update(
        'users',
        {
          'streak': newStreak,
          'last_active_date': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );

      // Check for streak badge unlocks
      await _checkStreakBadges(userId, newStreak);
    } catch (e) {
      // Handle error
    }
  }

  // Check for badge unlocks based on points
  Future<void> _checkBadgeUnlocks(String userId, int totalPoints) async {
    try {
      final db = await _dbHelper.database;
      
      // Get all badges with point requirements
      final badges = await db.query(
        'badges',
        where: 'requirement_type = ? AND requirement_value <= ?',
        whereArgs: ['points', totalPoints],
      );

      for (final badgeData in badges) {
        final badgeId = badgeData['id'] as String;
        
        // Check if user already has this badge
        final existing = await db.query(
          'user_badges',
          where: 'user_id = ? AND badge_id = ?',
          whereArgs: [userId, badgeId],
        );

        if (existing.isEmpty) {
          // Unlock badge
          await db.insert('user_badges', {
            'user_id': userId,
            'badge_id': badgeId,
            'unlocked_at': DateTime.now().toIso8601String(),
            'is_synced': 0,
          });
          
          // Log badge unlock for analytics
          try {
            final badgeData = await db.query('badges', where: 'id = ?', whereArgs: [badgeId], limit: 1);
            if (badgeData.isNotEmpty) {
              final badgeName = badgeData.first['name'] as String;
              await AnalyticsService().logBadgeUnlocked(badgeName);
            }
          } catch (e) {
            // Ignore analytics errors
          }
        }
      }
    } catch (e) {
      // Handle error
    }
  }

  // Check for streak badge unlocks
  Future<void> _checkStreakBadges(String userId, int streak) async {
    try {
      final db = await _dbHelper.database;
      
      final badges = await db.query(
        'badges',
        where: 'requirement_type = ? AND requirement_value <= ?',
        whereArgs: ['streak', streak],
      );

      for (final badgeData in badges) {
        final badgeId = badgeData['id'] as String;
        
        final existing = await db.query(
          'user_badges',
          where: 'user_id = ? AND badge_id = ?',
          whereArgs: [userId, badgeId],
        );

        if (existing.isEmpty) {
          await db.insert('user_badges', {
            'user_id': userId,
            'badge_id': badgeId,
            'unlocked_at': DateTime.now().toIso8601String(),
            'is_synced': 0,
          });
        }
      }
    } catch (e) {
      // Handle error
    }
  }

  // Get user badges
  Future<List<Badge>> getUserBadges(String userId) async {
    try {
      final db = await _dbHelper.database;
      
      final userBadges = await db.rawQuery('''
        SELECT b.* FROM badges b
        INNER JOIN user_badges ub ON b.id = ub.badge_id
        WHERE ub.user_id = ?
        ORDER BY ub.unlocked_at DESC
      ''', [userId]);

      return userBadges.map((data) => Badge.fromJson(Map<String, dynamic>.from(data))).toList();
    } catch (e) {
      return [];
    }
  }
}

