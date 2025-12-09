import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/quiz_model.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/services/content_moderation_service.dart';
import '../../../core/services/analytics_service.dart';

class CreateContentScreen extends StatefulWidget {
  const CreateContentScreen({super.key});

  @override
  State<CreateContentScreen> createState() => _CreateContentScreenState();
}

class _CreateContentScreenState extends State<CreateContentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quizRepository = QuizRepository();
  final _authService = AuthService();
  final _syncService = SyncService();
  final _contentModeration = ContentModerationService();
  final Uuid _uuid = const Uuid();

  String _contentType = 'quiz';
  String _questionType = 'mcq';
  final _questionController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  final _option3Controller = TextEditingController();
  final _option4Controller = TextEditingController();
  String _selectedSubject = 'Math';
  int _selectedGrade = 4;
  String _selectedAnswer = '';
  int _selectedDifficulty = 2;

  @override
  void dispose() {
    _questionController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    _option4Controller.dispose();
    super.dispose();
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Content moderation check
    final questionText = _questionController.text.trim();
    if (!_contentModeration.isValidContent(questionText)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question contains inappropriate content. Please revise.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    if (_selectedAnswer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the correct answer')),
      );
      return;
    }

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      // Build options based on question type
      List<String> options = [];
      if (_questionType == 'true_false') {
        options = ['True', 'False'];
        _selectedAnswer = _selectedAnswer == 'True' ? 'True' : 'False';
      } else {
        options = [
          _option1Controller.text.trim(),
          _option2Controller.text.trim(),
          _option3Controller.text.trim(),
          _option4Controller.text.trim(),
        ];
      }

      final question = QuizQuestion(
        id: _uuid.v4(),
        subject: _selectedSubject,
        gradeLevel: _selectedGrade,
        questionText: questionText,
        questionType: _questionType,
        options: options,
        correctAnswer: _selectedAnswer,
        difficulty: _selectedDifficulty,
        createdBy: user.id,
        createdAt: DateTime.now(),
      );

      await _quizRepository.saveQuestion(question);
      await _syncService.enqueue('quiz_questions', question.id, data: question.toJson());
      
      // Analytics
      await AnalyticsService().logContentCreated('quiz_question');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Question saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving question: $e')),
        );
      }
    }
  }

  void _resetForm() {
    _questionController.clear();
    _option1Controller.clear();
    _option2Controller.clear();
    _option3Controller.clear();
    _option4Controller.clear();
    _selectedAnswer = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Content')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Subject and Grade
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedSubject,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Math', 'Science', 'English', 'Filipino']
                          .map((subject) => DropdownMenuItem(
                                value: subject,
                                child: Text(subject),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedSubject = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedGrade,
                      decoration: const InputDecoration(
                        labelText: 'Grade',
                        border: OutlineInputBorder(),
                      ),
                      items: [1, 2, 3, 4, 5, 6]
                          .map((grade) => DropdownMenuItem(
                                value: grade,
                                child: Text('Grade $grade'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedGrade = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Question Type
              DropdownButtonFormField<String>(
                value: _questionType,
                decoration: const InputDecoration(
                  labelText: 'Question Type',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'mcq', child: Text('Multiple Choice')),
                  DropdownMenuItem(value: 'true_false', child: Text('True/False')),
                ],
                onChanged: (value) {
                  setState(() {
                    _questionType = value ?? 'mcq';
                    if (_questionType == 'true_false') {
                      _selectedAnswer = '';
                    }
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Question
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a question';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Options (only for MCQ)
              if (_questionType == 'mcq') ...[
                TextFormField(
                  controller: _option1Controller,
                  decoration: const InputDecoration(
                    labelText: 'Option 1',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_questionType == 'mcq' && (value == null || value.isEmpty)) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _option2Controller,
                  decoration: const InputDecoration(
                    labelText: 'Option 2',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_questionType == 'mcq' && (value == null || value.isEmpty)) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _option3Controller,
                  decoration: const InputDecoration(
                    labelText: 'Option 3',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_questionType == 'mcq' && (value == null || value.isEmpty)) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _option4Controller,
                  decoration: const InputDecoration(
                    labelText: 'Option 4',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_questionType == 'mcq' && (value == null || value.isEmpty)) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Correct Answer for MCQ
                const Text('Correct Answer:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...['Option 1', 'Option 2', 'Option 3', 'Option 4'].map((option) {
                  return RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _selectedAnswer,
                    onChanged: (value) {
                      setState(() => _selectedAnswer = value ?? '');
                    },
                  );
                }),
              ] else ...[
                // True/False options
                const SizedBox(height: 16),
                const Text('Correct Answer:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                RadioListTile<String>(
                  title: const Text('True'),
                  value: 'True',
                  groupValue: _selectedAnswer,
                  onChanged: (value) {
                    setState(() => _selectedAnswer = value ?? '');
                  },
                ),
                RadioListTile<String>(
                  title: const Text('False'),
                  value: 'False',
                  groupValue: _selectedAnswer,
                  onChanged: (value) {
                    setState(() => _selectedAnswer = value ?? '');
                  },
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Difficulty
              DropdownButtonFormField<int>(
                value: _selectedDifficulty,
                decoration: const InputDecoration(
                  labelText: 'Difficulty',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 1, child: Text('Easy')),
                  DropdownMenuItem(value: 2, child: Text('Medium')),
                  DropdownMenuItem(value: 3, child: Text('Hard')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedDifficulty = value);
                  }
                },
              ),
              
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _saveQuestion,
                child: const Text('Save Question'),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

