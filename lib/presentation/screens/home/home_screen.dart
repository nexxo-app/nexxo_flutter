import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/repositories/supabase_repository.dart';
import '../../../../data/models/supabase_models.dart';
import '../../../../data/models/ranking_models.dart';
import '../../widgets/mission_notification.dart';
import 'widgets/home_header.dart';
import 'widgets/summary_card.dart';
import 'widgets/import_balance_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/transaction_list.dart';
import 'widgets/goals_pie_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _repository = SupabaseRepository();
  final _notificationService = MissionNotificationService();
  late Future<Map<String, dynamic>> _dashboardData;
  bool _hasCheckedDailyMission = false;
  DateTime? _lastLoadTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _dashboardData = _fetchDashboardData();
    _lastLoadTime = DateTime.now();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh when app resumes from background
    if (state == AppLifecycleState.resumed) {
      _refreshDataIfNeeded();
    }
  }

  /// Refresh data if more than 1 second has passed since last load
  /// This handles navigation back from import balance screen
  void _refreshDataIfNeeded() {
    final now = DateTime.now();
    if (_lastLoadTime == null || now.difference(_lastLoadTime!).inSeconds > 1) {
      _refreshData();
    }
  }

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    final now = DateTime.now();
    final profile = await _repository.getProfile();
    final summaryTotal = await _repository.getFinancialSummary();
    final summaryMonth = await _repository.getFinancialSummaryByMonth(
      now.year,
      now.month,
    );
    final transactions = await _repository.getRecentTransactions();
    final savingsGoals = await _repository.getSavingsGoals();

    // Check and complete daily "open app" mission
    if (!_hasCheckedDailyMission) {
      _hasCheckedDailyMission = true;
      _checkDailyOpenAppMission();
    }

    // New User Redirect Logic
    if (profile?.hasImportedBalance == false &&
        transactions.isEmpty &&
        mounted) {
      // Use Future.microtask to avoid build conflicts
      Future.microtask(() {
        if (mounted) context.go('/import-balance');
      });
    }

    return {
      'profile': profile,
      'summaryTotal': summaryTotal,
      'summaryMonth': summaryMonth,
      'transactions': transactions,
      'savingsGoals': savingsGoals,
    };
  }

  /// Check and complete the daily "open app" mission
  Future<void> _checkDailyOpenAppMission() async {
    try {
      final missions = await _repository.getWeeklyMissions();

      // Find the daily "open app" mission
      final openAppMission = missions
          .where(
            (m) => m.missionType == MissionType.openAppDaily && !m.isCompleted,
          )
          .firstOrNull;

      if (openAppMission != null) {
        // Complete the mission
        await _repository.updateMissionProgress(openAppMission.id, 1.0);

        // Show notification after a short delay
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              final completedMission = WeeklyMission(
                id: openAppMission.id,
                odMesterId: openAppMission.odMesterId,
                missionType: openAppMission.missionType,
                targetValue: openAppMission.targetValue,
                currentValue: openAppMission.targetValue,
                isCompleted: true,
                weekStart: openAppMission.weekStart,
                weekEnd: openAppMission.weekEnd,
              );
              _notificationService.showMissionComplete(
                context,
                completedMission,
              );
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking daily open app mission: $e');
    }
  }

  void _refreshData() {
    setState(() {
      _dashboardData = _fetchDashboardData();
      _lastLoadTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await context.push('/add-transaction');
            if (result == true) {
              _refreshData();
            }
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? {};
          final profile = data['profile'] as Profile?;
          final summaryTotal = data['summaryTotal'] as Map<String, double>?;
          final summaryMonth = data['summaryMonth'] as Map<String, double>?;
          final transactions = data['transactions'] as List<TransactionModel>?;
          final savingsGoals = data['savingsGoals'] as List<SavingsGoal>?;

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  HomeHeader(
                    userName: profile?.fullName?.split(' ').first ?? 'Usuário',
                  ),
                  const SizedBox(height: 20),
                  if (profile?.hasImportedBalance == false) ...[
                    const ImportBalanceCard(),
                    const SizedBox(height: 20),
                  ],
                  SummaryCard(
                    balanceTotal: summaryTotal?['balance'] ?? 0.0,
                    incomeTotal: summaryTotal?['income'] ?? 0.0,
                    expenseTotal: summaryTotal?['expense'] ?? 0.0,
                    balanceMonth: summaryMonth?['balance'] ?? 0.0,
                    incomeMonth: summaryMonth?['income'] ?? 0.0,
                    expenseMonth: summaryMonth?['expense'] ?? 0.0,
                  ),
                  const SizedBox(height: 20),
                  GoalsPieChart(
                    goals: savingsGoals ?? [],
                    onRefresh: _refreshData,
                  ),
                  const SizedBox(height: 20),
                  QuickActions(onRefresh: _refreshData),
                  const SizedBox(height: 20),
                  TransactionList(
                    transactions: transactions ?? [],
                    onRefresh: _refreshData,
                  ),
                  const SizedBox(height: 100), // Bottom padding for nav bar
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
