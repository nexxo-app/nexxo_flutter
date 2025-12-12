// Achievement Story Dialogs for Nexxo
// Modern, story-style dialogs with share functionality

import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/services/web_share_service.dart';
import '../../../data/models/ranking_models.dart';
import '../../widgets/glass_container.dart';

/// Full-screen story dialog for achievement unlocked
class AchievementStoryDialog extends StatefulWidget {
  final Achievement achievement;
  final int totalXp;
  final RankingLeague currentLeague;
  final VoidCallback? onDismiss;

  const AchievementStoryDialog({
    super.key,
    required this.achievement,
    required this.totalXp,
    required this.currentLeague,
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required Achievement achievement,
    required int totalXp,
    required RankingLeague currentLeague,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (context) => AchievementStoryDialog(
        achievement: achievement,
        totalXp: totalXp,
        currentLeague: currentLeague,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  State<AchievementStoryDialog> createState() => _AchievementStoryDialogState();
}

class _AchievementStoryDialogState extends State<AchievementStoryDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

  Future<void> _handleShare() async {
    setState(() => _isSharing = true);

    final shareService = WebShareService.instance;
    final shareText = shareService.createAchievementShareText(
      achievementName: widget.achievement.name,
      xpReward: widget.achievement.xpReward,
      totalXp: widget.totalXp,
      leagueName: widget.currentLeague.name,
    );

    await shareService.share(
      title: 'Nexxo - Conquista Desbloqueada!',
      text: shareText,
      url: 'https://vinis-moraes.github.io/nexxo-web/',
    );

    setState(() => _isSharing = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(scale: _scaleAnimation.value, child: child),
        );
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.amber.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.4),
                      Colors.amber.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with sparkles
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.amber, Colors.white, Colors.amber],
                        ).createShader(bounds),
                        child: const Text(
                          '✨ CONQUISTA DESBLOQUEADA ✨',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Achievement icon with glow
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber.withValues(alpha: 0.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.4),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _getIconData(widget.achievement.icon),
                          size: 64,
                          color: Colors.amber,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Achievement name
                      Text(
                        widget.achievement.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        widget.achievement.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),

                      const SizedBox(height: 24),

                      // XP reward badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade700,
                              Colors.amber.shade500,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+${widget.achievement.xpReward} XP',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Stats card
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                const Icon(
                                  Icons.analytics_outlined,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.totalXp}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'XP Total',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white24,
                            ),
                            Column(
                              children: [
                                Text(
                                  widget.currentLeague.emoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.currentLeague.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(widget.currentLeague.color),
                                  ),
                                ),
                                Text(
                                  'Liga',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Share button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSharing ? null : _handleShare,
                          icon: _isSharing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.share_rounded),
                          label: Text(
                            _isSharing ? 'Compartilhando...' : 'Compartilhar',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Continue button
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onDismiss?.call();
                        },
                        child: const Text(
                          'Continuar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen story dialog for league promotion
class LeagueUpStoryDialog extends StatefulWidget {
  final RankingLeague previousLeague;
  final RankingLeague newLeague;
  final int totalXp;
  final VoidCallback? onDismiss;

  const LeagueUpStoryDialog({
    super.key,
    required this.previousLeague,
    required this.newLeague,
    required this.totalXp,
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required RankingLeague previousLeague,
    required RankingLeague newLeague,
    required int totalXp,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) => LeagueUpStoryDialog(
        previousLeague: previousLeague,
        newLeague: newLeague,
        totalXp: totalXp,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  State<LeagueUpStoryDialog> createState() => _LeagueUpStoryDialogState();
}

class _LeagueUpStoryDialogState extends State<LeagueUpStoryDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleShare() async {
    setState(() => _isSharing = true);

    final shareService = WebShareService.instance;
    final shareText = shareService.createLeagueUpShareText(
      previousLeague: widget.previousLeague.name,
      newLeague: widget.newLeague.name,
      newLeagueEmoji: widget.newLeague.emoji,
      totalXp: widget.totalXp,
    );

    await shareService.share(
      title: 'Nexxo - Subi de Liga!',
      text: shareText,
      url: 'https://vinis-moraes.github.io/nexxo-web/',
    );

    setState(() => _isSharing = false);
  }

  @override
  Widget build(BuildContext context) {
    final leagueColor = Color(widget.newLeague.color);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(scale: _scaleAnimation.value, child: child),
        );
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      leagueColor.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.4),
                      leagueColor.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: leagueColor.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [leagueColor, Colors.white, leagueColor],
                        ).createShader(bounds),
                        child: const Text(
                          '🎉 SUBIU DE LIGA! 🎉',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // League transition
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Previous league
                          Column(
                            children: [
                              Text(
                                widget.previousLeague.emoji,
                                style: const TextStyle(fontSize: 40),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.previousLeague.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),

                          // Arrow
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 40,
                              color: leagueColor,
                            ),
                          ),

                          // New league with pulse
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + (_pulseController.value * 0.1),
                                child: child,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: leagueColor.withValues(alpha: 0.5),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    widget.newLeague.emoji,
                                    style: const TextStyle(fontSize: 64),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.newLeague.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: leagueColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Stats
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.analytics_outlined,
                              color: Colors.white70,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${widget.totalXp} XP Total',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Parabéns! Continue sua jornada financeira!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),

                      const SizedBox(height: 24),

                      // Share button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSharing ? null : _handleShare,
                          icon: _isSharing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.share_rounded),
                          label: Text(
                            _isSharing ? 'Compartilhando...' : 'Compartilhar',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: leagueColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Continue button
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onDismiss?.call();
                        },
                        child: const Text(
                          'Continuar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen story dialog for mission completed
class MissionStoryDialog extends StatefulWidget {
  final WeeklyMission mission;
  final int totalXp;
  final RankingLeague currentLeague;
  final VoidCallback? onDismiss;

  const MissionStoryDialog({
    super.key,
    required this.mission,
    required this.totalXp,
    required this.currentLeague,
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required WeeklyMission mission,
    required int totalXp,
    required RankingLeague currentLeague,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (context) => MissionStoryDialog(
        mission: mission,
        totalXp: totalXp,
        currentLeague: currentLeague,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  State<MissionStoryDialog> createState() => _MissionStoryDialogState();
}

class _MissionStoryDialogState extends State<MissionStoryDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getMissionIcon() {
    switch (widget.mission.missionType) {
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

  Future<void> _handleShare() async {
    setState(() => _isSharing = true);

    final shareService = WebShareService.instance;
    final shareText = shareService.createMissionShareText(
      missionTitle: widget.mission.missionType.title,
      xpReward: widget.mission.missionType.xpReward,
      totalXp: widget.totalXp,
      leagueName: widget.currentLeague.name,
    );

    await shareService.share(
      title: 'Nexxo - Missão Completa!',
      text: shareText,
      url: 'https://vinis-moraes.github.io/nexxo-web/',
    );

    setState(() => _isSharing = false);
  }

  @override
  Widget build(BuildContext context) {
    final difficultyColor = Color(widget.mission.difficulty.color);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(scale: _scaleAnimation.value, child: child),
        );
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.4),
                      difficultyColor.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      const Text(
                        '✅ MISSÃO COMPLETA! ✅',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Mission icon with glow
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.withValues(alpha: 0.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.4),
                              blurRadius: 30,
                              spreadRadius: 8,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _getMissionIcon(),
                          size: 56,
                          color: Colors.green,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Mission title
                      Text(
                        widget.mission.missionType.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Difficulty badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: difficultyColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: difficultyColor.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          widget.mission.difficulty.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: difficultyColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // XP reward badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              difficultyColor,
                              difficultyColor.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: difficultyColor.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+${widget.mission.missionType.xpReward} XP',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Stats card
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                const Icon(
                                  Icons.analytics_outlined,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.totalXp}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'XP Total',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white24,
                            ),
                            Column(
                              children: [
                                Text(
                                  widget.currentLeague.emoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.currentLeague.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(widget.currentLeague.color),
                                  ),
                                ),
                                Text(
                                  'Liga',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Share button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSharing ? null : _handleShare,
                          icon: _isSharing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.share_rounded),
                          label: Text(
                            _isSharing ? 'Compartilhando...' : 'Compartilhar',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Continue button
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onDismiss?.call();
                        },
                        child: const Text(
                          'Continuar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
