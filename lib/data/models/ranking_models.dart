// Ranking and Gamification Models for Nexxo Flutter
// Implements Duolingo-style leagues, weekly missions, and level progression

// League/Category enum with XP thresholds
enum RankingLeague {
  bronze(0, 499, '🏆', 'Bronze', 0xFF8B4513),
  silver(500, 1499, '🥈', 'Prata', 0xFFC0C0C0),
  gold(1500, 2999, '🥇', 'Ouro', 0xFFFFD700),
  diamond(3000, 4999, '💎', 'Diamante', 0xFF00BFFF),
  legend(5000, 999999, '👑', 'Lenda', 0xFFFF6B35);

  final int minXp;
  final int maxXp;
  final String emoji;
  final String name;
  final int color;

  const RankingLeague(
    this.minXp,
    this.maxXp,
    this.emoji,
    this.name,
    this.color,
  );

  static RankingLeague fromXp(int xp) {
    if (xp >= RankingLeague.legend.minXp) return RankingLeague.legend;
    if (xp >= RankingLeague.diamond.minXp) return RankingLeague.diamond;
    if (xp >= RankingLeague.gold.minXp) return RankingLeague.gold;
    if (xp >= RankingLeague.silver.minXp) return RankingLeague.silver;
    return RankingLeague.bronze;
  }

  RankingLeague? get nextLeague {
    switch (this) {
      case RankingLeague.bronze:
        return RankingLeague.silver;
      case RankingLeague.silver:
        return RankingLeague.gold;
      case RankingLeague.gold:
        return RankingLeague.diamond;
      case RankingLeague.diamond:
        return RankingLeague.legend;
      case RankingLeague.legend:
        return null;
    }
  }
}

// Mission types with different XP rewards
enum MissionType {
  // ============ DAILY MISSIONS (reset every day at midnight) ============
  openAppDaily('Abrir o app', 'Acesse o aplicativo hoje', 10, 'daily'),
  registerExpenseDaily(
    'Registrar despesa',
    'Registre pelo menos 1 despesa hoje',
    25,
    'daily',
  ),
  checkBalanceDaily(
    'Verificar saldo',
    'Visualize seu resumo financeiro',
    15,
    'daily',
  ),
  registerIncomeDaily(
    'Registrar receita',
    'Registre uma receita hoje',
    20,
    'daily',
  ),

  // ============ WEEKLY MISSIONS (reset every Monday) ============
  registerAllExpenses7Days(
    'Registrar despesas 7 dias',
    'Registre despesas todos os dias por 7 dias',
    75,
    'weekly',
  ),
  categorizeAllTransactions(
    'Categorizar transações',
    'Registre 10 transações categorizadas',
    60,
    'weekly',
  ),
  maintainPositiveBalance(
    'Manter saldo positivo',
    'Mantenha saldo positivo por 7 dias',
    80,
    'weekly',
  ),
  addSavingsGoal(
    'Criar meta de economia',
    'Crie uma nova meta de economia',
    50,
    'weekly',
  ),
  maintainStreak7Days(
    'Streak 7 dias',
    'Acesse o app 7 dias consecutivos',
    100,
    'weekly',
  ),
  reduceSpendingCategory(
    'Reduzir gastos',
    'Gaste menos que a semana anterior',
    120,
    'weekly',
  ),
  noUnnecessarySpending(
    'Gastos conscientes',
    'Evite gastos em entretenimento por 1 semana',
    180,
    'weekly',
  ),
  perfectWeek(
    'Semana perfeita',
    'Complete todas as missões diárias da semana',
    300,
    'weekly',
  ),

  // ============ MONTHLY MISSIONS (reset on 1st of each month) ============
  reachSavingsGoal(
    'Atingir meta',
    'Atinja 100% de uma meta de economia',
    200,
    'monthly',
  ),
  reduceSpending20Percent(
    'Super economia',
    'Reduza gastos totais em 20% vs mês anterior',
    250,
    'monthly',
  ),
  increaseIncome(
    'Aumentar receita',
    'Aumente sua receita em 10% vs mês anterior',
    200,
    'monthly',
  ),
  investmentGoal(
    'Meta de investimento',
    'Reserve R\$100+ para investimentos',
    200,
    'monthly',
  ),
  perfectMonth(
    'Mês perfeito',
    'Complete todas as missões semanais do mês',
    500,
    'monthly',
  );

  final String title;
  final String description;
  final int xpReward;
  final String frequency; // 'daily', 'weekly', 'monthly'

