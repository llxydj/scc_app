import '../../data/repositories/quiz_repository.dart';
import '../../data/models/quiz_model.dart';

class SubjectProgressService {
  final QuizRepository _quizRepository = QuizRepository();

  Future<Map<String, double>> getSubjectProgress(String userId) async {
    try {
      final results = await _quizRepository.getUserResults(userId);
      final progress = <String, Map<String, int>>{};

      // Group results by subject
      for (final result in results) {
        String? subject = result.subject;
        
        // If subject not stored, try to get from first question
        if (subject == null || subject.isEmpty) {
          final question = await _quizRepository.getQuestionById(result.quizId);
          subject = question?.subject;
        }
        
        if (subject == null || subject.isEmpty) continue;

        if (!progress.containsKey(subject)) {
          progress[subject] = {'total': 0, 'correct': 0};
        }

        progress[subject]!['total'] = (progress[subject]!['total'] ?? 0) + result.totalQuestions;
        progress[subject]!['correct'] = (progress[subject]!['correct'] ?? 0) + result.score;
      }

      // Calculate percentages
      final percentages = <String, double>{};
      for (final entry in progress.entries) {
        final total = entry.value['total'] ?? 0;
        final correct = entry.value['correct'] ?? 0;
        percentages[entry.key] = total > 0 ? correct / total : 0.0;
      }

      // Ensure all subjects have a value
      final allSubjects = ['Math', 'Science', 'English', 'Filipino'];
      for (final subject in allSubjects) {
        if (!percentages.containsKey(subject)) {
          percentages[subject] = 0.0;
        }
      }

      return percentages;
    } catch (e) {
      // Return default progress for all subjects
      return {
        'Math': 0.0,
        'Science': 0.0,
        'English': 0.0,
        'Filipino': 0.0,
      };
    }
  }
}

