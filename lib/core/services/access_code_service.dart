import 'dart:math';
import 'package:sqflite/sqflite.dart';
import '../../data/local/database_helper.dart';
import '../../data/models/user_model.dart';
import '../services/auth_service.dart';

class AccessCodeService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final AuthService _authService = AuthService();
  final Random _random = Random();

  // Generate a unique 6-digit access code
  String _generateAccessCode() {
    return (100000 + _random.nextInt(900000)).toString();
  }

  // Generate access code for a student
  Future<String> generateAccessCodeForStudent(String studentId) async {
    final db = await _dbHelper.database;
    
    // Check if student exists
    final students = await db.query(
      'users',
      where: 'id = ? AND role = ?',
      whereArgs: [studentId, 'student'],
      limit: 1,
    );

    if (students.isEmpty) {
      throw Exception('Student not found');
    }

    // Generate unique code
    String accessCode;
    bool isUnique = false;
    int attempts = 0;

    while (!isUnique && attempts < 10) {
      accessCode = _generateAccessCode();
      final existing = await db.query(
        'users',
        where: 'parent_access_code = ?',
        whereArgs: [accessCode],
        limit: 1,
      );
      isUnique = existing.isEmpty;
      attempts++;
    }

    if (!isUnique) {
      throw Exception('Failed to generate unique access code');
    }

    // Save access code to student record
    await db.update(
      'users',
      {'parent_access_code': accessCode},
      where: 'id = ?',
      whereArgs: [studentId],
    );

    return accessCode;
  }

  // Get access code for current teacher's students (including those without codes)
  Future<Map<String, String>> getAccessCodesForClass() async {
    final user = await _authService.getCurrentUser();
    if (user?.classCode == null) {
      return {};
    }

    final db = await _dbHelper.database;
    final students = await db.query(
      'users',
      where: 'class_code = ? AND role = ?',
      whereArgs: [user!.classCode, 'student'],
    );

    final codes = <String, String>{};
    for (final student in students) {
      final studentId = student['id'] as String;
      final studentName = student['name'] as String;
      final accessCode = student['parent_access_code'] as String?;
      
      // Include all students, even without codes
      if (accessCode != null && accessCode.isNotEmpty) {
        codes[studentId] = '$studentName: $accessCode';
      } else {
        codes[studentId] = '$studentName: '; // Empty code, will show "No code generated"
      }
    }

    return codes;
  }

  // Regenerate access code
  Future<String> regenerateAccessCode(String studentId) async {
    return await generateAccessCodeForStudent(studentId);
  }
}

