class Flashcard {
  final String id;
  final String subject;
  final int gradeLevel;
  final String front;
  final String back;
  final String? frontImageUrl;
  final String? backImageUrl;
  final List<String> tags;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? syncedAt;

  Flashcard({
    required this.id,
    required this.subject,
    required this.gradeLevel,
    required this.front,
    required this.back,
    this.frontImageUrl,
    this.backImageUrl,
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
      'front': front,
      'back': back,
      'front_image_url': frontImageUrl,
      'back_image_url': backImageUrl,
      'tags': tags,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String,
      subject: json['subject'] as String,
      gradeLevel: json['grade_level'] as int,
      front: json['front'] as String,
      back: json['back'] as String,
      frontImageUrl: json['front_image_url'] as String?,
      backImageUrl: json['back_image_url'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : [],
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      syncedAt: json['synced_at'] != null
          ? DateTime.parse(json['synced_at'] as String)
          : null,
    );
  }
}

