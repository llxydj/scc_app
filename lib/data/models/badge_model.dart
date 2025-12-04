class Badge {
  final String id;
  final String name;
  final String description;
  final String? iconUrl;
  final String requirementType; // 'points', 'streak', 'subject_completion'
  final int requirementValue;
  final DateTime createdAt;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
    required this.requirementType,
    required this.requirementValue,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'requirement_type': requirementType,
      'requirement_value': requirementValue,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['icon_url'] as String?,
      requirementType: json['requirement_type'] as String,
      requirementValue: json['requirement_value'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class UserBadge {
  final String userId;
  final String badgeId;
  final DateTime unlockedAt;
  final int isSynced;

  UserBadge({
    required this.userId,
    required this.badgeId,
    required this.unlockedAt,
    this.isSynced = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'badge_id': badgeId,
      'unlocked_at': unlockedAt.toIso8601String(),
      'is_synced': isSynced,
    };
  }

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      userId: json['user_id'] as String,
      badgeId: json['badge_id'] as String,
      unlockedAt: DateTime.parse(json['unlocked_at'] as String),
      isSynced: json['is_synced'] as int? ?? 0,
    );
  }
}

