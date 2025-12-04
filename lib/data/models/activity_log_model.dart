class ActivityLog {
  final int? id;
  final String userId;
  final String? quizId;
  final String eventType; // 'app_paused', 'app_resumed', 'answer_changed'
  final Map<String, dynamic>? eventData;
  final DateTime timestamp;
  final int isSynced;

  ActivityLog({
    this.id,
    required this.userId,
    this.quizId,
    required this.eventType,
    this.eventData,
    required this.timestamp,
    this.isSynced = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'quiz_id': quizId,
      'event_type': eventType,
      'event_data': eventData != null ? eventData : null,
      'timestamp': timestamp.toIso8601String(),
      'is_synced': isSynced,
    };
  }

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      quizId: json['quiz_id'] as String?,
      eventType: json['event_type'] as String,
      eventData: json['event_data'] != null
          ? Map<String, dynamic>.from(json['event_data'] as Map)
          : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isSynced: json['is_synced'] as int? ?? 0,
    );
  }
}

