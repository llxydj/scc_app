import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('scc_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        role TEXT CHECK(role IN ('student', 'teacher', 'parent')),
        grade_level INTEGER,
        class_code TEXT,
        points INTEGER DEFAULT 0,
        streak INTEGER DEFAULT 0,
        last_active_date TEXT,
        language_preference TEXT DEFAULT 'en',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        synced_at TEXT,
        fcm_token TEXT,
        parent_access_code TEXT,
        student_id TEXT
      )
    ''');

    // Quiz questions table
    await db.execute('''
      CREATE TABLE quiz_questions (
        id TEXT PRIMARY KEY,
        subject TEXT NOT NULL,
        grade_level INTEGER NOT NULL,
        question_text TEXT NOT NULL,
        question_type TEXT CHECK(question_type IN ('mcq', 'true_false', 'image_based')),
        options TEXT,
        correct_answer TEXT NOT NULL,
        image_url TEXT,
        explanation TEXT,
        difficulty INTEGER CHECK(difficulty BETWEEN 1 AND 3),
        tags TEXT,
        created_by TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        synced_at TEXT
      )
    ''');

    // Flashcards table
    await db.execute('''
      CREATE TABLE flashcards (
        id TEXT PRIMARY KEY,
        subject TEXT NOT NULL,
        grade_level INTEGER NOT NULL,
        front TEXT NOT NULL,
        back TEXT NOT NULL,
        front_image_url TEXT,
        back_image_url TEXT,
        tags TEXT,
        created_by TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        synced_at TEXT
      )
    ''');

    // Student progress table
    await db.execute('''
      CREATE TABLE student_progress (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        quiz_id TEXT NOT NULL,
        subject TEXT,
        score INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        time_taken INTEGER,
        time_per_question TEXT,
        completed_at TEXT DEFAULT CURRENT_TIMESTAMP,
        hash_signature TEXT NOT NULL,
        device_id TEXT NOT NULL,
        is_verified INTEGER DEFAULT 0,
        is_synced INTEGER DEFAULT 0,
        total_pauses INTEGER DEFAULT 0,
        events TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (quiz_id) REFERENCES quiz_questions(id)
      )
    ''');

    // Badges table
    await db.execute('''
      CREATE TABLE badges (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        icon_url TEXT,
        requirement_type TEXT,
        requirement_value INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // User badges table
    await db.execute('''
      CREATE TABLE user_badges (
        user_id TEXT NOT NULL,
        badge_id TEXT NOT NULL,
        unlocked_at TEXT DEFAULT CURRENT_TIMESTAMP,
        is_synced INTEGER DEFAULT 0,
        PRIMARY KEY (user_id, badge_id),
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (badge_id) REFERENCES badges(id)
      )
    ''');

    // Activity logs table
    await db.execute('''
      CREATE TABLE activity_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        quiz_id TEXT,
        event_type TEXT,
        event_data TEXT,
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
        is_synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Sync queue table
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT CHECK(operation IN ('INSERT', 'UPDATE', 'DELETE')),
        data TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        retry_count INTEGER DEFAULT 0,
        last_error TEXT
      )
    ''');

    // Assignments table
    await db.execute('''
      CREATE TABLE assignments (
        id TEXT PRIMARY KEY,
        teacher_id TEXT NOT NULL,
        class_code TEXT NOT NULL,
        module_id TEXT NOT NULL,
        module_type TEXT CHECK(module_type IN ('quiz', 'flashcard')),
        title TEXT NOT NULL,
        instructions TEXT,
        due_date TEXT,
        assigned_to TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        is_synced INTEGER DEFAULT 0,
        FOREIGN KEY (teacher_id) REFERENCES users(id)
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_users_class_code ON users(class_code)');
    await db.execute('CREATE INDEX idx_quiz_subject_grade ON quiz_questions(subject, grade_level)');
    await db.execute('CREATE INDEX idx_progress_user ON student_progress(user_id)');
    await db.execute('CREATE INDEX idx_progress_quiz ON student_progress(quiz_id)');
    await db.execute('CREATE INDEX idx_progress_synced ON student_progress(is_synced)');
    await db.execute('CREATE INDEX idx_sync_queue_retry ON sync_queue(retry_count)');
    await db.execute('CREATE INDEX idx_assignments_class ON assignments(class_code)');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

