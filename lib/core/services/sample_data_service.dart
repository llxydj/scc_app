import 'package:uuid/uuid.dart';
import '../../data/local/database_helper.dart';
import '../../data/models/badge_model.dart';
import '../../data/models/quiz_model.dart';
import '../../data/repositories/quiz_repository.dart';
import 'dart:convert';

class SampleDataService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final QuizRepository _quizRepository = QuizRepository();
  final Uuid _uuid = const Uuid();

  Future<void> initializeSampleData() async {
    await _initializeBadges();
    await _initializeSampleQuestions();
  }

  Future<void> _initializeBadges() async {
    try {
      final db = await _dbHelper.database;
      
      // Check if badges already exist
      final existing = await db.query('badges', limit: 1);
      if (existing.isNotEmpty) return;

      final badges = [
        Badge(
          id: _uuid.v4(),
          name: 'First Steps',
          description: 'Complete your first quiz',
          requirementType: 'points',
          requirementValue: 10,
          createdAt: DateTime.now(),
        ),
        Badge(
          id: _uuid.v4(),
          name: 'Perfect Score',
          description: 'Get 100% on a quiz',
          requirementType: 'points',
          requirementValue: 200,
          createdAt: DateTime.now(),
        ),
        Badge(
          id: _uuid.v4(),
          name: 'Week Warrior',
          description: 'Maintain a 7-day streak',
          requirementType: 'streak',
          requirementValue: 7,
          createdAt: DateTime.now(),
        ),
        Badge(
          id: _uuid.v4(),
          name: 'Scholar',
          description: 'Earn 500 points',
          requirementType: 'points',
          requirementValue: 500,
          createdAt: DateTime.now(),
        ),
        Badge(
          id: _uuid.v4(),
          name: 'Math Master',
          description: 'Complete 10 Math quizzes',
          requirementType: 'subject_completion',
          requirementValue: 10,
          createdAt: DateTime.now(),
        ),
      ];

      for (final badge in badges) {
        await db.insert('badges', badge.toJson(),
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _initializeSampleQuestions() async {
    try {
      final db = await _dbHelper.database;
      
      // Check if questions already exist
      final existing = await db.query('quiz_questions', limit: 1);
      if (existing.isNotEmpty) return;

      final sampleQuestions = [
        QuizQuestion(
          id: _uuid.v4(),
          subject: 'Math',
          gradeLevel: 4,
          questionText: 'What is 3/4 + 1/4?',
          questionType: 'mcq',
          options: ['4/4', '4/8', '1/2', '2/4'],
          correctAnswer: '4/4',
          explanation: 'When adding fractions with the same denominator, add the numerators.',
          difficulty: 2,
          tags: ['fractions', 'addition'],
          createdAt: DateTime.now(),
        ),
        QuizQuestion(
          id: _uuid.v4(),
          subject: 'Math',
          gradeLevel: 4,
          questionText: 'What is 5 × 7?',
          questionType: 'mcq',
          options: ['30', '35', '40', '42'],
          correctAnswer: '35',
          explanation: '5 multiplied by 7 equals 35.',
          difficulty: 1,
          tags: ['multiplication'],
          createdAt: DateTime.now(),
        ),
        QuizQuestion(
          id: _uuid.v4(),
          subject: 'Science',
          gradeLevel: 4,
          questionText: 'What is the process by which plants make food?',
          questionType: 'mcq',
          options: ['Respiration', 'Photosynthesis', 'Digestion', 'Circulation'],
          correctAnswer: 'Photosynthesis',
          explanation: 'Photosynthesis is the process by which plants use sunlight to make food.',
          difficulty: 2,
          tags: ['plants', 'photosynthesis'],
          createdAt: DateTime.now(),
        ),
        QuizQuestion(
          id: _uuid.v4(),
          subject: 'English',
          gradeLevel: 4,
          questionText: 'What is a noun?',
          questionType: 'mcq',
          options: [
            'A word that describes an action',
            'A word that names a person, place, or thing',
            'A word that describes a noun',
            'A word that connects words'
          ],
          correctAnswer: 'A word that names a person, place, or thing',
          explanation: 'A noun is a word that names a person, place, thing, or idea.',
          difficulty: 1,
          tags: ['grammar', 'parts of speech'],
          createdAt: DateTime.now(),
        ),
        QuizQuestion(
          id: _uuid.v4(),
          subject: 'Filipino',
          gradeLevel: 4,
          questionText: 'Ano ang kabisera ng Pilipinas?',
          questionType: 'mcq',
          options: ['Cebu', 'Manila', 'Davao', 'Quezon City'],
          correctAnswer: 'Manila',
          explanation: 'Ang Manila ang kabisera ng Pilipinas.',
          difficulty: 1,
          tags: ['geography', 'capital'],
          createdAt: DateTime.now(),
        ),
      ];

      for (final question in sampleQuestions) {
        await _quizRepository.saveQuestion(question);
      }
    } catch (e) {
      // Handle error
    }
  }
}

