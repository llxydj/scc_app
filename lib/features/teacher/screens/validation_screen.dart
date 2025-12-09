import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/hash_service.dart';
import '../../../core/services/revalidation_service.dart';
import '../../../core/utils/device_info.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../data/models/quiz_model.dart';
import '../../../core/services/activity_log_service.dart';
import '../../../core/services/auth_service.dart';

class ValidationScreen extends StatefulWidget {
  const ValidationScreen({super.key});

  @override
  State<ValidationScreen> createState() => _ValidationScreenState();
}

class _ValidationScreenState extends State<ValidationScreen> {
  final _quizRepository = QuizRepository();
  final _authService = AuthService();
  final _activityLogService = ActivityLogService();
  final _revalidationService = RevalidationService();
  List<QuizResult> _results = [];
  bool _isLoading = true;
  String? _selectedClassCode;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user?.classCode != null) {
        _selectedClassCode = user!.classCode;
        // Load results for this class
        final classResults = await _quizRepository.getResultsByClassCode(user.classCode!);
        setState(() {
          _results = classResults;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getVerificationStatus(QuizResult result) {
    // Check hash validity
    final isValid = HashService.validateHash(
      result.hashSignature,
      result.userId,
      result.quizId,
      result.score,
      result.completedAt,
      result.deviceId,
    );
    
    if (!isValid) return 'failed';
    if (result.isVerified == 1) return 'verified';
    if (result.isVerified == -1) return 'failed';
    if (result.totalPauses > 3) return 'flagged';
    if (result.timeTaken < result.totalQuestions * 10) return 'flagged';
    return 'verified';
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'verified':
        return Icons.check_circle;
      case 'flagged':
        return Icons.warning;
      case 'failed':
        return Icons.error;
      default:
        return Icons.pending;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'verified':
        return AppColors.verified;
      case 'flagged':
        return AppColors.flagged;
      case 'failed':
        return AppColors.failed;
      default:
        return AppColors.textSecondary;
    }
  }

  Future<void> _requestRevalidation(String userId, String quizId) async {
    try {
      // Get the original quiz result to find subject and grade
      final result = _results.firstWhere((r) => r.id == quizId);
      final question = await _quizRepository.getQuestionById(result.quizId);
      
      if (question == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not find quiz details')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Request Revalidation'),
          content: const Text(
            'A revalidation quiz with 5 random questions will be assigned to this student. '
            'They must score at least 60% to verify their original score.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                
                try {
                  await _revalidationService.createRevalidationQuiz(
                    userId: userId,
                    originalQuizId: quizId,
                    subject: question.subject,
                    gradeLevel: question.gradeLevel,
                  );
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Revalidation quiz assigned successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Assign'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _showDetailedView(QuizResult result) async {
    final logs = await _activityLogService.getLogsForQuiz(result.userId, result.quizId);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quiz Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Score: ${result.score}/${result.totalQuestions}'),
            Text('Time Taken: ${result.timeTaken} seconds'),
            Text('Total Pauses: ${result.totalPauses}'),
            const SizedBox(height: 24),
            
            // Time per question chart
            const Text(
              'Time per Question',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
              child: BarChart(
                BarChartData(
                  barGroups: result.timePerQuestion.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: AppColors.primary,
                          width: 16,
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('Q${value.toInt() + 1}');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}s');
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Activity timeline
            const Text(
              'Activity Timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return ListTile(
                    leading: Icon(
                      log.eventType == 'app_paused'
                          ? Icons.pause_circle
                          : log.eventType == 'app_resumed'
                              ? Icons.play_circle
                              : Icons.edit,
                    ),
                    title: Text(log.eventType.replaceAll('_', ' ').toUpperCase()),
                    subtitle: Text(log.timestamp.toString()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Validation')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _results.isEmpty
                ? const Center(child: Text('No quiz results to validate'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final result = _results[index];
                      final status = _getVerificationStatus(result);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Icon(
                            _getStatusIcon(status),
                            color: _getStatusColor(status),
                          ),
                          title: Text('Student ${result.userId.substring(0, 8)}'),
                          subtitle: Text(
                            'Score: ${result.score}/${result.totalQuestions} | '
                            'Time: ${result.timeTaken}s | '
                            'Pauses: ${result.totalPauses}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          trailing: status == 'flagged'
                              ? IconButton(
                                  icon: const Icon(Icons.refresh),
                                  tooltip: 'Revalidate',
                                  onPressed: () => _requestRevalidation(
                                    result.userId,
                                    result.quizId,
                                  ),
                                )
                              : null,
                          onTap: () => _showDetailedView(result),
                        ),
                      );
                    },
                  ),
        ),
    );
  }
}