  const MissionType(
    this.title,
    this.description,
    this.xpReward,
    this.frequency,
  );
}

// Mission difficulty for UI styling
enum MissionDifficulty {
  easy(0xFF4CAF50, 'Fácil'),
  medium(0xFFFFA726, 'Médio'),
  hard(0xFFEF5350, 'Difícil'),
  expert(0xFF9C27B0, 'Expert');

  final int color;
  final String label;

  const MissionDifficulty(this.color, this.label);

  static MissionDifficulty fromXp(int xp) {
    if (xp >= 200) return MissionDifficulty.expert;
    if (xp >= 100) return MissionDifficulty.hard;
    if (xp >= 50) return MissionDifficulty.medium;
    return MissionDifficulty.easy;
  }
}

// User's current ranking data
class UserRanking {
  final String id;
  final String odMesterId;
  final int totalXp;
  final int monthlyXp;
  final RankingLeague currentLeague;
  final int rankPosition;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;

  UserRanking({
    required this.id,
    required this.odMesterId,
    required this.totalXp,
    required this.monthlyXp,
    required this.currentLeague,
    required this.rankPosition,
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
  });

  factory UserRanking.fromJson(Map<String, dynamic> json) {
    final xp = json['total_xp'] as int? ?? 0;
    return UserRanking(
      id: json['id'] ?? '',
      odMesterId: json['user_id'] ?? '',
      totalXp: xp,
      monthlyXp: json['monthly_xp'] as int? ?? 0,
      currentLeague: RankingLeague.fromXp(xp),
      rankPosition: json['rank_position'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastActivityDate: json['last_activity_date'] != null
          ? DateTime.parse(json['last_activity_date'])
          : null,
    );
  }

  int get xpToNextLeague {
    final next = currentLeague.nextLeague;
    if (next == null) return 0;
    return next.minXp - totalXp;
  }

  double get progressToNextLeague {
    final next = currentLeague.nextLeague;
    if (next == null) return 1.0;
    final range = next.minXp - currentLeague.minXp;
    final progress = totalXp - currentLeague.minXp;
    return (progress / range).clamp(0.0, 1.0);
  }
}

// Weekly mission instance
class WeeklyMission {
  final String id;
  final String odMesterId;
  final MissionType missionType;
  final double targetValue;
  final double currentValue;
  final bool isCompleted;
  final DateTime weekStart;
  final DateTime weekEnd;

  WeeklyMission({
    required this.id,
    required this.odMesterId,
    required this.missionType,
    required this.targetValue,
    required this.currentValue,
    required this.isCompleted,
    required this.weekStart,
    required this.weekEnd,
  });

