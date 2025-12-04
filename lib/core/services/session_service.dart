import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../data/local/database_helper.dart';
import 'dart:convert';

class SessionService {
  static const String _currentUserIdKey = 'current_user_id';
  static const String _currentUserRoleKey = 'current_user_role';
  
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  static UserModel? _currentUser;

  // Save current user session
  Future<void> saveSession(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserIdKey, user.id);
      await prefs.setString(_currentUserRoleKey, user.role);
      _currentUser = user;
    } catch (e) {
      // Handle error
    }
  }

  // Get current user from session
  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_currentUserIdKey);
      
      if (userId == null) return null;

      final db = await _dbHelper.database;
      final users = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (users.isEmpty) {
        await clearSession();
        return null;
      }

      _currentUser = UserModel.fromJson(Map<String, dynamic>.from(users.first));
      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  // Clear session
  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserIdKey);
      await prefs.remove(_currentUserRoleKey);
      _currentUser = null;
    } catch (e) {
      // Handle error
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }
}

