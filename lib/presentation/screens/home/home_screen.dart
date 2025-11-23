import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/repositories/supabase_repository.dart';
import '../../../../data/models/supabase_models.dart';
import 'widgets/home_header.dart';
import 'widgets/summary_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/transaction_list.dart';

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
    final profile = await _repository.getProfile();
    final streak = await _repository.getUserStreak();
    final summary = await _repository.getFinancialSummary();
    final transactions = await _repository.getRecentTransactions();

    return {
      'profile': profile,
      'streak': streak,
      'summary': summary,
      'transactions': transactions,
    };
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
              setState(() {
                _dashboardData = _fetchDashboardData(); // Refresh data
              });
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
          final summary = data['summary'] as Map<String, double>?;
          final transactions = data['transactions'] as List<TransactionModel>?;

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
                    balance: summary?['balance'] ?? 0.0,
                    income: summary?['income'] ?? 0.0,
                    expense: summary?['expense'] ?? 0.0,
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  QuickActions(
                    onRefresh: () {
                      setState(() {
                        _dashboardData = _fetchDashboardData();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TransactionList(transactions: transactions ?? []),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
