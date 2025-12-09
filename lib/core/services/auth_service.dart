import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../data/local/database_helper.dart';
import '../../data/models/user_model.dart';
import '../errors/exceptions.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'session_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final SessionService _sessionService = SessionService();
  final Uuid _uuid = const Uuid();

  // Student login with username and PIN
  Future<UserModel> loginStudent(String username, String pin) async {
    try {
      final db = await _dbHelper.database;
      
      // Find user by username (assuming username is stored in name or email field)
      final users = await db.query(
        'users',
        where: '(name = ? OR email = ?) AND role = ?',
        whereArgs: [username, username, 'student'],
        limit: 1,
      );

      if (users.isEmpty) {
        throw AuthenticationException('Student not found');
      }

      final userData = users.first;
      final storedPinHash = await _secureStorage.read(key: 'pin_${userData['id']}');

      if (storedPinHash == null) {
        throw AuthenticationException('PIN not set for this student');
      }

      // Verify PIN
      final pinHash = _hashPin(pin);
      if (pinHash != storedPinHash) {
        throw AuthenticationException('Invalid PIN');
      }

      // Update last active date
      await db.update(
        'users',
        {
          'last_active_date': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userData['id']],
      );

      final user = UserModel.fromJson(Map<String, dynamic>.from(userData));
      await _sessionService.saveSession(user);
      return user;
    } catch (e) {
      if (e is AuthenticationException) rethrow;
      throw AuthenticationException('Login failed: ${e.toString()}');
    }
  }

  // Teacher login with email and password
  Future<UserModel> loginTeacher(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthenticationException('Login failed');
      }

      final db = await _dbHelper.database;
      final users = await db.query(
        'users',
        where: 'email = ? AND role = ?',
        whereArgs: [email, 'teacher'],
        limit: 1,
      );

      if (users.isEmpty) {
        throw AuthenticationException('Teacher not found in local database');
      }

      final userData = users.first;
      final user = UserModel.fromJson(Map<String, dynamic>.from(userData));
      await _sessionService.saveSession(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException('Login failed: ${e.message}');
    } catch (e) {
      throw AuthenticationException('Login failed: ${e.toString()}');
    }
  }

  // Parent login with access code
  Future<UserModel> loginParent(String accessCode) async {
    try {
      final db = await _dbHelper.database;
      
      // Find student with this access code
      final students = await db.query(
        'users',
        where: 'parent_access_code = ? AND role = ?',
        whereArgs: [accessCode, 'student'],
        limit: 1,
      );

      if (students.isEmpty) {
        throw AuthenticationException('Invalid access code');
      }

      final studentData = students.first;
      final studentId = studentData['id'] as String;
      
      // Find or create parent account linked to this student
      final parents = await db.query(
        'users',
        where: 'student_id = ? AND role = ?',
        whereArgs: [studentId, 'parent'],
        limit: 1,
      );

      UserModel parentUser;
      if (parents.isEmpty) {
        // Create new parent account
        final parentId = _uuid.v4();
        final now = DateTime.now();
        parentUser = UserModel(
          id: parentId,
          name: 'Parent of ${studentData['name']}',
          role: 'parent',
          studentId: studentId,
          parentAccessCode: accessCode,
          createdAt: now,
          updatedAt: now,
        );
        await db.insert('users', parentUser.toJson());
      } else {
        parentUser = UserModel.fromJson(Map<String, dynamic>.from(parents.first));
      }

      await _sessionService.saveSession(parentUser);
      return parentUser;
    } catch (e) {
      throw AuthenticationException('Login failed: ${e.toString()}');
    }
  }

  // Register student
  Future<UserModel> registerStudent({
    required String name,
    required String username,
    required String pin,
    required int gradeLevel,
    required String classCode,
  }) async {
    try {
      final db = await _dbHelper.database;
      
      // Check if username already exists
      final existingUsers = await db.query(
        'users',
        where: '(name = ? OR email = ?) AND role = ?',
        whereArgs: [username, username, 'student'],
        limit: 1,
      );
      
      if (existingUsers.isNotEmpty) {
        throw AuthenticationException('Username already taken. Please choose a different username.');
      }
      
      final userId = _uuid.v4();
      final now = DateTime.now();

      // Hash PIN
      final pinHash = _hashPin(pin);
      await _secureStorage.write(key: 'pin_$userId', value: pinHash);

      final user = UserModel(
        id: userId,
        name: name,
        email: username,
        role: 'student',
        gradeLevel: gradeLevel,
        classCode: classCode,
        createdAt: now,
        updatedAt: now,
      );

      await db.insert('users', user.toJson());
      await _sessionService.saveSession(user);
      return user;
    } catch (e) {
      throw AuthenticationException('Registration failed: ${e.toString()}');
    }
  }

  // Register teacher
  Future<UserModel> registerTeacher({
    required String name,
    required String email,
    required String password,
    required String classCode,
  }) async {
    try {
      // Create Firebase account
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw AuthenticationException('Registration failed');
      }

      final db = await _dbHelper.database;
      final userId = _uuid.v4();
      final now = DateTime.now();

      final user = UserModel(
        id: userId,
        name: name,
        email: email,
        role: 'teacher',
        classCode: classCode,
        createdAt: now,
        updatedAt: now,
      );

      await db.insert('users', user.toJson());
      
      // Send verification email
      try {
        await credential.user?.sendEmailVerification();
      } catch (e) {
        // Email verification is optional, don't fail registration
        print('Failed to send verification email: $e');
      }
      
      await _sessionService.saveSession(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException('Registration failed: ${e.message}');
    } catch (e) {
      throw AuthenticationException('Registration failed: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _sessionService.clearSession();
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    // First try session service (works for all user types)
    final sessionUser = await _sessionService.getCurrentUser();
    if (sessionUser != null) return sessionUser;

    // Fallback to Firebase for teachers
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      final db = await _dbHelper.database;
      final users = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [firebaseUser.email],
        limit: 1,
      );

      if (users.isEmpty) return null;
      final user = UserModel.fromJson(Map<String, dynamic>.from(users.first));
      await _sessionService.saveSession(user);
      return user;
    } catch (e) {
      return null;
    }
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
}

