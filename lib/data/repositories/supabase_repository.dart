import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/supabase_models.dart';
import '../models/ranking_models.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint

class SupabaseRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // --- Authentication ---

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  Future<AuthResponse> signUp(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      return await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
    } catch (e) {
      throw Exception('Erro ao cadastrar: $e');
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Erro ao enviar email de recuperação: $e');
    }
  }

  // --- Data Fetching ---

  Future<Profile?> getProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return Profile.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return null;
    }
  }

  Future<List<TransactionModel>> getRecentTransactions() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final data = await _client
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false)
          .limit(5);

      return (data as List).map((e) => TransactionModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      return [];
    }
  }

  Future<UserStreak?> getUserStreak() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final data = await _client
          .from('user_streaks')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) return UserStreak(currentStreak: 0, longestStreak: 0);

      return UserStreak.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching streak: $e');
      return null;
    }
  }

  Future<Map<String, double>> getFinancialSummary() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return {'balance': 0.0, 'income': 0.0, 'expense': 0.0};
      }

      // This is a simplified calculation. Ideally, use Supabase RPC or aggregate queries.
      final transactions = await _client
          .from('transactions')
          .select('amount, type')
          .eq('user_id', userId);

      double income = 0.0;
      double expense = 0.0;

      for (var t in transactions) {
        final amount = (t['amount'] as num).toDouble();
        if (t['type'] == 'income') {
          income += amount;
        } else {
          expense += amount;
        }
      }

      return {
        'balance': income - expense,
        'income': income,
        'expense': expense,
      };
    } catch (e) {
      return {'balance': 0.0, 'income': 0.0, 'expense': 0.0};
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _client.from('transactions').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar transação: $e');
    }
  }

  // Get financial summary filtered by month
  Future<Map<String, double>> getFinancialSummaryByMonth(
    int year,
    int month,
  ) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return {'balance': 0.0, 'income': 0.0, 'expense': 0.0};
      }

      // Calculate date range for the month
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(
        year,
        month + 1,
        0,
        23,
        59,
        59,
      ); // Last day of month

      final transactions = await _client
          .from('transactions')
          .select('amount, type')
          .eq('user_id', userId)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String());

      double income = 0.0;
      double expense = 0.0;

      for (var t in transactions) {
        final amount = (t['amount'] as num).toDouble();
        if (t['type'] == 'income') {
          income += amount;
        } else {
          expense += amount;
        }
      }

      return {
        'balance': income - expense,
        'income': income,
        'expense': expense,
      };
    } catch (e) {
      debugPrint('Error fetching monthly summary: $e');
      return {'balance': 0.0, 'income': 0.0, 'expense': 0.0};
    }
  }

  // Get transactions filtered by month
  Future<List<TransactionModel>> getTransactionsByMonth(
    int year,
    int month,
  ) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      // Calculate date range for the month
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(
        year,
        month + 1,
        0,
        23,
        59,
        59,
      ); // Last day of month

      final data = await _client
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String())
          .order('date', ascending: false);

      return (data as List).map((e) => TransactionModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching monthly transactions: $e');
      return [];
    }
  }

  // --- Savings ---

  Future<List<SavingsGoal>> getSavingsGoals() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final data = await _client
          .from('savings_goals')
          .select()
          .eq('user_id', userId);

      return (data as List).map((e) => SavingsGoal.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching savings goals: $e');
      return [];
    }
  }

  Future<void> addSavingsGoal({
    required String title,
    required double targetAmount,
    required double currentAmount,
    required DateTime? deadline,
    required String icon,
    required String color,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      await _client.from('savings_goals').insert({
        'user_id': userId,
        'title': title,
        'target_amount': targetAmount,
        'current_amount': currentAmount,
        'deadline': deadline?.toIso8601String(),
        'icon': icon,
        'color': color,
      });
    } catch (e) {
      throw Exception('Erro ao adicionar meta: $e');
    }
  }

  Future<void> deleteSavingsGoal(String id) async {
    try {
      await _client.from('savings_goals').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar meta: $e');
    }
  }

  Future<void> updateSavingsGoal({
    required String id,
    required String title,
    required double targetAmount,
    required double currentAmount,
    required DateTime? deadline,
    required String icon,
    required String color,
  }) async {
    try {
      await _client
          .from('savings_goals')
          .update({
            'title': title,
            'target_amount': targetAmount,
            'current_amount': currentAmount,
            'deadline': deadline?.toIso8601String(),
            'icon': icon,
            'color': color,
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao atualizar meta: $e');
    }
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required String type,
    required String category,
    required DateTime date,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      await _client.from('transactions').insert({
        'user_id': userId,
        'title': title,
        'amount': amount,
        'type': type,
        'category': category,
        'date': date.toIso8601String(),
      });

      // Update missions progress after creating transaction
      await _updateMissionsForTransaction(type, amount, category);

      // Add base XP for creating a transaction
      await addXp(5); // 5 XP per transaction
    } catch (e) {
      throw Exception('Erro ao salvar transação: $e');
    }
  }

  /// Update mission progress based on transaction creation
  Future<void> _updateMissionsForTransaction(
    String type,
    double amount,
    String category,
  ) async {
    try {
      final missions = await getWeeklyMissions();

      for (final mission in missions) {
        if (mission.isCompleted) continue;

        double newValue = mission.currentValue;

        switch (mission.missionType) {
          case MissionType.registerExpenseDaily:
            if (type == 'expense') {
              newValue = mission.currentValue + 1;
            }
            break;

          case MissionType.registerAllExpenses7Days:
            if (type == 'expense') {
              newValue = mission.currentValue + 1;
            }
            break;

          case MissionType.categorizeAllTransactions:
            // Increment for any categorized transaction
            newValue = mission.currentValue + 1;
            break;

          default:
            // Other missions are handled by checkAndUpdateMissions
            break;
        }

        if (newValue != mission.currentValue) {
          await updateMissionProgress(mission.id, newValue);
        }
      }
    } catch (e) {
      debugPrint('Error updating missions for transaction: $e');
    }
  }

  Future<void> updateTransaction({
    required String id,
    required String title,
    required double amount,
    required String type,
    required String category,
    required DateTime date,
  }) async {
    try {
      await _client
          .from('transactions')
          .update({
            'title': title,
            'amount': amount,
            'type': type,
            'category': category,
            'date': date.toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao atualizar transação: $e');
    }
  }

  Future<void> updateProfile({required String fullName}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      await _client
          .from('profiles')
          .update({'full_name': fullName})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Erro ao atualizar perfil: $e');
    }
  }

  Future<void> updateHasImportedBalance(bool value) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      await _client
          .from('profiles')
          .update({'has_imported_balance': value})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Erro ao atualizar status de saldo importado: $e');
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final userId = _client.auth.currentUser?.id;

      // 1. Fetch Categories
      var query = _client.from('categories').select();
      if (userId != null) {
        query = query.or('user_id.is.null,user_id.eq.$userId');
      } else {
        query = query.filter('user_id', 'is', 'null');
      }
      final categoriesData = await query;
      final categories = (categoriesData as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();

      // 2. Fetch User Budgets
      if (userId != null) {
        final budgetsData = await _client
            .from('category_budgets')
            .select()
            .eq('user_id', userId);

        // Map category_id -> budget_percent
        final budgetMap = {
          for (var b in (budgetsData as List))
            b['category_id'] as String: (b['budget_limit_percent'] as num)
                .toDouble(),
        };

        // 3. Merge
        return categories.map((cat) {
          return CategoryModel(
            id: cat.id,
            name: cat.name,
            type: cat.type,
            icon: cat.icon,
            color: cat.color,
            budgetLimitPercent:
                budgetMap[cat.id] ?? 0, // Default to 0 if not set
          );
        }).toList();
      }

      return categories;
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  /// Updates the budget limit for a specific category using the dedicated table.
  Future<void> updateCategoryBudget(
    String categoryId,
    double newLimitPercent,
  ) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Uses UPSERT logic (on_conflict)
      await _client.from('category_budgets').upsert(
        {
          'user_id': userId,
          'category_id': categoryId,
          'budget_limit_percent': newLimitPercent,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id, category_id', // Matches the unique constraint
      );
    } catch (e) {
      debugPrint('Error updating category budget: $e');
      rethrow;
    }
  }

  // --- Ranking System ---

  /// Get or create user ranking
  Future<UserRanking?> getUserRanking() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      var data = await _client
          .from('user_rankings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      // Create ranking if doesn't exist
      if (data == null) {
        await _client.from('user_rankings').insert({
          'user_id': userId,
          'total_xp': 0,
          'monthly_xp': 0,
          'current_streak': 0,
          'longest_streak': 0,
        });

        data = await _client
            .from('user_rankings')
            .select()
            .eq('user_id', userId)
            .single();
      }

      return UserRanking.fromJson(data);
    } catch (e) {
      debugPrint('Error fetching user ranking: $e');
      return null;
    }
  }

  /// Add XP to user
  Future<void> addXp(int xpAmount) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final current = await getUserRanking();
      final newTotalXp = (current?.totalXp ?? 0) + xpAmount;
      final newMonthlyXp = (current?.monthlyXp ?? 0) + xpAmount;

      await _client
          .from('user_rankings')
          .update({
            'total_xp': newTotalXp,
            'monthly_xp': newMonthlyXp,
            'last_activity_date': DateTime.now().toIso8601String().split(
              'T',
            )[0],
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Error adding XP: $e');
      rethrow;
    }
  }

  /// Update user streak
  Future<void> updateStreak() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final ranking = await getUserRanking();
      if (ranking == null) return;

      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final lastActivity = ranking.lastActivityDate;

      int newStreak = ranking.currentStreak;

      if (lastActivity == null) {
        newStreak = 1;
      } else {
        final lastDate = DateTime(
          lastActivity.year,
          lastActivity.month,
          lastActivity.day,
        );
        final difference = todayDate.difference(lastDate).inDays;

        if (difference == 0) {
          // Same day, no change
          return;
        } else if (difference == 1) {
          // Consecutive day
          newStreak = ranking.currentStreak + 1;
        } else {
          // Streak broken
          newStreak = 1;
        }
      }

      final newLongestStreak = newStreak > ranking.currentStreak
          ? newStreak
          : ranking.currentStreak;

      await _client
          .from('user_rankings')
          .update({
            'current_streak': newStreak,
            'longest_streak': newLongestStreak > (ranking.longestStreak)
                ? newLongestStreak
                : ranking.longestStreak,
            'last_activity_date': todayDate.toIso8601String().split('T')[0],
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Error updating streak: $e');
    }
  }

  /// Get leaderboard for a specific league
  Future<List<LeaderboardEntry>> getLeaderboard(
    RankingLeague league, {
    int limit = 10,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;

      // Fetch rankings
      final data = await _client
          .from('user_rankings')
          .select('user_id, total_xp')
          .gte('total_xp', league.minXp)
          .lte('total_xp', league.maxXp)
          .order('total_xp', ascending: false)
          .limit(limit);

      // Fetch profiles for these users
      final userIds = (data as List)
          .map((e) => e['user_id'] as String)
          .toList();
      Map<String, Map<String, dynamic>> profilesMap = {};

      if (userIds.isNotEmpty) {
        final profiles = await _client
            .from('profiles')
            .select('id, full_name, avatar_url')
            .inFilter('id', userIds);

        for (var p in (profiles as List)) {
          profilesMap[p['id'] as String] = p;
        }
      }

      int position = 0;
      return (data as List).map((e) {
        position++;
        final odMesterId = e['user_id'] as String? ?? '';
        final profile = profilesMap[odMesterId];
        return LeaderboardEntry(
          odMesterId: odMesterId,
          userName: profile?['full_name'] ?? 'Usuário',
          avatarUrl: profile?['avatar_url'],
          totalXp: e['total_xp'] as int? ?? 0,
          rankPosition: position,
          league: league,
          isCurrentUser: odMesterId == userId,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');
      return [];
    }
  }

  /// Get global leaderboard (top users across all leagues)
  Future<List<LeaderboardEntry>> getGlobalLeaderboard({int limit = 20}) async {
    try {
      final userId = _client.auth.currentUser?.id;

      final data = await _client
          .from('user_rankings')
          .select('user_id, total_xp')
          .order('total_xp', ascending: false)
          .limit(limit);

      // Fetch profiles for these users
      final userIds = (data as List)
          .map((e) => e['user_id'] as String)
          .toList();
      Map<String, Map<String, dynamic>> profilesMap = {};

      if (userIds.isNotEmpty) {
        final profiles = await _client
            .from('profiles')
            .select('id, full_name, avatar_url')
            .inFilter('id', userIds);

        for (var p in (profiles as List)) {
          profilesMap[p['id'] as String] = p;
        }
      }

      int position = 0;
      return (data as List).map((e) {
        position++;
        final xp = e['total_xp'] as int? ?? 0;
        final odMesterId = e['user_id'] as String? ?? '';
        final profile = profilesMap[odMesterId];
        return LeaderboardEntry(
          odMesterId: odMesterId,
          userName: profile?['full_name'] ?? 'Usuário',
          avatarUrl: profile?['avatar_url'],
          totalXp: xp,
          rankPosition: position,
          league: RankingLeague.fromXp(xp),
          isCurrentUser: odMesterId == userId,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching global leaderboard: $e');
      return [];
    }
  }

  // --- Weekly Missions ---

  /// Get all current missions (daily, weekly, monthly) for user
  Future<List<WeeklyMission>> getWeeklyMissions() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Get all active missions
      var data = await _client
          .from('weekly_missions')
          .select()
          .eq('user_id', userId)
          .gte('week_end', today.toIso8601String().split('T')[0]);

      // If no missions exist, generate them
      if ((data as List).isEmpty) {
        await _generateAllMissions();
        data = await _client
            .from('weekly_missions')
            .select()
            .eq('user_id', userId)
            .gte('week_end', today.toIso8601String().split('T')[0]);
      } else {
        // Check if we need to regenerate daily missions
        await _checkAndRegenerateDailyMissions();
      }

      return (data as List).map((e) => WeeklyMission.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching missions: $e');
      return [];
    }
  }

  /// Check and regenerate daily missions if needed
  Future<void> _checkAndRegenerateDailyMissions() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayStr = today.toIso8601String().split('T')[0];

      // Check if daily missions exist for today
      final dailyMissions = await _client
          .from('weekly_missions')
          .select()
          .eq('user_id', userId)
          .eq('week_start', todayStr);

      if ((dailyMissions as List).isEmpty) {
        await _generateDailyMissions();
      }
    } catch (e) {
      debugPrint('Error checking daily missions: $e');
    }
  }

  /// Generate all types of missions
  Future<void> _generateAllMissions() async {
    await _generateDailyMissions();
    await _generateWeeklyMissions();
    await _generateMonthlyMissions();
  }

  /// Generate daily missions (reset at midnight)
  Future<void> _generateDailyMissions() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayStr = today.toIso8601String().split('T')[0];

      // All daily missions are active today
      final dailyMissions = MissionType.values
          .where((m) => m.frequency == 'daily')
          .toList();

      for (final mission in dailyMissions) {
        await _client.from('weekly_missions').insert({
          'user_id': userId,
          'mission_type': mission.name,
          'target_value': 1.0,
          'current_value': 0.0,
          'xp_reward': mission.xpReward,
          'is_completed': false,
          'week_start': todayStr,
          'week_end': todayStr, // Daily missions end same day
        });
      }
    } catch (e) {
      debugPrint('Error generating daily missions: $e');
    }
  }

  /// Generate weekly missions (reset every Monday)
  Future<void> _generateWeeklyMissions() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final now = DateTime.now();
      // Calculate this week's Monday
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartDate = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day,
      );
      // Sunday of this week
      final weekEndDate = weekStartDate.add(const Duration(days: 6));

      final weekStartStr = weekStartDate.toIso8601String().split('T')[0];
      final weekEndStr = weekEndDate.toIso8601String().split('T')[0];

      // Select 4 random weekly missions
      final weeklyMissions =
          MissionType.values.where((m) => m.frequency == 'weekly').toList()
            ..shuffle();

      final selectedMissions = weeklyMissions.take(4).toList();

      for (final mission in selectedMissions) {
        double targetValue = _getTargetValueForMission(mission);

        await _client.from('weekly_missions').insert({
          'user_id': userId,
          'mission_type': mission.name,
          'target_value': targetValue,
          'current_value': 0.0,
          'xp_reward': mission.xpReward,
          'is_completed': false,
          'week_start': weekStartStr,
          'week_end': weekEndStr,
        });
      }
    } catch (e) {
      debugPrint('Error generating weekly missions: $e');
    }
  }

  /// Generate monthly missions (reset on 1st of each month)
  Future<void> _generateMonthlyMissions() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final now = DateTime.now();
      // First day of current month
      final monthStart = DateTime(now.year, now.month, 1);
      // Last day of current month
      final monthEnd = DateTime(now.year, now.month + 1, 0);

      final monthStartStr = monthStart.toIso8601String().split('T')[0];
      final monthEndStr = monthEnd.toIso8601String().split('T')[0];

      // Select 2 random monthly missions
      final monthlyMissions =
          MissionType.values.where((m) => m.frequency == 'monthly').toList()
            ..shuffle();

      final selectedMissions = monthlyMissions.take(2).toList();

      for (final mission in selectedMissions) {
        double targetValue = _getTargetValueForMission(mission);

        await _client.from('weekly_missions').insert({
          'user_id': userId,
          'mission_type': mission.name,
          'target_value': targetValue,
          'current_value': 0.0,
          'xp_reward': mission.xpReward,
          'is_completed': false,
          'week_start': monthStartStr,
          'week_end': monthEndStr,
        });
      }
    } catch (e) {
      debugPrint('Error generating monthly missions: $e');
    }
  }

  /// Get target value for a mission type
  double _getTargetValueForMission(MissionType mission) {
    switch (mission) {
      case MissionType.registerAllExpenses7Days:
      case MissionType.maintainStreak7Days:
      case MissionType.maintainPositiveBalance:
        return 7.0;
      case MissionType.categorizeAllTransactions:
        return 10.0; // 10 transactions
      case MissionType.reduceSpendingCategory:
        return 10.0; // 10% reduction
      case MissionType.increaseIncome:
        return 10.0; // 10% increase
      case MissionType.reduceSpending20Percent:
        return 20.0; // 20% reduction
      case MissionType.investmentGoal:
        return 100.0; // R$100
      default:
        return 1.0;
    }
  }

  /// Update mission progress
  Future<void> updateMissionProgress(String missionId, double newValue) async {
    try {
      final data = await _client
          .from('weekly_missions')
          .select()
          .eq('id', missionId)
          .single();

      final mission = WeeklyMission.fromJson(data);
      final isNowComplete =
          newValue >= mission.targetValue && !mission.isCompleted;

      await _client
          .from('weekly_missions')
          .update({
            'current_value': newValue,
            'is_completed': newValue >= mission.targetValue,
            'completed_at': isNowComplete
                ? DateTime.now().toIso8601String()
                : null,
          })
          .eq('id', missionId);

      // Award XP if just completed
      if (isNowComplete) {
        await addXp(mission.missionType.xpReward);
      }
    } catch (e) {
      debugPrint('Error updating mission progress: $e');
      rethrow;
    }
  }

  /// Complete a mission manually
  Future<void> completeMission(String missionId) async {
    try {
      final data = await _client
          .from('weekly_missions')
          .select()
          .eq('id', missionId)
          .single();

      final mission = WeeklyMission.fromJson(data);

      if (mission.isCompleted) return;

      await _client
          .from('weekly_missions')
          .update({
            'current_value': mission.targetValue,
            'is_completed': true,
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', missionId);

      await addXp(mission.missionType.xpReward);
    } catch (e) {
      debugPrint('Error completing mission: $e');
      rethrow;
    }
  }

  // --- Achievements ---

  /// Get all achievements with unlock status
  Future<List<Achievement>> getAchievements() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final achievementsData = await _client.from('achievements').select();

      final userAchievementsData = await _client
          .from('user_achievements')
          .select()
          .eq('user_id', userId);

      final unlockedIds = (userAchievementsData as List)
          .map((e) => e['achievement_id'] as String)
          .toSet();

      final userAchievementsMap = {
        for (var ua in userAchievementsData as List)
          ua['achievement_id'] as String: ua,
      };

      return (achievementsData as List).map((a) {
        final id = a['id'] as String;
        final isUnlocked = unlockedIds.contains(id);
        final ua = userAchievementsMap[id];

        return Achievement(
          id: id,
          name: a['name'] ?? '',
          description: a['description'] ?? '',
          icon: a['icon'] ?? 'emoji_events',
          xpReward: a['xp_reward'] as int? ?? 0,
          category: a['category'] ?? 'general',
          requirementType: a['requirement_type'] ?? 'general',
          requirementValue: a['requirement_value'] as int? ?? 1,
          isUnlocked: isUnlocked,
          unlockedAt: isUnlocked && ua != null
              ? DateTime.tryParse(ua['unlocked_at'] ?? '')
              : null,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching achievements: $e');
      return [];
    }
  }

  /// Unlock an achievement
  Future<void> unlockAchievement(String achievementId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Check if already unlocked
      final existing = await _client
          .from('user_achievements')
          .select()
          .eq('user_id', userId)
          .eq('achievement_id', achievementId)
          .maybeSingle();

      if (existing != null) return;

      // Unlock achievement
      await _client.from('user_achievements').insert({
        'user_id': userId,
        'achievement_id': achievementId,
      });

      // Get achievement XP reward
      final achievement = await _client
          .from('achievements')
          .select('xp_reward')
          .eq('id', achievementId)
          .single();

      await addXp(achievement['xp_reward'] as int? ?? 0);
    } catch (e) {
      debugPrint('Error unlocking achievement: $e');
      rethrow;
    }
  }

  /// Check and unlock achievements based on user progress
  Future<List<Achievement>> checkAndUnlockAchievements() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final achievements = await getAchievements();
      final ranking = await getUserRanking();
      final unlockedNow = <Achievement>[];

      // Count completed missions
      final allMissions = await _client
          .from('weekly_missions')
          .select()
          .eq('user_id', userId)
          .eq('is_completed', true);
      final completedMissionsCount = (allMissions as List).length;

      for (final achievement in achievements) {
        if (achievement.isUnlocked) continue;

        bool shouldUnlock = false;

        switch (achievement.requirementType) {
          case 'missions_completed':
            shouldUnlock =
                completedMissionsCount >= achievement.requirementValue;
            break;

          case 'xp_earned':
            shouldUnlock =
                (ranking?.totalXp ?? 0) >= achievement.requirementValue;
            break;

          case 'streak_days':
            shouldUnlock =
                (ranking?.currentStreak ?? 0) >= achievement.requirementValue ||
                (ranking?.longestStreak ?? 0) >= achievement.requirementValue;
            break;

          case 'goals_reached':
            final goals = await getSavingsGoals();
            final completedGoals = goals
                .where((g) => g.currentAmount >= g.targetAmount)
                .length;
            shouldUnlock = completedGoals >= achievement.requirementValue;
            break;

          default:
            // Other types can be added later
            break;
        }

        if (shouldUnlock) {
          await unlockAchievement(achievement.id);
          unlockedNow.add(
            Achievement(
              id: achievement.id,
              name: achievement.name,
              description: achievement.description,
              icon: achievement.icon,
              xpReward: achievement.xpReward,
              category: achievement.category,
              requirementType: achievement.requirementType,
              requirementValue: achievement.requirementValue,
              isUnlocked: true,
              unlockedAt: DateTime.now(),
            ),
          );
        }
      }

      return unlockedNow;
    } catch (e) {
      debugPrint('Error checking achievements: $e');
      return [];
    }
  }

  // --- Monthly Progression ---

  /// Get monthly progress history
  Future<List<MonthlyProgress>> getMonthlyHistory() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final data = await _client
          .from('monthly_history')
          .select()
          .eq('user_id', userId)
          .order('year', ascending: false)
          .order('month', ascending: false)
          .limit(12);

      return (data as List).map((e) => MonthlyProgress.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error fetching monthly history: $e');
      return [];
    }
  }

  /// Process end of month progression
  Future<void> processMonthlyProgression() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final ranking = await getUserRanking();
      if (ranking == null) return;

      final now = DateTime.now();
      final lastMonth = now.month == 1 ? 12 : now.month - 1;
      final lastYear = now.month == 1 ? now.year - 1 : now.year;

      // Check if we already processed this month
      final existing = await _client
          .from('monthly_history')
          .select()
          .eq('user_id', userId)
          .eq('month', lastMonth)
          .eq('year', lastYear)
          .maybeSingle();

      if (existing != null) return;

      // Get missions stats for last month
      final missions = await _client
          .from('weekly_missions')
          .select()
          .eq('user_id', userId)
          .gte(
            'week_start',
            DateTime(lastYear, lastMonth, 1).toIso8601String().split('T')[0],
          )
          .lt(
            'week_start',
            DateTime(now.year, now.month, 1).toIso8601String().split('T')[0],
          );

      final missionsTotal = (missions as List).length;
      final missionsCompleted = missions
          .where((m) => m['is_completed'] == true)
          .length;

      // Save monthly history
      await _client.from('monthly_history').insert({
        'user_id': userId,
        'month': lastMonth,
        'year': lastYear,
        'start_xp': ranking.totalXp - ranking.monthlyXp,
        'end_xp': ranking.totalXp,
        'total_xp': ranking.monthlyXp,
        'missions_completed': missionsCompleted,
        'missions_total': missionsTotal,
        'rank_change': 0, // Will be calculated later
      });

      // Reset monthly XP
      await _client
          .from('user_rankings')
          .update({'monthly_xp': 0})
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Error processing monthly progression: $e');
    }
  }

  /// Check and update missions based on user activity
  Future<void> checkAndUpdateMissions() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final missions = await getWeeklyMissions();
      final ranking = await getUserRanking();

      for (final mission in missions) {
        if (mission.isCompleted) continue;

        double newValue = mission.currentValue;

        switch (mission.missionType) {
          case MissionType.registerExpenseDaily:
          case MissionType.checkBalanceDaily:
            // These are handled by transaction creation
            break;

          case MissionType.maintainStreak7Days:
            newValue = (ranking?.currentStreak ?? 0).toDouble();
            break;

          case MissionType.addSavingsGoal:
            final goals = await getSavingsGoals();
            newValue = goals.isNotEmpty ? 1.0 : 0.0;
            break;

          case MissionType.reachSavingsGoal:
            final goals = await getSavingsGoals();
            final completedGoals = goals.where(
              (g) => g.currentAmount >= g.targetAmount,
            );
            newValue = completedGoals.isNotEmpty ? 1.0 : 0.0;
            break;

          default:
            // Other missions need specific tracking
            break;
        }

        if (newValue != mission.currentValue) {
          await updateMissionProgress(mission.id, newValue);
        }
      }
    } catch (e) {
      debugPrint('Error checking missions: $e');
    }
  }
}
