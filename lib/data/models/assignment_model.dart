class Assignment {
  final String id;
  final String teacherId;
  final String classCode;
  final String moduleId;
  final String moduleType; // 'quiz', 'flashcard'
  final String title;
  final String? instructions;
  final DateTime? dueDate;
  final dynamic assignedTo; // List<String> or 'all'
  final DateTime createdAt;
  final int isSynced;

  Assignment({
    required this.id,
    required this.teacherId,
    required this.classCode,
    required this.moduleId,
    required this.moduleType,
    required this.title,
    this.instructions,
    this.dueDate,
    this.assignedTo,
    required this.createdAt,
    this.isSynced = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacher_id': teacherId,
      'class_code': classCode,
      'module_id': moduleId,
      'module_type': moduleType,
      'title': title,
      'instructions': instructions,
      'due_date': dueDate?.toIso8601String(),
      'assigned_to': assignedTo is List ? assignedTo : (assignedTo == 'all' ? 'all' : assignedTo),
      'created_at': createdAt.toIso8601String(),
      'is_synced': isSynced,
    };
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      teacherId: json['teacher_id'] as String,
      classCode: json['class_code'] as String,
      moduleId: json['module_id'] as String,
      moduleType: json['module_type'] as String,
      title: json['title'] as String,
      instructions: json['instructions'] as String?,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      assignedTo: json['assigned_to'],
      createdAt: DateTime.parse(json['created_at'] as String),
      isSynced: json['is_synced'] as int? ?? 0,
    );
  }
}

