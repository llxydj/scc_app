import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/quiz_model.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  final _authService = AuthService();
  final _quizRepository = QuizRepository();
  UserModel? _currentUser;
  List<QuizResult> _childProgress = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null || user.studentId == null) {
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        _currentUser = user;
      });

      // Load child's progress
      final progress = await _quizRepository.getUserResults(user.studentId!);
      setState(() {
        _childProgress = progress;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null || _currentUser!.studentId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Parent Dashboard')),
        body: const Center(
          child: Text('No child account linked. Please contact your child\'s teacher.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Parent Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Child\'s Progress',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_childProgress.isEmpty)
                      const Text('No quiz results yet.')
                    else
                      ..._childProgress.take(5).map((result) {
                        final percentage = result.score / result.totalQuestions;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quiz ${_childProgress.indexOf(result) + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Score: ${result.score}/${result.totalQuestions}',
                                    ),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      value: percentage,
                                      backgroundColor: AppColors.divider,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        percentage >= 0.7
                                            ? AppColors.success
                                            : AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                Formatters.formatDate(result.completedAt),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
