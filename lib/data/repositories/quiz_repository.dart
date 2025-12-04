import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../models/quiz_model.dart';
import 'package:uuid/uuid.dart';

class QuizRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  // Get quiz questions by subject and grade
  Future<List<QuizQuestion>> getQuestionsBySubjectAndGrade(String subject, int gradeLevel) async {
    try {
      final db = await _dbHelper.database;
      final questions = await db.query(
        'quiz_questions',
        where: 'subject = ? AND grade_level = ?',
        whereArgs: [subject, gradeLevel],
        orderBy: 'created_at DESC',
      );

      return questions.map((data) {
        final optionsJson = data['options'] as String?;
        final tagsJson = data['tags'] as String?;
        
        return QuizQuestion(
          id: data['id'] as String,
          subject: data['subject'] as String,
          gradeLevel: data['grade_level'] as int,
          questionText: data['question_text'] as String,
          questionType: data['question_type'] as String,
          options: optionsJson != null ? List<String>.from(jsonDecode(optionsJson)) : [],
          correctAnswer: data['correct_answer'] as String,
          imageUrl: data['image_url'] as String?,
          explanation: data['explanation'] as String?,
          difficulty: data['difficulty'] as int? ?? 2,
          tags: tagsJson != null ? List<String>.from(jsonDecode(tagsJson)) : [],
          createdBy: data['created_by'] as String?,
          createdAt: DateTime.parse(data['created_at'] as String),
          syncedAt: data['synced_at'] != null ? DateTime.parse(data['synced_at'] as String) : null,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get question by ID
  Future<QuizQuestion?> getQuestionById(String id) async {
    try {
      final db = await _dbHelper.database;
      final questions = await db.query(
        'quiz_questions',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (questions.isEmpty) return null;

      final data = questions.first;
      final optionsJson = data['options'] as String?;
      final tagsJson = data['tags'] as String?;

      return QuizQuestion(
        id: data['id'] as String,
        subject: data['subject'] as String,
        gradeLevel: data['grade_level'] as int,
        questionText: data['question_text'] as String,
        questionType: data['question_type'] as String,
        options: optionsJson != null ? List<String>.from(jsonDecode(optionsJson)) : [],
        correctAnswer: data['correct_answer'] as String,
        imageUrl: data['image_url'] as String?,
        explanation: data['explanation'] as String?,
        difficulty: data['difficulty'] as int? ?? 2,
        tags: tagsJson != null ? List<String>.from(jsonDecode(tagsJson)) : [],
        createdBy: data['created_by'] as String?,
        createdAt: DateTime.parse(data['created_at'] as String),
        syncedAt: data['synced_at'] != null ? DateTime.parse(data['synced_at'] as String) : null,
      );
    } catch (e) {
      return null;
    }
  }

  // Save quiz question
  Future<void> saveQuestion(QuizQuestion question) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        'quiz_questions',
        {
          'id': question.id,
          'subject': question.subject,
          'grade_level': question.gradeLevel,
          'question_text': question.questionText,
          'question_type': question.questionType,
          'options': jsonEncode(question.options),
          'correct_answer': question.correctAnswer,
          'image_url': question.imageUrl,
          'explanation': question.explanation,
          'difficulty': question.difficulty,
          'tags': jsonEncode(question.tags),
          'created_by': question.createdBy,
          'created_at': question.createdAt.toIso8601String(),
          'synced_at': question.syncedAt?.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Save quiz result
  Future<void> saveQuizResult(QuizResult result) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        'student_progress',
        {
          'id': result.id,
          'user_id': result.userId,
          'quiz_id': result.quizId,
          'subject': result.subject,
          'score': result.score,
          'total_questions': result.totalQuestions,
          'time_taken': result.timeTaken,
          'time_per_question': jsonEncode(result.timePerQuestion),
          'completed_at': result.completedAt.toIso8601String(),
          'hash_signature': result.hashSignature,
          'device_id': result.deviceId,
          'is_verified': result.isVerified,
          'is_synced': result.isSynced,
          'total_pauses': result.totalPauses,
          'events': jsonEncode(result.events),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get quiz results for user
  Future<List<QuizResult>> getUserResults(String userId) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'student_progress',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'completed_at DESC',
      );

      return results.map((data) {
        final timePerQuestionJson = data['time_per_question'] as String?;
        final eventsJson = data['events'] as String?;

        return QuizResult(
          id: data['id'] as String,
          userId: data['user_id'] as String,
          quizId: data['quiz_id'] as String,
          subject: data['subject'] as String?,
          score: data['score'] as int,
          totalQuestions: data['total_questions'] as int,
          timeTaken: data['time_taken'] as int? ?? 0,
          timePerQuestion: timePerQuestionJson != null
              ? List<int>.from(jsonDecode(timePerQuestionJson))
              : [],
          completedAt: DateTime.parse(data['completed_at'] as String),
          hashSignature: data['hash_signature'] as String,
          deviceId: data['device_id'] as String,
          isVerified: data['is_verified'] as int? ?? 0,
          isSynced: data['is_synced'] as int? ?? 0,
          totalPauses: data['total_pauses'] as int? ?? 0,
          events: eventsJson != null ? List<String>.from(jsonDecode(eventsJson)) : [],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}

