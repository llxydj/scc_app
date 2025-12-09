import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/services/hash_service.dart';
import '../../../core/services/points_service.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/services/activity_log_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/utils/device_info.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/answer_feedback.dart';
import '../../../core/widgets/points_animation.dart';
import '../../../data/models/quiz_model.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../core/services/auth_service.dart';
import 'package:uuid/uuid.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;
  final String subject;

  const QuizScreen({
    super.key,
    required this.quizId,
    required this.subject,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with WidgetsBindingObserver {
  final _quizRepository = QuizRepository();
  final _authService = AuthService();
  final _pointsService = PointsService();
  final _syncService = SyncService();
  final _activityLogService = ActivityLogService();
  final Uuid _uuid = const Uuid();

  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  int _score = 0;
  int _elapsedSeconds = 0;
  List<int> _timePerQuestion = [];
  int _questionStartTime = 0;
  Timer? _timer;
  bool _isCompleted = false;
  int _totalPauses = 0;
  List<String> _events = [];
  bool _isPaused = false;
  String _quizSessionId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadQuestions();
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseQuiz();
    } else if (state == AppLifecycleState.resumed) {
      _resumeQuiz();
    }
  }

  Future<void> _loadQuestions() async {
    try {
      final user = await _authService.getCurrentUser();
      final gradeLevel = user?.gradeLevel ?? 4;
      
      // Generate quiz session ID if not provided
      if (widget.quizId.isEmpty) {
        _quizSessionId = _uuid.v4();
      } else {
        _quizSessionId = widget.quizId;
      }
      
      final questions = await _quizRepository.getQuestionsBySubjectAndGrade(
        widget.subject,
        gradeLevel,
      );
      
      // Log quiz start
      if (user != null && _quizSessionId.isNotEmpty) {
        await _activityLogService.logEvent(
          userId: user.id,
          quizId: _quizSessionId,
          eventType: 'quiz_started',
          eventData: {'subject': widget.subject, 'grade_level': gradeLevel},
        );
        
        // Analytics
        await AnalyticsService().logQuizStarted(widget.subject, gradeLevel);
      }
      
      if (questions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No questions available for this subject')),
          );
          context.pop();
        }
        return;
      }

      setState(() {
        _questions = questions.take(10).toList(); // Limit to 10 questions
        _questionStartTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading questions: $e')),
        );
        context.pop();
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && !_isCompleted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _pauseQuiz() async {
    if (_isCompleted || _isPaused) return;
    
    final user = await _authService.getCurrentUser();
    if (user != null && _quizSessionId.isNotEmpty) {
      await _activityLogService.logEvent(
        userId: user.id,
        quizId: _quizSessionId,
        eventType: 'app_paused',
        eventData: {'question_index': _currentQuestionIndex + 1},
      );
    }
    
    setState(() {
      _isPaused = true;
      _totalPauses++;
      _events.add('paused_at_q${_currentQuestionIndex + 1}');
    });
  }

  void _resumeQuiz() async {
    if (!_isPaused) return;
    
    final user = await _authService.getCurrentUser();
    if (user != null && _quizSessionId.isNotEmpty) {
      await _activityLogService.logEvent(
        userId: user.id,
        quizId: _quizSessionId,
        eventType: 'app_resumed',
        eventData: {'question_index': _currentQuestionIndex + 1},
      );
    }
    
    setState(() {
      _isPaused = false;
      _events.add('resumed_at_q${_currentQuestionIndex + 1}');
    });
  }

  void _nextQuestion() {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an answer')),
      );
      return;
    }

    // Calculate time for this question
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final questionTime = currentTime - _questionStartTime;
    _timePerQuestion.add(questionTime);

    // Check if answer is correct
    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = _selectedAnswer == currentQuestion.correctAnswer;
    
    if (isCorrect) {
      _score++;
    }
    
    // Show feedback animation
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (context) => Center(
        child: AnswerFeedback(
          isCorrect: isCorrect,
          onAnimationComplete: () {
            Navigator.pop(context);
            _moveToNextQuestion();
          },
        ),
      ),
    );

  }

  void _moveToNextQuestion() {
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    // Move to next question or complete
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _questionStartTime = currentTime;
      });
    } else {
      _completeQuiz();
    }
  }

  Future<void> _completeQuiz() async {
    _timer?.cancel();
    setState(() => _isCompleted = true);

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      final deviceId = await DeviceInfo.getId();
      final now = DateTime.now();
      final quizSessionId = _quizSessionId.isNotEmpty ? _quizSessionId : _uuid.v4();

      // Generate hash signature
      final hash = HashService.generateQuizHash(
        user.id,
        quizSessionId,
        _score,
        now,
        deviceId,
      );

      // Calculate points
      final points = _pointsService.calculateQuizPoints(
        score: _score,
        total: _questions.length,
      );

      // Award points
      await _pointsService.awardPoints(user.id, points);

      // Save quiz result
      final result = QuizResult(
        id: _uuid.v4(),
        userId: user.id,
        quizId: quizSessionId,
        subject: widget.subject,
        score: _score,
        totalQuestions: _questions.length,
        timeTaken: _elapsedSeconds,
        timePerQuestion: _timePerQuestion,
        completedAt: now,
        hashSignature: hash,
        deviceId: deviceId,
        totalPauses: _totalPauses,
        events: _events,
      );

      await _quizRepository.saveQuizResult(result);

      // Log quiz completion
      await _activityLogService.logEvent(
        userId: user.id,
        quizId: quizSessionId,
        eventType: 'quiz_completed',
        eventData: {
          'score': _score,
          'total_questions': _questions.length,
          'time_taken': _elapsedSeconds,
        },
      );
      
      // Analytics
      await AnalyticsService().logQuizCompleted(
        widget.subject,
        _score,
        _questions.length,
      );

      // Enqueue for sync
      await _syncService.enqueue('student_progress', result.id, data: result.toJson());

      // Show results
      if (mounted) {
        _showResults(points);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving results: $e')),
        );
      }
    }
  }

  void _showResults(int points) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $_score/${_questions.length}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Time: ${Formatters.formatTime(_elapsedSeconds)}'),
            const SizedBox(height: 16),
            PointsAnimation(points: points),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isCompleted) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject} Quiz'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _showExitConfirmation(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                Formatters.formatTime(_elapsedSeconds),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.divider,
            minHeight: 4,
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // Question
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentQuestion.questionText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Options
                  ...currentQuestion.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isSelected = _selectedAnswer == option;
                    final optionLabel = String.fromCharCode(65 + index); // A, B, C, D
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Semantics(
                        label: 'Option $optionLabel: $option',
                        button: true,
                        selected: isSelected,
                        child: InkWell(
                        onTap: () async {
                          final previousAnswer = _selectedAnswer;
                          setState(() {
                            _selectedAnswer = option;
                          });
                          
                          // Log answer change if different from previous
                          if (previousAnswer != null && previousAnswer != option) {
                            final user = await _authService.getCurrentUser();
                            if (user != null && _quizSessionId.isNotEmpty) {
                              await _activityLogService.logEvent(
                                userId: user.id,
                                quizId: _quizSessionId,
                                eventType: 'answer_changed',
                                eventData: {
                                  'question_index': _currentQuestionIndex + 1,
                                  'previous_answer': previousAnswer,
                                  'new_answer': option,
                                },
                              );
                              _events.add('changed_q${_currentQuestionIndex + 1}_answer');
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.divider,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.1)
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: isSelected ? AppColors.primary : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList()),
                ],
              ),
            ),
          ),

          // Next button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _currentQuestionIndex < _questions.length - 1
                      ? 'Next Question'
                      : 'Submit Quiz',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text('Your progress will be lost if you exit now.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

