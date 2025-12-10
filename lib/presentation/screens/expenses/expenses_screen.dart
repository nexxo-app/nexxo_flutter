import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/supabase_models.dart';
import '../../../../data/repositories/supabase_repository.dart';
import '../../widgets/glass_container.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final SupabaseRepository _repository = SupabaseRepository();

  // Current selected month/year
  late int _selectedYear;
  late int _selectedMonth;

  // Data state (not using FutureBuilder to avoid full refresh)
  bool _isInitialLoading = true;
  Map<String, double> _summary = {};
  List<TransactionModel> _transactions = [];
  Map<String, double> _expensesByCategory = {};
  Map<String, double> _prevSummary = {}; // To store previous month's summary

  Map<String, CategoryModel> _categoryMap = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _loadExpensesData();
  }

  Future<void> _loadExpensesData() async {
    final summary = await _repository.getFinancialSummaryByMonth(
      _selectedYear,
      _selectedMonth,
    );
    final transactions = await _repository.getTransactionsByMonth(
      _selectedYear,
      _selectedMonth,
    );
    final categories = await _repository.getCategories();
    final categoryMap = {for (var c in categories) c.name: c};

    // Separate expenses for category grouping
    final expenses = transactions.where((t) => t.type == 'expense').toList();

    // Group expenses by category
    final Map<String, double> expensesByCategory = {};
    for (var expense in expenses) {
      expensesByCategory[expense.category] =
          (expensesByCategory[expense.category] ?? 0) + expense.amount;
    }

    // Load previous month data for comparison
    int prevMonth = _selectedMonth - 1;
    int prevYear = _selectedYear;
    if (prevMonth == 0) {
      prevMonth = 12;
      prevYear--;
    }
    final prevSummary = await _repository.getFinancialSummaryByMonth(
      prevYear,
      prevMonth,
    );

    if (mounted) {
      setState(() {
        _summary = summary;
        _prevSummary = prevSummary;
        _transactions = transactions;
        _categoryMap = categoryMap;
        _expensesByCategory = expensesByCategory;
        _isInitialLoading = false;
      });
    }
  }

  String _formatCategoryName(String rawName) {
    return rawName.replaceAll(RegExp(r'\s*\([RD]\)$'), '');
  }

  Future<void> _showEditBudgetDialog(CategoryModel category) async {
    final controller = TextEditingController(
      text: category.budgetLimitPercent?.toStringAsFixed(0) ?? '',
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Meta: ${_formatCategoryName(category.name)}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Meta (% da renda)',
            suffixText: '%',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              Navigator.pop(context, value);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      try {
        await _repository.updateCategoryBudget(category.id, result);
        _loadExpensesData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meta atualizada com sucesso!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erro ao atualizar: $e')));
        }
      }
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return months[month - 1];
  }

  void _previousMonth() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
    });
    _loadExpensesData();
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_selectedYear == now.year && _selectedMonth >= now.month) return;

    setState(() {
      if (_selectedMonth == 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else {
        _selectedMonth++;
      }
    });
    _loadExpensesData();
  }

  bool get _canGoNext {
    final now = DateTime.now();
    return !(_selectedYear == now.year && _selectedMonth >= now.month);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalExpense = _summary['expense'] ?? 0.0;
    final totalIncome = _summary['income'] ?? 0.0;
    final balance = _summary['balance'] ?? 0.0;

    if (_isInitialLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadExpensesData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Controle de',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withAlpha(
                                153,
                              ), // 0.6 * 255 ~= 153
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gastos',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: -0.5,
                              fontSize: 32,
                            ),
                          ),
                        ],
                      ),
                      // Month Selector
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withAlpha(
                            26,
                          ), // 0.1 * 255 ~= 26
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primaryColor.withAlpha(
                              77,
                            ), // 0.3 * 255 ~= 77
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left_rounded),
                              color: AppTheme.primaryColor,
                              iconSize: 22,
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
                              onPressed: _previousMonth,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                '${_getMonthName(_selectedMonth).substring(0, 3)}/${_selectedYear.toString().substring(2)}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.chevron_right_rounded,
                                color: _canGoNext
                                    ? AppTheme.primaryColor
                                    : AppTheme.primaryColor.withAlpha(
                                        77,
                                      ), // 0.3
                              ),
                              iconSize: 22,
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(),
                              onPressed: _canGoNext ? _nextMonth : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Balance Card
                _BalanceSummaryCard(
                  balance: balance,
                  income: totalIncome,
                  expense: totalExpense,
                ),

                const SizedBox(height: 20),

                // Comparative Insights
                if (!_isInitialLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _ExpenseInsightsCard(
                      currentExpense: totalExpense,
                      previousExpense: _prevSummary['expense'] ?? 0.0,
                    ),
                  ),

                const SizedBox(height: 28),

                // Expenses by Category Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Gastos por Categoria',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (_expensesByCategory.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.pie_chart_outline_rounded,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Nenhuma despesa em ${_getMonthName(_selectedMonth)}',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: _expensesByCategory.entries.map((entry) {
                        final percentage = totalExpense > 0
                            ? (entry.value / totalExpense * 100)
                            : 0.0;
                        final categoryModel = _categoryMap[entry.key];
                        double? budgetLimit;
                        if (categoryModel?.budgetLimitPercent != null &&
                            totalIncome > 0) {
                          budgetLimit =
                              (categoryModel!.budgetLimitPercent! / 100) *
                              totalIncome;
                        }

                        return _CategoryExpenseCard(
                          categoryName: _formatCategoryName(entry.key),
                          amount: entry.value,
                          percentageOfTotal: percentage,
                          budgetLimit: budgetLimit,
                          categoryModel: categoryModel,
                          onEditBudget: () =>
                              _showEditBudgetDialog(categoryModel!),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 28),

                // Transactions Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Transações de ${_getMonthName(_selectedMonth)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                if (_transactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Nenhuma transação em ${_getMonthName(_selectedMonth)}',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: _transactions
                            .map(
                              (transaction) => _TransactionListItem(
                                transaction: transaction,
                                onRefresh: _loadExpensesData,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),

                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await context.push('/add-transaction');
            if (result == true) {
              _loadExpensesData();
            }
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class _BalanceSummaryCard extends StatefulWidget {
  final double balance;
  final double income;
  final double expense;

  const _BalanceSummaryCard({
    required this.balance,
    required this.income,
    required this.expense,
  });

  @override
  State<_BalanceSummaryCard> createState() => _BalanceSummaryCardState();
}

class _BalanceSummaryCardState extends State<_BalanceSummaryCard> {
  bool _isBalanceVisible = true;

  String formatCurrency(double value) {
    if (!_isBalanceVisible) return 'R\$ ****';
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withAlpha(204), // 0.8
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withAlpha(77), // 0.3
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(26), // 0.1
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(26), // 0.1
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saldo do Mês',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white.withAlpha(230),
                              ), // 0.9
                        ),
                        IconButton(
                          icon: Icon(
                            _isBalanceVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.white70,
                          ),
                          onPressed: () => setState(
                            () => _isBalanceVisible = !_isBalanceVisible,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      formatCurrency(widget.balance),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        _BalanceItem(
                          label: 'Receitas',
                          value: formatCurrency(widget.income),
                          icon: Icons.arrow_upward_rounded,
                        ),
                        const SizedBox(width: 24),
                        _BalanceItem(
                          label: 'Despesas',
                          value: formatCurrency(widget.expense),
                          icon: Icons.arrow_downward_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _BalanceItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(51), // 0.2
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withAlpha(204), // 0.8
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryExpenseCard extends StatelessWidget {
  final String categoryName;
  final double amount;
  final double percentageOfTotal;
  final double? budgetLimit;
  final CategoryModel? categoryModel;
  final VoidCallback? onEditBudget;

  const _CategoryExpenseCard({
    required this.categoryName,
    required this.amount,
    required this.percentageOfTotal,
    this.budgetLimit,
    this.categoryModel,
    this.onEditBudget,
  });

  IconData _getCategoryIcon(String category) {
    // Sanitize for switch matching just in case, though we pass formatted name
    final normalized = category.toLowerCase();
    if (normalized.contains('alimentação')) return Icons.restaurant_rounded;
    if (normalized.contains('mercado')) return Icons.shopping_cart_rounded;

    // ... complete standard switch or simplified lookup
    switch (normalized) {
      case 'alimentação':
        return Icons.restaurant_rounded;
      case 'mercado':
        return Icons.shopping_cart_rounded;
      case 'transporte':
        return Icons.directions_car_rounded;
      case 'moradia':
        return Icons.home_rounded;
      case 'lazer':
        return Icons.sports_esports_rounded;
      case 'saúde':
        return Icons.local_hospital_rounded;
      case 'educação':
        return Icons.school_rounded;
      case 'salário':
        return Icons.attach_money_rounded;
      case 'investimentos':
        return Icons.trending_up_rounded;
      case 'compras':
        return Icons.shopping_bag_rounded;
      case 'contas':
        return Icons.receipt_long_rounded;
      case 'presente':
        return Icons.card_giftcard_rounded;
      case 'freelance':
        return Icons.work_rounded;
      case 'bônus':
        return Icons.star_rounded;
      case 'reembolso':
        return Icons.replay_rounded;
      case 'viagem':
        return Icons.flight_rounded;
      case 'pets':
        return Icons.pets_rounded;
      case 'assinaturas':
        return Icons.subscriptions_rounded;
      case 'eletrônicos':
        return Icons.devices_rounded;
      case 'cuidados pessoais':
        return Icons.spa_rounded;
      default:
        // Fallback for suffixes like (R) if they weren't stripped properly or for new variants
        if (normalized.startsWith('outros')) return Icons.category_rounded;
        return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    if (categoryModel != null) {
      try {
        return Color(int.parse(categoryModel!.color));
      } catch (_) {}
    }
    // Fallback colors
    // Fallback colors logic adjusted for formatted names
    final normalized = category.toLowerCase();
    switch (normalized) {
      case 'alimentação':
        return Colors.orange;
      case 'transporte':
        return Colors.blue;
      case 'moradia':
        return Colors.purple;
      case 'lazer':
        return Colors.pink;
      case 'saúde':
        return Colors.red;
      case 'educação':
        return Colors.teal;
      case 'salário':
        return Colors.green;
      case 'investimentos':
        return Colors.indigo;
      case 'bônus':
        return Colors.amber;
      case 'reembolso':
        return Colors.green;
      case 'viagem':
        return Colors.pink;
      case 'pets':
        return Colors.brown;
      case 'assinaturas':
        return Colors.blueGrey;
      case 'eletrônicos':
        return Colors.indigo;
      case 'cuidados pessoais':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(categoryName);

    // Budget Logic
    final hasBudget = budgetLimit != null && budgetLimit! > 0;
    final budgetProgress = hasBudget
        ? (amount / budgetLimit!).clamp(0.0, 1.0)
        : 0.0;
    final isOverBudget = hasBudget && amount > budgetLimit!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withAlpha(38), // 0.15
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getCategoryIcon(categoryName),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (hasBudget)
                        Text(
                          isOverBudget
                              ? 'Acima da meta!'
                              : '${(budgetProgress * 100).toStringAsFixed(0)}% da meta',
                          style: TextStyle(
                            color: isOverBudget ? Colors.red : Colors.grey[500],
                            fontSize: 12,
                            fontWeight: isOverBudget
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        )
                      else
                        Text(
                          '${percentageOfTotal.toStringAsFixed(1)}% dos gastos',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'R\$ ${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                    if (hasBudget)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '/ R\$ ${budgetLimit!.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                // Edit Budget Icon
                if (categoryModel != null && categoryModel!.id.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton(
                      icon: Icon(
                        Icons.edit_rounded,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onEditBudget,
                    ),
                  ),
              ],
            ),
            if (hasBudget) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: budgetProgress,
                  backgroundColor: color.withAlpha(38),
                  color: isOverBudget ? Colors.red : color,
                  minHeight: 6,
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentageOfTotal / 100,
                  backgroundColor: color.withAlpha(38),
                  color: color,
                  minHeight: 6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

final class _TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onRefresh;

  const _TransactionListItem({required this.transaction, this.onRefresh});

  IconData _getCategoryIcon(String category) {
    // Use a cleaned name for mapping
    final cleanName = category
        .replaceAll(RegExp(r'\s*\([RD]\)$'), '')
        .toLowerCase();
    switch (cleanName) {
      case 'alimentação':
        return Icons.restaurant_rounded;
      case 'transporte':
        return Icons.directions_car_rounded;
      case 'moradia':
        return Icons.home_rounded;
      case 'lazer':
        return Icons.sports_esports_rounded;
      case 'saúde':
        return Icons.local_hospital_rounded;
      case 'educação':
        return Icons.school_rounded;
      case 'salário':
        return Icons.attach_money_rounded;
      case 'investimentos':
        return Icons.trending_up_rounded;
      case 'bônus':
        return Icons.star_rounded;
      case 'reembolso':
        return Icons.replay_rounded;
      case 'viagem':
        return Icons.flight_rounded;
      case 'pets':
        return Icons.pets_rounded;
      case 'assinaturas':
        return Icons.subscriptions_rounded;
      case 'eletrônicos':
        return Icons.devices_rounded;
      case 'cuidados pessoais':
        return Icons.spa_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == 'expense';
    final color = isExpense ? Colors.red : Colors.green;
    final categoryName = transaction.category.replaceAll(
      RegExp(r'\s*\([RD]\)$'),
      '',
    );

    return InkWell(
      onTap: () async {
        final result = await context.push(
          '/add-transaction',
          extra: transaction,
        );
        if (result == true) {
          onRefresh?.call();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(26), // 0.1
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(transaction.category),
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        categoryName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd/MM').format(transaction.date),
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${isExpense ? '-' : '+'} R\$ ${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              color: Colors.red,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Excluir Transação'),
                    content: const Text(
                      'Tem certeza que deseja excluir esta transação?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Excluir',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  try {
                    await SupabaseRepository().deleteTransaction(
                      transaction.id,
                    );
                    onRefresh?.call();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao excluir: $e')),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseInsightsCard extends StatelessWidget {
  final double currentExpense;
  final double previousExpense;

  const _ExpenseInsightsCard({
    required this.currentExpense,
    required this.previousExpense,
  });

  @override
  Widget build(BuildContext context) {
    if (previousExpense <= 0) return const SizedBox.shrink();

    final diff = currentExpense - previousExpense;
    final isHigher = diff > 0;
    final percent = (diff.abs() / previousExpense) * 100;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isHigher ? Colors.red : Colors.green).withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isHigher
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color: isHigher ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHigher ? 'Gastos Aumentaram' : 'Gastos Diminuíram',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Você gastou R\$ ${diff.abs().toStringAsFixed(2)} '
                  '${isHigher ? 'a mais' : 'a menos'} que no mês passado.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (isHigher ? Colors.red : Colors.green).withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${isHigher ? '+' : '-'}${percent.toStringAsFixed(1)}%',
              style: TextStyle(
                color: isHigher ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
