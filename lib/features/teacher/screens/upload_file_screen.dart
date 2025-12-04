import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/quiz_model.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/services/file_parser_service.dart';
import '../../../core/services/analytics_service.dart';

class UploadFileScreen extends StatefulWidget {
  const UploadFileScreen({super.key});

  @override
  State<UploadFileScreen> createState() => _UploadFileScreenState();
}

class _UploadFileScreenState extends State<UploadFileScreen> {
  final _quizRepository = QuizRepository();
  final _authService = AuthService();
  final _syncService = SyncService();
  final _fileParserService = FileParserService();

  bool _isUploading = false;
  String? _fileName;
  int _questionsProcessed = 0;

  Future<void> _pickAndProcessFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx'],
      );

      if (result == null || result.files.single.path == null) return;

      setState(() {
        _fileName = result.files.single.name;
        _isUploading = true;
        _questionsProcessed = 0;
      });

      final filePath = result.files.single.path!;
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      if (filePath.endsWith('.csv')) {
        await _processCSV(filePath, user.id);
      } else if (filePath.endsWith('.xlsx')) {
        // Excel processing would require excel package
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Excel support coming soon')),
        );
        setState(() => _isUploading = false);
        return;
      } else {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unsupported file format')),
        );
        return;
      }

      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully processed $_questionsProcessed questions!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing file: $e')),
        );
      }
    }
  }

  Future<void> _processCSV(String filePath, String userId) async {
    try {
      final questions = await _fileParserService.parseCSV(filePath, userId);
      
      for (final question in questions) {
        await _quizRepository.saveQuestion(question);
        await _syncService.enqueue('quiz_questions', question.id, data: question.toJson());
        
        setState(() => _questionsProcessed++);
      }
      
      // Analytics
      await AnalyticsService().logFileUploaded('csv', _questionsProcessed);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload File')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.upload_file,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Upload Quiz Questions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload a CSV file with quiz questions. Format: Question, Option1, Option2, Option3, Option4, CorrectAnswer, Subject, GradeLevel, Difficulty',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            
            if (_fileName != null) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.description),
                  title: Text(_fileName!),
                  trailing: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            if (_isUploading) ...[
              LinearProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Processing $_questionsProcessed questions...',
                textAlign: TextAlign.center,
              ),
            ],
            
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: _isUploading ? null : _pickAndProcessFile,
              child: const Text('Select File'),
            ),
          ],
        ),
      ),
    );
  }
}

