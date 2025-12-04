class QuizQuestion {
  final String id;
  final String subject;
  final int gradeLevel;
  final String questionText;
  final String questionType; // 'mcq', 'true_false', 'image_based'
  final List<String> options;
  final String correctAnswer;
  final String? imageUrl;
  final String? explanation;
  final int difficulty; // 1-3
  final List<String> tags;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? syncedAt;

  QuizQuestion({
    required this.id,
    required this.subject,
    required this.gradeLevel,
    required this.questionText,
    required this.questionType,
    required this.options,
    required this.correctAnswer,
    this.imageUrl,
    this.explanation,
    this.difficulty = 2,
    this.tags = const [],
    this.createdBy,
    required this.createdAt,
    this.syncedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'grade_level': gradeLevel,
      'question_text': questionText,
      'question_type': questionType,
      'options': options,
      'correct_answer': correctAnswer,
      'image_url': imageUrl,
      'explanation': explanation,
      'difficulty': difficulty,
      'tags': tags,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      subject: json['subject'] as String,
      gradeLevel: json['grade_level'] as int,
      questionText: json['question_text'] as String,
      questionType: json['question_type'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswer: json['correct_answer'] as String,
      imageUrl: json['image_url'] as String?,
      explanation: json['explanation'] as String?,
      difficulty: json['difficulty'] as int? ?? 2,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : [],
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      syncedAt: json['synced_at'] != null
          ? DateTime.parse(json['synced_at'] as String)
          : null,
    );
  }
}

class QuizResult {
  final String id;
  final String userId;
  final String quizId;
  final String? subject; // Store subject for easier querying
  final int score;
  final int totalQuestions;
  final int timeTaken; // seconds
  final List<int> timePerQuestion;
  final DateTime completedAt;
  final String hashSignature;
  final String deviceId;
  final int isVerified; // 0 = pending, 1 = verified, -1 = flagged
  final int isSynced;
  final int totalPauses;
  final List<String> events;

  QuizResult({
    required this.id,
    required this.userId,
    required this.quizId,
    this.subject,
    required this.score,
    required this.totalQuestions,
    required this.timeTaken,
    required this.timePerQuestion,
    required this.completedAt,
    required this.hashSignature,
    required this.deviceId,
    this.isVerified = 0,
    this.isSynced = 0,
    this.totalPauses = 0,
    this.events = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'quiz_id': quizId,
      'subject': subject,
      'score': score,
      'total_questions': totalQuestions,
      'time_taken': timeTaken,
      'time_per_question': timePerQuestion,
      'completed_at': completedAt.toIso8601String(),
      'hash_signature': hashSignature,
      'device_id': deviceId,
      'is_verified': isVerified,
      'is_synced': isSynced,
      'total_pauses': totalPauses,
      'events': events,
    };
  }

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      quizId: json['quiz_id'] as String,
      subject: json['subject'] as String?,
      score: json['score'] as int,
      totalQuestions: json['total_questions'] as int,
      timeTaken: json['time_taken'] as int,
      timePerQuestion: List<int>.from(json['time_per_question'] as List),
      completedAt: DateTime.parse(json['completed_at'] as String),
      hashSignature: json['hash_signature'] as String,
      deviceId: json['device_id'] as String,
      isVerified: json['is_verified'] as int? ?? 0,
      isSynced: json['is_synced'] as int? ?? 0,
      totalPauses: json['total_pauses'] as int? ?? 0,
      events: json['events'] != null ? List<String>.from(json['events'] as List) : [],
    );
  }
}

