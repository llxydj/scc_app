import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/quiz_model.dart';
import '../errors/exceptions.dart';

class FileParserService {
  final Uuid _uuid = const Uuid();

  Future<List<QuizQuestion>> parseCSV(String filePath, String createdBy) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileException('File not found');
      }

      final content = await file.readAsString();
      final csvData = const CsvToListConverter().convert(content);

      if (csvData.isEmpty) {
        throw FileException('CSV file is empty');
      }

      final questions = <QuizQuestion>[];

      // Skip header row (index 0)
      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        
        // Expected format: Question, Option1, Option2, Option3, Option4, CorrectAnswer, Subject, GradeLevel, Difficulty
        if (row.length < 8) continue;

        try {
          final question = QuizQuestion(
            id: _uuid.v4(),
            subject: row[6].toString().trim(),
            gradeLevel: int.tryParse(row[7].toString()) ?? 4,
            questionText: row[0].toString().trim(),
            questionType: 'mcq',
            options: [
              row[1].toString().trim(),
              row[2].toString().trim(),
              row[3].toString().trim(),
              row[4].toString().trim(),
            ],
            correctAnswer: row[5].toString().trim(),
            difficulty: row.length > 8 ? (int.tryParse(row[8].toString()) ?? 2) : 2,
            createdBy: createdBy,
            createdAt: DateTime.now(),
          );

          questions.add(question);
        } catch (e) {
          // Skip invalid rows
          continue;
        }
      }

      return questions;
    } catch (e) {
      if (e is FileException) rethrow;
      throw FileException('Failed to parse CSV: ${e.toString()}');
    }
  }
}