  factory WeeklyMission.fromJson(Map<String, dynamic> json) {
    final typeString =
        json['mission_type'] as String? ?? 'registerExpenseDaily';
    final missionType = MissionType.values.firstWhere(
      (e) => e.name == typeString,
      orElse: () => MissionType.registerExpenseDaily,
    );

    return WeeklyMission(
      id: json['id'] ?? '',
      odMesterId: json['user_id'] ?? '',
      missionType: missionType,
      targetValue: (json['target_value'] as num?)?.toDouble() ?? 1.0,
      currentValue: (json['current_value'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['is_completed'] as bool? ?? false,
      weekStart: DateTime.parse(
        json['week_start'] ?? DateTime.now().toIso8601String(),
      ),
      weekEnd: DateTime.parse(
        json['week_end'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  double get progress =>
      targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;

  int get progressPercent => (progress * 100).toInt();

  MissionDifficulty get difficulty =>
      MissionDifficulty.fromXp(missionType.xpReward);

  /// Returns whether this mission is still active (not expired)
  bool get isActive {
    final now = DateTime.now();
    final endOfDay = DateTime(
      weekEnd.year,
      weekEnd.month,
      weekEnd.day,
      23,
      59,
      59,
    );
    return now.isBefore(endOfDay) || now.isAtSameMomentAs(endOfDay);
  }

  /// Time remaining until mission expires (uses end of day)
  Duration get timeRemaining {
    final now = DateTime.now();
    final endOfDay = DateTime(
      weekEnd.year,
      weekEnd.month,
      weekEnd.day,
      23,
      59,
      59,
    );
    return endOfDay.difference(now);
  }

  /// Formatted time remaining string
  String get timeRemainingFormatted {
    if (isCompleted) return 'Concluída ✓';

    final remaining = timeRemaining;
    if (remaining.isNegative) return 'Expirada';

    final days = remaining.inDays;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;

    // For daily missions, show hours/minutes
    if (missionType.frequency == 'daily') {
      if (hours > 0) return '${hours}h ${minutes}m';
      return '${minutes}m';
    }

    // For weekly/monthly missions
    if (days > 0) return '${days}d ${hours}h';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  /// Get frequency label for display
  String get frequencyLabel {
    switch (missionType.frequency) {
      case 'daily':
        return 'Diária';
      case 'weekly':
        return 'Semanal';
      case 'monthly':
        return 'Mensal';
      default:
        return '';
    }
  }
}

// Leaderboard entry
class LeaderboardEntry {
  final String odMesterId;
  final String userName;
  final String? avatarUrl;
  final int totalXp;
  final int rankPosition;
  final RankingLeague league;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.odMesterId,
    required this.userName,
    this.avatarUrl,
    required this.totalXp,
    required this.rankPosition,
    required this.league,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    final odMesterId = json['user_id'] ?? '';
    final xp = json['total_xp'] as int? ?? 0;
    return LeaderboardEntry(
      odMesterId: odMesterId,
      userName: json['user_name'] ?? json['full_name'] ?? 'Usuário',
      avatarUrl: json['avatar_url'],
      totalXp: xp,
      rankPosition: json['rank_position'] as int? ?? 0,
      league: RankingLeague.fromXp(xp),
      isCurrentUser: odMesterId == currentUserId,
    );
  }
}

// Achievement model
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int xpReward;
  final String category; // 'streak', 'savings', 'spending', 'general'
  final String
  requirementType; // 'missions_completed', 'xp_earned', 'streak_days', etc.
  final int requirementValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.xpReward,
    this.category = 'general',
    this.requirementType = 'general',
    this.requirementValue = 1,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'emoji_events',
      xpReward: json['xp_reward'] as int? ?? 0,
      category: json['category'] ?? 'general',
      requirementType: json['requirement_type'] ?? 'general',
      requirementValue: json['requirement_value'] as int? ?? 1,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'])
          : null,
    );
  }

  /// Get a formatted requirement description
  String get requirementDescription {
    switch (requirementType) {
      case 'missions_completed':
        return 'Complete $requirementValue missões';
      case 'xp_earned':
        return 'Alcance $requirementValue XP';
      case 'streak_days':
        return 'Mantenha um streak de $requirementValue dias';
      case 'savings_weeks':
        return 'Economize por $requirementValue semanas seguidas';
      case 'goals_reached':
        return 'Atinja $requirementValue meta(s) de economia';
      case 'perfect_weeks':
        return 'Tenha $requirementValue semana(s) perfeita(s)';
      case 'perfect_months':
        return 'Tenha $requirementValue mês(es) perfeito(s)';
      default:
        return description;
    }
  }

  /// Get category display name
  String get categoryName {
    switch (category) {
      case 'streak':
        return '🔥 Consistência';
      case 'savings':
        return '💰 Economia';
      case 'spending':
        return '📉 Gastos';
      case 'general':
      default:
        return '⭐ Geral';
    }
  }
}

// Monthly progress summary
class MonthlyProgress {
  final int month;
  final int year;
  final int totalXp;
  final int missionsCompleted;
  final int missionsTotal;
  final RankingLeague startLeague;
  final RankingLeague endLeague;
  final int rankChange; // positive = moved up, negative = moved down

  MonthlyProgress({
    required this.month,
    required this.year,
    required this.totalXp,
    required this.missionsCompleted,
    required this.missionsTotal,
    required this.startLeague,
    required this.endLeague,
    required this.rankChange,
  });

  factory MonthlyProgress.fromJson(Map<String, dynamic> json) {
    final startXp = json['start_xp'] as int? ?? 0;
    final endXp = json['end_xp'] as int? ?? 0;
    return MonthlyProgress(
      month: json['month'] as int? ?? DateTime.now().month,
      year: json['year'] as int? ?? DateTime.now().year,
      totalXp: json['total_xp'] as int? ?? 0,
      missionsCompleted: json['missions_completed'] as int? ?? 0,
      missionsTotal: json['missions_total'] as int? ?? 0,
      startLeague: RankingLeague.fromXp(startXp),
      endLeague: RankingLeague.fromXp(endXp),
      rankChange: json['rank_change'] as int? ?? 0,
    );
  }

  bool get leveledUp => endLeague.index > startLeague.index;
  bool get leveledDown => endLeague.index < startLeague.index;
}
