import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../models/assignment_model.dart';
import 'package:uuid/uuid.dart';

class AssignmentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  Future<void> saveAssignment(Assignment assignment) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(
        'assignments',
        {
          'id': assignment.id,
          'teacher_id': assignment.teacherId,
          'class_code': assignment.classCode,
          'module_id': assignment.moduleId,
          'module_type': assignment.moduleType,
          'title': assignment.title,
          'instructions': assignment.instructions,
          'due_date': assignment.dueDate?.toIso8601String(),
          'assigned_to': assignment.assignedTo is List
              ? jsonEncode(assignment.assignedTo)
              : assignment.assignedTo,
          'created_at': assignment.createdAt.toIso8601String(),
          'is_synced': assignment.isSynced,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Assignment>> getAssignmentsByClass(String classCode) async {
    try {
      final db = await _dbHelper.database;
      final assignments = await db.query(
        'assignments',
        where: 'class_code = ?',
        whereArgs: [classCode],
        orderBy: 'created_at DESC',
      );

      return assignments.map((data) {
        final assignedTo = data['assigned_to'];
        return Assignment(
          id: data['id'] as String,
          teacherId: data['teacher_id'] as String,
          classCode: data['class_code'] as String,
          moduleId: data['module_id'] as String,
          moduleType: data['module_type'] as String,
          title: data['title'] as String,
          instructions: data['instructions'] as String?,
          dueDate: data['due_date'] != null
              ? DateTime.parse(data['due_date'] as String)
              : null,
          assignedTo: assignedTo == 'all'
              ? 'all'
              : (assignedTo != null
                  ? List<String>.from(jsonDecode(assignedTo as String))
                  : null),
          createdAt: DateTime.parse(data['created_at'] as String),
          isSynced: data['is_synced'] as int? ?? 0,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Assignment>> getAssignmentsForStudent(String userId, String classCode) async {
    try {
      final db = await _dbHelper.database;
      final assignments = await db.query(
        'assignments',
        where: 'class_code = ?',
        whereArgs: [classCode],
        orderBy: 'created_at DESC',
      );

      return assignments.where((data) {
        final assignedTo = data['assigned_to'];
        if (assignedTo == 'all') return true;
        if (assignedTo == null) return false;
        final assignedList = List<String>.from(jsonDecode(assignedTo as String));
        return assignedList.contains(userId);
      }).map((data) {
        final assignedTo = data['assigned_to'];
        return Assignment(
          id: data['id'] as String,
          teacherId: data['teacher_id'] as String,
          classCode: data['class_code'] as String,
          moduleId: data['module_id'] as String,
          moduleType: data['module_type'] as String,
          title: data['title'] as String,
          instructions: data['instructions'] as String?,
          dueDate: data['due_date'] != null
              ? DateTime.parse(data['due_date'] as String)
              : null,
          assignedTo: assignedTo == 'all'
              ? 'all'
              : (assignedTo != null
                  ? List<String>.from(jsonDecode(assignedTo as String))
                  : null),
          createdAt: DateTime.parse(data['created_at'] as String),
          isSynced: data['is_synced'] as int? ?? 0,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}

