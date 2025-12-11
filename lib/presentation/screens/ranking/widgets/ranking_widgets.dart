import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/ranking_models.dart';
import '../../../widgets/glass_container.dart';

class XpProgressBar extends StatelessWidget {
  final int currentXp;
  final int targetXp;
  final RankingLeague currentLeague;
  final RankingLeague? nextLeague;
  final double height;

  const XpProgressBar({
    super.key,
    required this.currentXp,
    required this.targetXp,
    required this.currentLeague,
    this.nextLeague,
    this.height = 20,
  });

  @override
  Widget build(BuildContext context) {
    final progress = nextLeague == null
        ? 1.0
        : ((currentXp - currentLeague.minXp) /
                  (nextLeague!.minXp - currentLeague.minXp))
              .clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(currentLeague.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  currentLeague.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (nextLeague != null)
              Text(
                '${currentXp - currentLeague.minXp}/${nextLeague!.minXp - currentLeague.minXp} XP',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              Text(
                '$currentXp XP ⭐',
                style: TextStyle(
                  color: Color(currentLeague.color),
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            // Background
            Container(
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height / 2),
                color: Colors.grey.withValues(alpha: 0.2),
              ),
            ),
            // Progress
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: height,
              width: MediaQuery.of(context).size.width * 0.85 * progress,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height / 2),
                gradient: LinearGradient(
                  colors: [
                    Color(currentLeague.color),
                    Color(currentLeague.color).withValues(alpha: 0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(currentLeague.color).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (nextLeague != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Próximo: ${nextLeague!.emoji} ${nextLeague!.name}',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class LeagueCard extends StatelessWidget {
  final RankingLeague league;
  final bool isCurrentLeague;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const LeagueCard({
    super.key,
    required this.league,
    this.isCurrentLeague = false,
    this.isUnlocked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isCurrentLeague
              ? Color(league.color).withValues(alpha: 0.2)
              : (isDark ? Colors.grey[900] : Colors.grey[100]),
          border: Border.all(
            color: isCurrentLeague ? Color(league.color) : Colors.transparent,
            width: 2,
          ),
          boxShadow: isCurrentLeague
              ? [
                  BoxShadow(
                    color: Color(league.color).withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              league.emoji,
              style: TextStyle(
                fontSize: 28,
                color: isUnlocked || isCurrentLeague
                    ? null
                    : Colors.grey.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              league.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isUnlocked || isCurrentLeague
                    ? (isDark ? Colors.white : Colors.black87)
                    : Colors.grey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${league.minXp}+ XP',
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
            if (isCurrentLeague) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(league.color),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'VOCÊ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LeaderboardItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final int position;

  const LeaderboardItem({
    super.key,
    required this.entry,
    required this.position,
  });

  Widget _buildPositionBadge() {
    if (position == 1) {
      return const Text('🥇', style: TextStyle(fontSize: 24));
    } else if (position == 2) {
      return const Text('🥈', style: TextStyle(fontSize: 24));
    } else if (position == 3) {
      return const Text('🥉', style: TextStyle(fontSize: 24));
    }
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$position',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: entry.isCurrentUser
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : (isDark ? Colors.grey[900] : Colors.grey[50]),
        border: entry.isCurrentUser
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : null,
      ),
      child: Row(
        children: [
          _buildPositionBadge(),
          const SizedBox(width: 12),
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: Color(entry.league.color).withValues(alpha: 0.2),
            backgroundImage: entry.avatarUrl != null
                ? NetworkImage(entry.avatarUrl!)
                : null,
            child: entry.avatarUrl == null
                ? Text(
                    entry.userName.isNotEmpty
                        ? entry.userName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Color(entry.league.color),
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.userName,
                  style: TextStyle(
                    fontWeight: entry.isCurrentUser
                        ? FontWeight.bold
                        : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  entry.league.name,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // XP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(entry.league.color).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${entry.totalXp} XP',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(entry.league.color),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MissionCard extends StatelessWidget {
  final WeeklyMission mission;
  final VoidCallback? onTap;

  const MissionCard({super.key, required this.mission, this.onTap});

  IconData _getMissionIcon() {
    switch (mission.missionType) {
      case MissionType.openAppDaily:
        return Icons.phone_android;
      case MissionType.registerExpenseDaily:
      case MissionType.registerAllExpenses7Days:
        return Icons.receipt_long;
      case MissionType.registerIncomeDaily:
        return Icons.add_circle_outline;
      case MissionType.checkBalanceDaily:
        return Icons.account_balance_wallet;
      case MissionType.categorizeAllTransactions:
        return Icons.category;
      case MissionType.maintainPositiveBalance:
        return Icons.trending_up;
      case MissionType.addSavingsGoal:
        return Icons.flag;
      case MissionType.reduceSpendingCategory:
      case MissionType.reduceSpending20Percent:
        return Icons.savings;
      case MissionType.increaseIncome:
        return Icons.attach_money;
      case MissionType.maintainStreak7Days:
        return Icons.local_fire_department;
      case MissionType.reachSavingsGoal:
        return Icons.emoji_events;
      case MissionType.noUnnecessarySpending:
        return Icons.block;
      case MissionType.investmentGoal:
        return Icons.trending_up;
      case MissionType.perfectWeek:
      case MissionType.perfectMonth:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final difficultyColor = Color(mission.difficulty.color);

    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: difficultyColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getMissionIcon(),
                    color: difficultyColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mission.missionType.title,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (mission.isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Completa',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mission.missionType.description,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: mission.progress,
                          backgroundColor: difficultyColor.withValues(
                            alpha: 0.15,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            mission.isCompleted
                                ? Colors.green
                                : difficultyColor,
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${mission.currentValue.toInt()}/${mission.targetValue.toInt()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            '${mission.progressPercent}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: difficultyColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // XP reward
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        difficultyColor,
                        difficultyColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: difficultyColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '+${mission.missionType.xpReward}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!mission.isCompleted) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: difficultyColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      mission.difficulty.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: difficultyColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.timer_outlined, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    mission.timeRemainingFormatted,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StreakCard extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const StreakCard({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.orange,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Streak Atual',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$currentStreak',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        currentStreak == 1 ? 'dia' : 'dias',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Recorde',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  '$longestStreak 🔥',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
