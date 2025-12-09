import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../data/local/database_helper.dart';

class QuizProgress {
  final String id;
  final String userId;
  final String quizId;
  final String subject;
  final int currentQuestionIndex;
  final List<String> selectedAnswers;
  final int score;
  final int elapsedSeconds;
  final DateTime lastSavedAt;

  QuizProgress({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.subject,
    required this.currentQuestionIndex,
    required this.selectedAnswers,
    required this.score,
    required this.elapsedSeconds,
    required this.lastSavedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'quiz_id': quizId,
        'subject': subject,
        'current_question_index': currentQuestionIndex,
        'selected_answers': jsonEncode(selectedAnswers),
        'score': score,
        'elapsed_seconds': elapsedSeconds,
        'last_saved_at': lastSavedAt.toIso8601String(),
      };

  factory QuizProgress.fromJson(Map<String, dynamic> json) => QuizProgress(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        quizId: json['quiz_id'] as String,
        subject: json['subject'] as String,
        currentQuestionIndex: json['current_question_index'] as int,
        selectedAnswers: json['selected_answers'] != null
            ? List<String>.from(jsonDecode(json['selected_answers'] as String))
            : [],
        score: json['score'] as int,
        elapsedSeconds: json['elapsed_seconds'] as int,
        lastSavedAt: DateTime.parse(json['last_saved_at'] as String),
      );
}

class QuizProgressService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Save quiz progress
  Future<void> saveProgress(QuizProgress progress) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        'quiz_progress',
        progress.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to save quiz progress: $e');
    }
  }

  // Get quiz progress
  Future<QuizProgress?> getProgress(String userId, String quizId) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'quiz_progress',
        where: 'user_id = ? AND quiz_id = ?',
        whereArgs: [userId, quizId],
        limit: 1,
      );

      if (results.isEmpty) return null;
      return QuizProgress.fromJson(Map<String, dynamic>.from(results.first));
    } catch (e) {
      throw Exception('Failed to get quiz progress: $e');
    }
  }

  // Delete quiz progress (when completed)
  Future<void> deleteProgress(String userId, String quizId) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        'quiz_progress',
        where: 'user_id = ? AND quiz_id = ?',
        whereArgs: [userId, quizId],
      );
    } catch (e) {
      throw Exception('Failed to delete quiz progress: $e');
    }
  }

  // Get all in-progress quizzes for user
  Future<List<QuizProgress>> getInProgressQuizzes(String userId) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'quiz_progress',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'last_saved_at DESC',
      );

      return results
          .map((data) => QuizProgress.fromJson(Map<String, dynamic>.from(data)))
          .toList();
    } catch (e) {
      throw Exception('Failed to get in-progress quizzes: $e');
    }
  }
}

