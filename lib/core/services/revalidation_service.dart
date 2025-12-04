import 'package:uuid/uuid.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../data/repositories/assignment_repository.dart';
import '../../data/models/quiz_model.dart';
import '../../data/models/assignment_model.dart';
import 'auth_service.dart';
import 'sync_service.dart';
import 'dart:math';

class RevalidationService {
  final QuizRepository _quizRepository = QuizRepository();
  final AssignmentRepository _assignmentRepository = AssignmentRepository();
  final AuthService _authService = AuthService();
  final SyncService _syncService = SyncService();
  final Uuid _uuid = const Uuid();
  final Random _random = Random();

  Future<void> createRevalidationQuiz({
    required String userId,
    required String originalQuizId,
    required String subject,
    required int gradeLevel,
  }) async {
    try {
      // Get 5 random questions from the same subject and grade
      final allQuestions = await _quizRepository.getQuestionsBySubjectAndGrade(
        subject,
        gradeLevel,
      );

      if (allQuestions.length < 5) {
        throw Exception('Not enough questions available for revalidation');
      }

      // Shuffle and take 5 random questions
      final shuffled = List<QuizQuestion>.from(allQuestions)..shuffle(_random);
      final revalidationQuestions = shuffled.take(5).toList();

      // Create a temporary quiz ID for revalidation
      final revalidationQuizId = _uuid.v4();

      // Create assignment for revalidation
      final teacher = await _authService.getCurrentUser();
      if (teacher == null || teacher.classCode == null) {
        throw Exception('Teacher not found');
      }

      final assignment = Assignment(
        id: _uuid.v4(),
        teacherId: teacher.id,
        classCode: teacher.classCode!,
        moduleId: revalidationQuizId,
        moduleType: 'quiz',
        title: 'Revalidation Quiz - $subject',
        instructions: 'Please complete this revalidation quiz. You must score at least 60% to verify your original score.',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        assignedTo: [userId],
        createdAt: DateTime.now(),
      );

      await _assignmentRepository.saveAssignment(assignment);
      await _syncService.enqueue('assignments', assignment.id, data: assignment.toJson());

      // Store revalidation questions mapping (in a real app, you'd create a separate table)
      // For now, we'll use the assignment's module_id to identify revalidation quizzes
      
      return;
    } catch (e) {
      rethrow;
    }
  }

  bool isRevalidationPassed(int score, int total) {
    final percentage = (score / total) * 100;
    return percentage >= 60;
  }
}

