import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/sound_manager.dart';
import '../../../core/services/web_share_service.dart';
import '../../../core/services/story_image_service.dart';
import '../../../data/models/ranking_models.dart';
import '../../../data/repositories/supabase_repository.dart';
import '../../widgets/glass_container.dart';
import 'widgets/ranking_widgets.dart';
import 'achievement_story.dart';
import 'story_cards.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with SingleTickerProviderStateMixin {
  final SupabaseRepository _repository = SupabaseRepository();
  final SoundManager _soundManager = SoundManager();
  late TabController _tabController;

  UserRanking? _userRanking;
  RankingLeague? _previousLeague;
  List<WeeklyMission> _missions = [];
  List<WeeklyMission> _previousMissions = [];
  bool _isLoading = true;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Store previous state for comparison
      _previousLeague = _userRanking?.currentLeague;
      _previousMissions = List.from(_missions);

      final ranking = await _repository.getUserRanking();

      // Load user profile for name
      final profile = await _repository.getProfile();

      // Update streak on app open
      await _repository.updateStreak();

      // Check and update missions
      await _repository.checkAndUpdateMissions();

      // Reload missions after check
      final updatedMissions = await _repository.getWeeklyMissions();

      setState(() {
        _userRanking = ranking;
        _missions = updatedMissions;
        _userName = profile?.fullName ?? profile?.email ?? '';
        _isLoading = false;
      });

      // Check for newly completed missions and show celebration
      _checkForCompletedMissions(updatedMissions);

      // Check for level up
      if (_previousLeague != null && ranking != null) {
        if (ranking.currentLeague.index > _previousLeague!.index) {
          _showLevelUpCelebration(_previousLeague!, ranking.currentLeague);
        }
      }

      // Check and unlock achievements
      final unlockedAchievements = await _repository
          .checkAndUnlockAchievements();
      for (final achievement in unlockedAchievements) {
        _showAchievementUnlockedNotification(achievement);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading ranking data: $e');
    }
  }

  void _showAchievementUnlockedNotification(Achievement achievement) {
    if (!mounted) return;

    // Show story dialog for achievement
    _soundManager.playLevelUp();
    AchievementStoryDialog.show(
      context,
      achievement: achievement,
      totalXp: _userRanking?.totalXp ?? 0,
      currentLeague: _userRanking?.currentLeague ?? RankingLeague.bronze,
      onDismiss: () {
        _loadData(); // Refresh data
      },
    );
  }

  void _checkForCompletedMissions(List<WeeklyMission> currentMissions) {
    for (final mission in currentMissions) {
      // Find matching previous mission
      final previousMission = _previousMissions
          .where((m) => m.id == mission.id)
          .firstOrNull;

      // If mission was not completed before but is now
      if (previousMission != null &&
          !previousMission.isCompleted &&
          mission.isCompleted) {
        _showMissionCompleteCelebration(mission);
        break; // Show one at a time
      }
    }
  }

  void _showMissionCompleteCelebration(WeeklyMission mission) {
    _soundManager.playMissionComplete();
    MissionStoryDialog.show(
      context,
      mission: mission,
      totalXp: _userRanking?.totalXp ?? 0,
      currentLeague: _userRanking?.currentLeague ?? RankingLeague.bronze,
      onDismiss: () {
        _loadData(); // Refresh data
      },
    );
  }

  void _showLevelUpCelebration(
    RankingLeague previous,
    RankingLeague newLeague,
  ) {
    _soundManager.playLevelUp();
    LeagueUpStoryDialog.show(
      context,
      previousLeague: previous,
      newLeague: newLeague,
      totalXp: _userRanking?.totalXp ?? 0,
      onDismiss: () {
        _loadData(); // Refresh data
      },
    );
  }

  Future<void> _shareRanking() async {
    if (_userRanking == null) return;

    final storyKey = GlobalKey();
    OverlayEntry? overlayEntry;

    // Create offscreen widget to capture
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: -2000,
        top: -2000,
        child: Material(
          color: Colors.transparent,
          child: RankingStoryCard(
            totalXp: _userRanking!.totalXp,
            currentLeague: _userRanking!.currentLeague,
            currentStreak: _userRanking!.currentStreak,
            longestStreak: _userRanking!.longestStreak,
            userName: _userName,
            repaintBoundaryKey: storyKey,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    await Future.delayed(const Duration(milliseconds: 200));

    // Capture the story as image
    final imageService = StoryImageService.instance;
    final imageBytes = await imageService.captureWidget(storyKey);

    // Remove overlay
    overlayEntry.remove();

    if (imageBytes != null) {
      final shareText =
          '''🏆 Meu Ranking no Nexxo!

${_userRanking!.currentLeague.emoji} Liga ${_userRanking!.currentLeague.name}
⭐ ${_userRanking!.totalXp} XP
🔥 ${_userRanking!.currentStreak} dias de streak

Controle suas finanças com o Nexxo!''';

      await imageService.shareImage(
        imageBytes: imageBytes,
        fileName: 'nexxo_ranking.png',
        title: 'Nexxo - Meu Ranking',
        text: shareText,
      );
    } else {
      // Fallback to text share
      final shareService = WebShareService.instance;
      await shareService.share(
        title: 'Nexxo - Meu Ranking',
        text:
            '''🏆 Meu Ranking no Nexxo!

${_userRanking!.currentLeague.emoji} Liga ${_userRanking!.currentLeague.name}
⭐ ${_userRanking!.totalXp} XP
🔥 ${_userRanking!.currentStreak} dias de streak

Controle suas finanças com o Nexxo!''',
        url: 'https://vinis-moraes.github.io/nexxo-web/',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () {
              // Navigate to achievements
              _showAchievementsDialog();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Ranking', icon: Icon(Icons.leaderboard)),
            Tab(text: 'Missões', icon: Icon(Icons.flag)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildRankingTab(), _buildMissionsTab()],
            ),
    );
  }

  Widget _buildRankingTab() {
    if (_userRanking == null) {
      return const Center(child: Text('Erro ao carregar ranking'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // XP Progress Card
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  XpProgressBar(
                    currentXp: _userRanking!.totalXp,
                    targetXp:
                        _userRanking!.currentLeague.nextLeague?.minXp ??
                        _userRanking!.totalXp,
                    currentLeague: _userRanking!.currentLeague,
                    nextLeague: _userRanking!.currentLeague.nextLeague,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _shareRanking,
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Compartilhar Ranking'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(
                          _userRanking!.currentLeague.color,
                        ),
                        side: BorderSide(
                          color: Color(
                            _userRanking!.currentLeague.color,
                          ).withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Streak Card
            StreakCard(
              currentStreak: _userRanking!.currentStreak,
              longestStreak: _userRanking!.longestStreak,
            ),

            const SizedBox(height: 24),

            // Leagues Section
            Text(
              'Ligas',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: RankingLeague.values.length,
                itemBuilder: (context, index) {
                  final league = RankingLeague.values[index];
                  final isCurrentLeague = league == _userRanking!.currentLeague;
                  final isUnlocked = _userRanking!.totalXp >= league.minXp;

                  return LeagueCard(
                    league: league,
                    isCurrentLeague: isCurrentLeague,
                    isUnlocked: isUnlocked,
                    onTap: () => _showLeagueDetails(league),
                  );
                },
              ),
            ),

            const SizedBox(height: 100), // Bottom padding for nav bar
          ],
        ),
      ),
    );
  }

  Widget _buildMissionsTab() {
    final activeMissions = _missions.where((m) => !m.isCompleted).toList();
    final completedMissions = _missions.where((m) => m.isCompleted).toList();

    // Calculate weekly reset time
    final now = DateTime.now();
    final daysUntilMonday = (8 - now.weekday) % 7;
    final nextMonday = now.add(
      Duration(days: daysUntilMonday == 0 ? 7 : daysUntilMonday),
    );
    final resetTime = DateTime(
      nextMonday.year,
      nextMonday.month,
      nextMonday.day,
    );
    final timeRemaining = resetTime.difference(now);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly Reset Timer
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.timer,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Missões Semanais',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Reinicia em ${timeRemaining.inDays}d ${timeRemaining.inHours % 24}h',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${completedMissions.length}/${_missions.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Active Missions
            if (activeMissions.isNotEmpty) ...[
              Text(
                'Missões Ativas',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...activeMissions.map((mission) => MissionCard(mission: mission)),
              const SizedBox(height: 24),
            ],

            // Completed Missions
            if (completedMissions.isNotEmpty) ...[
              Row(
                children: [
                  Text(
                    'Completas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${completedMissions.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...completedMissions.map(
                (mission) => MissionCard(mission: mission),
              ),
            ],

            if (_missions.isEmpty)
              GlassContainer(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhuma missão disponível',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 100), // Bottom padding for nav bar
          ],
        ),
      ),
    );
  }

  void _showLeagueDetails(RankingLeague league) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(league.emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'Liga ${league.name}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${league.minXp} - ${league.maxXp} XP',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(league.color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _userRanking!.totalXp >= league.minXp
                        ? Icons.check_circle
                        : Icons.lock,
                    color: _userRanking!.totalXp >= league.minXp
                        ? Colors.green
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _userRanking!.totalXp >= league.minXp
                        ? 'Liga Desbloqueada!'
                        : 'Faltam ${league.minXp - _userRanking!.totalXp} XP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _userRanking!.totalXp >= league.minXp
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAchievementsDialog() async {
    final achievements = await _repository.getAchievements();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true, // Renderiza acima do bottom nav bar
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '🏆 Conquistas',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${achievements.where((a) => a.isUnlocked).length}/${achievements.length} desbloqueadas',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    return _buildAchievementCard(achievement);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData getIconData(String iconName) {
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

    return GestureDetector(
      onTap: () => _showAchievementDetails(achievement, getIconData),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: achievement.isUnlocked
              ? Colors.amber.withValues(alpha: 0.15)
              : (isDark ? Colors.grey[900] : Colors.grey[100]),
          border: achievement.isUnlocked
              ? Border.all(color: Colors.amber, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              getIconData(achievement.icon),
              size: 32,
              color: achievement.isUnlocked ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              achievement.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: achievement.isUnlocked
                    ? (isDark ? Colors.white : Colors.black87)
                    : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '+${achievement.xpReward} XP',
              style: TextStyle(
                fontSize: 10,
                color: achievement.isUnlocked ? Colors.amber : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetails(
    Achievement achievement,
    IconData Function(String) getIconData,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => _AchievementDetailsDialog(
        achievement: achievement,
        getIconData: getIconData,
        isDark: isDark,
        totalXp: _userRanking?.totalXp ?? 0,
        currentLeague: _userRanking?.currentLeague ?? RankingLeague.bronze,
        userName: _userName,
      ),
    );
  }
}

// Separate StatefulWidget for achievement details with share functionality
class _AchievementDetailsDialog extends StatefulWidget {
  final Achievement achievement;
  final IconData Function(String) getIconData;
  final bool isDark;
  final int totalXp;
  final RankingLeague currentLeague;
  final String userName;

  const _AchievementDetailsDialog({
    required this.achievement,
    required this.getIconData,
    required this.isDark,
    required this.totalXp,
    required this.currentLeague,
    required this.userName,
  });

  @override
  State<_AchievementDetailsDialog> createState() =>
      _AchievementDetailsDialogState();
}

class _AchievementDetailsDialogState extends State<_AchievementDetailsDialog> {
  bool _isSharing = false;
  final GlobalKey _storyKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  Future<void> _handleShare() async {
    setState(() => _isSharing = true);

    try {
      // Create an offscreen story card to capture
      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: -2000, // Off-screen
          top: -2000,
          child: Material(
            color: Colors.transparent,
            child: AchievementStoryCard(
              achievement: widget.achievement,
              totalXp: widget.totalXp,
              currentLeague: widget.currentLeague,
              userName: widget.userName,
              repaintBoundaryKey: _storyKey,
            ),
          ),
        ),
      );

      Overlay.of(context).insert(_overlayEntry!);
      await Future.delayed(const Duration(milliseconds: 200));

      // Capture the story as image
      final imageService = StoryImageService.instance;
      final imageBytes = await imageService.captureWidget(_storyKey);

      // Remove overlay
      _overlayEntry?.remove();
      _overlayEntry = null;

      if (imageBytes != null) {
        // Share with image
        final shareService = WebShareService.instance;
        final shareText = shareService.createAchievementShareText(
          achievementName: widget.achievement.name,
          xpReward: widget.achievement.xpReward,
          totalXp: widget.totalXp,
          leagueName: widget.currentLeague.name,
        );

        await imageService.shareImage(
          imageBytes: imageBytes,
          fileName:
              'nexxo_conquista_${DateTime.now().millisecondsSinceEpoch}.png',
          title: 'Nexxo - Minha Conquista!',
          text: shareText,
        );
      }
    } catch (e) {
      debugPrint('Error sharing: $e');
      _overlayEntry?.remove();
      _overlayEntry = null;
    }

    if (mounted) {
      setState(() => _isSharing = false);
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final achievement = widget.achievement;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with glow effect
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: achievement.isUnlocked
                    ? Colors.amber.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.1),
                boxShadow: achievement.isUnlocked
                    ? [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ]
                    : null,
                border: achievement.isUnlocked
                    ? Border.all(
                        color: Colors.amber.withValues(alpha: 0.5),
                        width: 2,
                      )
                    : null,
              ),
              child: Icon(
                widget.getIconData(achievement.icon),
                size: 48,
                color: achievement.isUnlocked ? Colors.amber : Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: achievement.isUnlocked
                    ? Colors.green.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: achievement.isUnlocked
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                achievement.isUnlocked ? '✓ Desbloqueada' : '🔒 Bloqueada',
                style: TextStyle(
                  color: achievement.isUnlocked ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              achievement.name,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Category
            Text(
              achievement.categoryName,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.isDark ? Colors.grey[300] : Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            // XP reward
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade700, Colors.amber.shade500],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
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

            // Unlocked date if applicable
            if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
              const SizedBox(height: 12),
              Text(
                'Desbloqueada em ${_formatDate(achievement.unlockedAt!)}',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],

            const SizedBox(height: 20),

            // Share button (only for unlocked achievements)
            if (achievement.isUnlocked) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSharing ? null : _handleShare,
                  icon: _isSharing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.share_rounded, size: 18),
                  label: Text(
                    _isSharing ? 'Compartilhando...' : 'Compartilhar Conquista',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Close button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Fechar',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
