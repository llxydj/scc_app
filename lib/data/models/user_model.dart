class UserModel {
  final String id;
  final String name;
  final String? email;
  final String role; // 'student', 'teacher', 'parent'
  final int? gradeLevel;
  final String? classCode;
  final int points;
  final int streak;
  final DateTime? lastActiveDate;
  final String languagePreference;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? syncedAt;
  final String? fcmToken;
  final String? parentAccessCode; // For parent role
  final String? studentId; // For parent role

  UserModel({
    required this.id,
    required this.name,
    this.email,
    required this.role,
    this.gradeLevel,
    this.classCode,
    this.points = 0,
    this.streak = 0,
    this.lastActiveDate,
    this.languagePreference = 'en',
    required this.createdAt,
    this.updatedAt,
    this.syncedAt,
    this.fcmToken,
    this.parentAccessCode,
    this.studentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'grade_level': gradeLevel,
      'class_code': classCode,
      'points': points,
      'streak': streak,
      'last_active_date': lastActiveDate?.toIso8601String(),
      'language_preference': languagePreference,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
      'fcm_token': fcmToken,
      'parent_access_code': parentAccessCode,
      'student_id': studentId,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      role: json['role'] as String,
      gradeLevel: json['grade_level'] as int?,
      classCode: json['class_code'] as String?,
      points: json['points'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      lastActiveDate: json['last_active_date'] != null
          ? DateTime.parse(json['last_active_date'] as String)
          : null,
      languagePreference: json['language_preference'] as String? ?? 'en',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      syncedAt: json['synced_at'] != null
          ? DateTime.parse(json['synced_at'] as String)
          : null,
      fcmToken: json['fcm_token'] as String?,
      parentAccessCode: json['parent_access_code'] as String?,
      studentId: json['student_id'] as String?,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    int? gradeLevel,
    String? classCode,
    int? points,
    int? streak,
    DateTime? lastActiveDate,
    String? languagePreference,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
    String? fcmToken,
    String? parentAccessCode,
    String? studentId,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      classCode: classCode ?? this.classCode,
      points: points ?? this.points,
      streak: streak ?? this.streak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      languagePreference: languagePreference ?? this.languagePreference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      fcmToken: fcmToken ?? this.fcmToken,
      parentAccessCode: parentAccessCode ?? this.parentAccessCode,
      studentId: studentId ?? this.studentId,
    );
  }
}

