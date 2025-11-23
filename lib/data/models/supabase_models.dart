class Profile {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String role;

  Profile({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.role,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      email: json['email'] ?? '',
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      role: json['role'] ?? 'user',
    );
  }
}

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type; // 'income' or 'expense'
  final String category;
  final DateTime date;
  final String? icon;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.icon,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      type: json['type'],
      category: json['category'],
      date: DateTime.parse(json['date']),
      icon: json['icon'],
    );
  }
}

class UserStreak {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;

  UserStreak({
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
  });

  factory UserStreak.fromJson(Map<String, dynamic> json) {
    return UserStreak(
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      lastActivityDate: json['last_activity_date'] != null
          ? DateTime.parse(json['last_activity_date'])
          : null,
    );
  }
}

class SavingsGoal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final String icon;
  final String color;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    required this.icon,
    required this.color,
  });

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'],
      title: json['title'],
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentAmount: (json['current_amount'] as num).toDouble(),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      icon: json['icon'] ?? 'savings',
      color: json['color'] ?? '0xFF4CAF50',
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final String description;
  final String contentUrl;
  final int xpReward;
  final bool isPublished;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.contentUrl,
    required this.xpReward,
    required this.isPublished,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      contentUrl: json['content_url'] ?? '',
      xpReward: json['xp_reward'] ?? 10,
      isPublished: json['is_published'] ?? false,
    );
  }
}

class UserLessonProgress {
  final String id;
  final String lessonId;
  final String status; // 'completed', 'in_progress', 'locked'
  final DateTime? completedAt;

  UserLessonProgress({
    required this.id,
    required this.lessonId,
    required this.status,
    this.completedAt,
  });

  factory UserLessonProgress.fromJson(Map<String, dynamic> json) {
    return UserLessonProgress(
      id: json['id'],
      lessonId: json['lesson_id'],
      status: json['status'] ?? 'locked',
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }
}
