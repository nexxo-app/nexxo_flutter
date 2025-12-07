import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/repositories/supabase_repository.dart';
import '../../../../data/models/supabase_models.dart';
import 'widgets/home_header.dart';
import 'widgets/summary_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/transaction_list.dart';
import 'widgets/goals_pie_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = SupabaseRepository();
  late Future<Map<String, dynamic>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = _fetchDashboardData();
  }

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    final now = DateTime.now();
    final profile = await _repository.getProfile();
    final streak = await _repository.getUserStreak();
    final summaryTotal = await _repository.getFinancialSummary();
    final summaryMonth = await _repository.getFinancialSummaryByMonth(
      now.year,
      now.month,
    );
    final transactions = await _repository.getRecentTransactions();
    final savingsGoals = await _repository.getSavingsGoals();

    return {
      'profile': profile,
      'streak': streak,
      'summaryTotal': summaryTotal,
      'summaryMonth': summaryMonth,
      'transactions': transactions,
      'savingsGoals': savingsGoals,
    };
  }

  void _refreshData() {
    setState(() {
      _dashboardData = _fetchDashboardData();
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
          final streak = data['streak'] as UserStreak?;
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
                    streak: streak?.currentStreak ?? 0,
                  ),
                  const SizedBox(height: 20),
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
                  TransactionList(transactions: transactions ?? []),
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
