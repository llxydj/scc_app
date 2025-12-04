import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/local/database_helper.dart';
import '../errors/exceptions.dart';

class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Connectivity _connectivity = Connectivity();

  // Check if device is online
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Enqueue item for sync
  Future<void> enqueue(String tableName, String recordId, {String operation = 'INSERT', Map<String, dynamic>? data}) async {
    try {
      final db = await _dbHelper.database;
      
      final recordData = data ?? await _getRecordData(db, tableName, recordId);
      
      await db.insert('sync_queue', {
        'table_name': tableName,
        'record_id': recordId,
        'operation': operation,
        'data': jsonEncode(recordData),
        'created_at': DateTime.now().toIso8601String(),
        'retry_count': 0,
        'last_error': null,
      });
    } catch (e) {
      throw SyncException('Failed to enqueue: ${e.toString()}');
    }
  }

  // Get record data from table
  Future<Map<String, dynamic>> _getRecordData(Database db, String tableName, String recordId) async {
    final records = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [recordId],
      limit: 1,
    );
    
    if (records.isEmpty) {
      throw SyncException('Record not found: $tableName/$recordId');
    }
    
    return Map<String, dynamic>.from(records.first);
  }

  // Sync all pending items
  Future<void> syncAll() async {
    if (!await isOnline()) {
      throw SyncException('No internet connection');
    }

    try {
      final db = await _dbHelper.database;
      final queue = await db.query(
        'sync_queue',
        where: 'retry_count < ?',
        whereArgs: [5], // Max 5 retries
        orderBy: 'created_at ASC',
      );

      for (final item in queue) {
        try {
          await _syncItem(db, item);
          // Remove from queue on success
          await db.delete(
            'sync_queue',
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        } catch (e) {
          // Increment retry count
          await db.update(
            'sync_queue',
            {
              'retry_count': (item['retry_count'] as int) + 1,
              'last_error': e.toString(),
            },
            where: 'id = ?',
            whereArgs: [item['id']],
          );
        }
      }
    } catch (e) {
      throw SyncException('Sync failed: ${e.toString()}');
    }
  }

  // Sync single item
  Future<void> _syncItem(Database db, Map<String, dynamic> item) async {
    final tableName = item['table_name'] as String;
    final recordId = item['record_id'] as String;
    final operation = item['operation'] as String;
    final dataJson = item['data'] as String?;

    if (dataJson == null) return;

    final data = jsonDecode(dataJson) as Map<String, dynamic>;

    switch (tableName) {
      case 'users':
        await _syncUser(operation, data);
        break;
      case 'student_progress':
        await _syncStudentProgress(operation, data);
        break;
      case 'quiz_questions':
        await _syncQuizQuestion(operation, data);
        break;
      case 'flashcards':
        await _syncFlashcard(operation, data);
        break;
      case 'user_badges':
        await _syncUserBadge(operation, data);
        break;
      case 'assignments':
        await _syncAssignment(operation, data);
        break;
    }

    // Mark as synced in local DB
    await db.update(
      tableName,
      {'is_synced': 1, 'synced_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }

  Future<void> _syncUser(String operation, Map<String, dynamic> data) async {
    final docRef = _firestore.collection('users').doc(data['id'] as String);
    
    if (operation == 'DELETE') {
      await docRef.delete();
    } else {
      await docRef.set(data, SetOptions(merge: true));
    }
  }

  Future<void> _syncStudentProgress(String operation, Map<String, dynamic> data) async {
    final docRef = _firestore.collection('student_progress').doc(data['id'] as String);
    
    if (operation == 'DELETE') {
      await docRef.delete();
    } else {
      await docRef.set(data, SetOptions(merge: true));
    }
  }

  Future<void> _syncQuizQuestion(String operation, Map<String, dynamic> data) async {
    final docRef = _firestore.collection('quiz_questions').doc(data['id'] as String);
    
    if (operation == 'DELETE') {
      await docRef.delete();
    } else {
      await docRef.set(data, SetOptions(merge: true));
    }
  }

  Future<void> _syncFlashcard(String operation, Map<String, dynamic> data) async {
    final docRef = _firestore.collection('flashcards').doc(data['id'] as String);
    
    if (operation == 'DELETE') {
      await docRef.delete();
    } else {
      await docRef.set(data, SetOptions(merge: true));
    }
  }

  Future<void> _syncUserBadge(String operation, Map<String, dynamic> data) async {
    final userId = data['user_id'] as String;
    final badgeId = data['badge_id'] as String;
    final docRef = _firestore.collection('users').doc(userId).collection('badges').doc(badgeId);
    
    if (operation == 'DELETE') {
      await docRef.delete();
    } else {
      await docRef.set(data, SetOptions(merge: true));
    }
  }

  Future<void> _syncAssignment(String operation, Map<String, dynamic> data) async {
    final docRef = _firestore.collection('assignments').doc(data['id'] as String);
    
    if (operation == 'DELETE') {
      await docRef.delete();
    } else {
      await docRef.set(data, SetOptions(merge: true));
    }
  }

  // Pull data from Firestore
  Future<void> pullFromCloud() async {
    if (!await isOnline()) {
      throw SyncException('No internet connection');
    }

    try {
      final db = await _dbHelper.database;
      
      // Pull users
      final usersSnapshot = await _firestore.collection('users').get();
      for (final doc in usersSnapshot.docs) {
        await db.insert('users', doc.data(), conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // Pull quiz questions
      final quizSnapshot = await _firestore.collection('quiz_questions').get();
      for (final doc in quizSnapshot.docs) {
        await db.insert('quiz_questions', doc.data(), conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // Pull flashcards
      final flashcardSnapshot = await _firestore.collection('flashcards').get();
      for (final doc in flashcardSnapshot.docs) {
        await db.insert('flashcards', doc.data(), conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // Pull assignments
      final assignmentSnapshot = await _firestore.collection('assignments').get();
      for (final doc in assignmentSnapshot.docs) {
        await db.insert('assignments', doc.data(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    } catch (e) {
      throw SyncException('Pull failed: ${e.toString()}');
    }
  }
}

