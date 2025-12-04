import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../models/flashcard_model.dart';

class FlashcardRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Get flashcards by subject and grade
  Future<List<Flashcard>> getFlashcardsBySubjectAndGrade(String subject, int gradeLevel) async {
    try {
      final db = await _dbHelper.database;
      final flashcards = await db.query(
        'flashcards',
        where: 'subject = ? AND grade_level = ?',
        whereArgs: [subject, gradeLevel],
        orderBy: 'created_at DESC',
      );

      return flashcards.map((data) {
        final tagsJson = data['tags'] as String?;
        
        return Flashcard(
          id: data['id'] as String,
          subject: data['subject'] as String,
          gradeLevel: data['grade_level'] as int,
          front: data['front'] as String,
          back: data['back'] as String,
          frontImageUrl: data['front_image_url'] as String?,
          backImageUrl: data['back_image_url'] as String?,
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

  // Save flashcard
  Future<void> saveFlashcard(Flashcard flashcard) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        'flashcards',
        {
          'id': flashcard.id,
          'subject': flashcard.subject,
          'grade_level': flashcard.gradeLevel,
          'front': flashcard.front,
          'back': flashcard.back,
          'front_image_url': flashcard.frontImageUrl,
          'back_image_url': flashcard.backImageUrl,
          'tags': jsonEncode(flashcard.tags),
          'created_by': flashcard.createdBy,
          'created_at': flashcard.createdAt.toIso8601String(),
          'synced_at': flashcard.syncedAt?.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      rethrow;
    }
  }
}

