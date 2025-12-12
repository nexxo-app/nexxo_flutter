// Story Shareable Widgets
// Minimalist story cards for sharing achievements (Instagram-style 9:16)

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/ranking_models.dart';

/// Minimalist story card for achievements - 9:16 aspect ratio
class AchievementStoryCard extends StatelessWidget {
  final Achievement achievement;
  final int totalXp;
  final RankingLeague currentLeague;
  final String userName;
  final GlobalKey repaintBoundaryKey;

  const AchievementStoryCard({
    super.key,
    required this.achievement,
    required this.totalXp,
    required this.currentLeague,
    required this.userName,
    required this.repaintBoundaryKey,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'directions_walk':
        return Icons.directions_walk;
      case 'star':
        return Icons.star;
      case 'military_tech':
        return Icons.military_tech;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'whatshot':
        return Icons.whatshot;
      case 'savings':
        return Icons.savings;
      case 'trending_up':
        return Icons.trending_up;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'diamond':
        return Icons.diamond;
      default:
        return Icons.emoji_events;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      key: repaintBoundaryKey,
      child: Container(
        width: 360, // Fixed width for story
        height: 640, // 9:16 ratio
        decoration: BoxDecoration(
          color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header with logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 28,
                        width: 28,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.account_balance_wallet,
                            size: 28,
                            color: AppTheme.primaryColor,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Nexxo',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Achievement icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber.withValues(alpha: 0.1),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _getIconData(achievement.icon),
                    size: 52,
                    color: Colors.amber,
                  ),
                ),

                const SizedBox(height: 20),

                // Achievement unlocked label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'CONQUISTA DESBLOQUEADA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Achievement name
                Text(
                  achievement.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                // Achievement description
                Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 20),

                // XP badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade600, Colors.amber.shade500],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '+${achievement.xpReward} XP',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // User stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat(
                        icon: Icons.person_outline,
                        value: userName.isNotEmpty
                            ? userName.split(' ').first
                            : 'Usuário',
                        label: '',
                        isDark: isDark,
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                      _buildStat(
                        icon: Icons.star_outline,
                        value: '$totalXp',
                        label: 'XP',
                        isDark: isDark,
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                      _buildStat(
                        emoji: currentLeague.emoji,
                        value: currentLeague.name,
                        label: '',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Footer
                Text(
                  'Controle suas finanças',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[600] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat({
    IconData? icon,
    String? emoji,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (emoji != null)
          Text(emoji, style: const TextStyle(fontSize: 20))
        else if (icon != null)
          Icon(icon, size: 20, color: isDark ? Colors.white54 : Colors.black45),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        if (label.isNotEmpty)
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
      ],
    );
  }
}

/// Minimalist story card for league promotion
class LeagueUpStoryCard extends StatelessWidget {
  final RankingLeague previousLeague;
  final RankingLeague newLeague;
  final int totalXp;
  final String userName;
  final GlobalKey repaintBoundaryKey;

  const LeagueUpStoryCard({
    super.key,
    required this.previousLeague,
    required this.newLeague,
    required this.totalXp,
    required this.userName,
    required this.repaintBoundaryKey,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final leagueColor = Color(newLeague.color);

    return RepaintBoundary(
      key: repaintBoundaryKey,
      child: Container(
        width: 360,
        height: 640,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header with logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 32,
                        width: 32,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.account_balance_wallet,
                            size: 32,
                            color: AppTheme.primaryColor,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Nexxo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 2),

                // League up label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: leagueColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'SUBIU DE LIGA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: leagueColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // League transition
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Previous league
                    Opacity(
                      opacity: 0.4,
                      child: Column(
                        children: [
                          Text(
                            previousLeague.emoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            previousLeague.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 32,
                        color: leagueColor,
                      ),
                    ),

                    // New league
                    Column(
                      children: [
                        Text(
                          newLeague.emoji,
                          style: const TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          newLeague.name,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: leagueColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // User name
                Text(
                  userName.isNotEmpty ? userName.split(' ').first : 'Usuário',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '$totalXp XP total',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),

                const Spacer(flex: 2),

                // Footer
                Text(
                  'Controle suas finanças',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[600] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Minimalist story card for mission completed
class MissionStoryCard extends StatelessWidget {
  final WeeklyMission mission;
  final int totalXp;
  final RankingLeague currentLeague;
  final String userName;
  final GlobalKey repaintBoundaryKey;

  const MissionStoryCard({
    super.key,
    required this.mission,
    required this.totalXp,
    required this.currentLeague,
    required this.userName,
    required this.repaintBoundaryKey,
  });

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final difficultyColor = Color(mission.difficulty.color);

    return RepaintBoundary(
      key: repaintBoundaryKey,
      child: Container(
        width: 360,
        height: 640,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header with logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 32,
                        width: 32,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.account_balance_wallet,
                            size: 32,
                            color: AppTheme.primaryColor,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Nexxo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 2),

                // Mission icon
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withValues(alpha: 0.1),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(_getMissionIcon(), size: 64, color: Colors.green),
                ),

                const SizedBox(height: 32),

                // Mission complete label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'MISSÃO COMPLETA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Mission title
                Text(
                  mission.missionType.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 12),

                // Difficulty badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: difficultyColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    mission.difficulty.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: difficultyColor,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // XP badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        difficultyColor,
                        difficultyColor.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${mission.missionType.xpReward} XP',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // User info
                Text(
                  userName.isNotEmpty ? userName.split(' ').first : 'Usuário',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentLeague.emoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${currentLeague.name} • $totalXp XP',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Footer
                Text(
                  'Controle suas finanças',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[600] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Minimalist story card for sharing ranking status
class RankingStoryCard extends StatelessWidget {
  final int totalXp;
  final RankingLeague currentLeague;
  final int currentStreak;
  final int longestStreak;
  final String userName;
  final GlobalKey repaintBoundaryKey;

  const RankingStoryCard({
    super.key,
    required this.totalXp,
    required this.currentLeague,
    required this.currentStreak,
    required this.longestStreak,
    required this.userName,
    required this.repaintBoundaryKey,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final leagueColor = Color(currentLeague.color);

    return RepaintBoundary(
      key: repaintBoundaryKey,
      child: Container(
        width: 360,
        height: 640,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header with logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 28,
                        width: 28,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.account_balance_wallet,
                            size: 28,
                            color: AppTheme.primaryColor,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Nexxo',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // League emoji with glow
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: leagueColor.withValues(alpha: 0.1),
                    border: Border.all(
                      color: leagueColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    currentLeague.emoji,
                    style: const TextStyle(fontSize: 56),
                  ),
                ),

                const SizedBox(height: 16),

                // Ranking label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: leagueColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'MEU RANKING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: leagueColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // League name
                Text(
                  'Liga ${currentLeague.name}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: leagueColor,
                  ),
                ),

                const SizedBox(height: 20),

                // XP badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [leagueColor, leagueColor.withValues(alpha: 0.8)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$totalXp XP',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Stats section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat(
                        icon: Icons.person_outline,
                        value: userName.isNotEmpty
                            ? userName.split(' ').first
                            : 'Usuário',
                        label: '',
                        isDark: isDark,
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                      _buildStat(
                        icon: Icons.local_fire_department,
                        value: '$currentStreak',
                        label: 'dias',
                        isDark: isDark,
                        iconColor: Colors.orange,
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                      _buildStat(
                        icon: Icons.emoji_events,
                        value: '$longestStreak',
                        label: 'recorde',
                        isDark: isDark,
                        iconColor: Colors.amber,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Footer
                Text(
                  'Controle suas finanças',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[600] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
    required bool isDark,
    Color? iconColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: iconColor ?? (isDark ? Colors.white54 : Colors.black45),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        if (label.isNotEmpty)
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
      ],
    );
  }
}
