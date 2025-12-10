import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/supabase_models.dart';
import '../../../../data/repositories/supabase_repository.dart';
import '../../widgets/glass_container.dart';
import 'widgets/expense_trend_chart.dart';
import 'widgets/category_pie_chart.dart';

class ReportsScreen extends StatefulWidget {
  final int initialTabIndex;
  const ReportsScreen({super.key, this.initialTabIndex = 0});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SupabaseRepository _repository = SupabaseRepository();
  bool _isLoading = true;

  // Analytics Data
  Map<int, Map<String, double>> _trendData =
      {}; // {month: {income: x, expense: y}}
  List<CategoryData> _pieData = [];
  Map<String, double> _currentMonthSummary = {};
  Map<String, double> _prevMonthSummary = {};

  // Goals Data
  List<CategoryModel> _categories = [];
  final Map<String, double> _pendingBudgets = {}; // Local state for sliders
  bool _isSavingGoals = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();

      // 1. Fetch Trend Data ... (omitted for brevity, keep existing logic)
      _trendData = {};
      for (int i = 5; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, 1);
        final summary = await _repository.getFinancialSummaryByMonth(
          date.year,
          date.month,
        );
        summary['month'] = date.month.toDouble();
        _trendData[5 - i] = summary;
      }

      // 2. Fetch Comparison ...
      _currentMonthSummary = await _repository.getFinancialSummaryByMonth(
        now.year,
        now.month,
      );
      DateTime prevDate = DateTime(now.year, now.month - 1, 1);
      _prevMonthSummary = await _repository.getFinancialSummaryByMonth(
        prevDate.year,
        prevDate.month,
      );

      // 3. Fetch Pie Data ...
      final transactions = await _repository.getTransactionsByMonth(
        now.year,
        now.month,
      );
      final expenses = transactions.where((t) => t.type == 'expense').toList();
      Map<String, double> catAmount = {};
      for (var e in expenses) {
        catAmount[e.category] = (catAmount[e.category] ?? 0) + e.amount;
      }

      final allCategories = await _repository.getCategories();

      _categories = allCategories.where((c) {
        final isExpense = c.type == 'expense';
        final isInvestment =
            c.name.toLowerCase() == 'investimentos' || c.type == 'investment';
        return isExpense || isInvestment;
      }).toList();

      // Initialize pending budgets
      _pendingBudgets.clear();
      for (var c in _categories) {
        _pendingBudgets[c.id] = c.budgetLimitPercent ?? 0;
      }

      Map<String, Color> catColors = {};
      for (var c in allCategories) {
        try {
          catColors[c.name] = Color(int.parse(c.color));
        } catch (_) {}
      }

      _pieData = catAmount.entries.map((e) {
        Color color = catColors[e.key] ?? Colors.grey;
        if (!catColors.containsKey(e.key)) {
          color = Colors.primaries[e.key.hashCode % Colors.primaries.length];
        }
        return CategoryData(
          name: e.key,
          amount: e.value,
          color: color,
          icon: Icons.circle,
        );
      }).toList();
      _pieData.sort((a, b) => b.amount.compareTo(a.amount));
    } catch (e) {
      debugPrint('Error loading report data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updatePendingBudget(String categoryId, double value) {
    setState(() {
      _pendingBudgets[categoryId] = value;
    });
  }

  Future<void> _saveAllBudgets() async {
    setState(() => _isSavingGoals = true);
    try {
      // Create a list of futures to run in parallel
      await Future.wait(
        _pendingBudgets.entries.map(
          (e) => _repository.updateCategoryBudget(e.key, e.value),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todas as metas foram salvas!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      // Reload to ensure sync
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar metas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingGoals = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildLiquidBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Relatórios e Análises'),
            actions: [
              if (_tabController.index == 1) // Only show on Goals tab
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _isSavingGoals
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : TextButton(
                          onPressed: _saveAllBudgets,
                          child: const Text(
                            'Salvar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryColor,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Análise'),
                Tab(text: 'Metas de Gastos'),
              ],
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [_buildAnalyticsTab(), _buildGoalsTab()],
                ),
        ),
      ],
    );
  }

  Widget _buildLiquidBackground() {
    return Container(
      color: const Color(0xFF121212), // Deep dark base
    );
  }

  Widget _buildAnalyticsTab() {
    final bottomPadding =
        MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 20;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly Comparison
          _buildComparisonCard(),
          const SizedBox(height: 24),

          // Trend Chart
          const Text(
            'Tendência (Últimos 6 meses)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 300, child: ExpenseTrendChart(data: _trendData)),

          const SizedBox(height: 32),

          // Pie Chart
          const Text(
            'Gastos por Categoria (Este Mês)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          CategoryPieChart(data: _pieData),

          SizedBox(height: bottomPadding), // Dynamic Bottom padding
        ],
      ),
    );
  }

  Widget _buildComparisonCard() {
    double currExp = _currentMonthSummary['expense'] ?? 0;
    double prevExp = _prevMonthSummary['expense'] ?? 0;
    double diff = currExp - prevExp;
    bool increased = diff > 0;
    double pct = prevExp > 0 ? (diff.abs() / prevExp * 100) : 0;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (increased ? Colors.red : Colors.green).withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              increased ? Icons.trending_up : Icons.trending_down,
              color: increased ? Colors.red : Colors.green,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gastos vs Mês Anterior',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'R\$ ${diff.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: increased ? Colors.red : Colors.green,
                  ),
                ),
                Text(
                  '${increased ? 'A mais' : 'A menos'} (${pct.toStringAsFixed(1)}%)',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Anterior: R\$${prevExp.toStringAsFixed(0)} | Atual: R\$${currExp.toStringAsFixed(0)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsTab() {
    // 1. Calculate and track Total from PENDING STATE
    double totalAllocated = 0;
    for (var val in _pendingBudgets.values) {
      totalAllocated += val;
    }
    final isOverTotal = totalAllocated > 100;
    final isSuccess = totalAllocated <= 100 && totalAllocated > 0;

    final bottomPadding =
        MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 20;

    return Column(
      children: [
        // Total Allocation Indicator
        // ... (keep container content)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.black26,
            border: Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Alocação Total da Renda',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${totalAllocated.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: isOverTotal
                          ? Colors.red
                          : (isSuccess ? Colors.green : Colors.white),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (totalAllocated / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.white10,
                  color: isOverTotal ? Colors.red : Colors.green,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              // Feedback Message Area
              if (isOverTotal)
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Atenção! Você alocou mais de 100% da sua renda. Reduza algumas metas.',
                        style: TextStyle(color: Colors.red[300], fontSize: 12),
                      ),
                    ),
                  ],
                )
              else if (isSuccess)
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Excelente! Sua distribuição está dentro do orçamento.',
                        style: TextStyle(
                          color: Colors.green[300],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.builder(
            // Correct padding for NavBar overlap
            padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              // Use value from pending map
              final currentValue = _pendingBudgets[category.id] ?? 0;

              return _GoalListItem(
                category: category,
                currentValue: currentValue,
                onChanged: (val) => _updatePendingBudget(category.id, val),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GoalListItem extends StatelessWidget {
  final CategoryModel category;
  final double currentValue;
  final ValueChanged<double> onChanged;

  const _GoalListItem({
    required this.category,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(category.color));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.category, color: color, size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Center(
                    child: Text(
                      '${currentValue.toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '0%',
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                    ),
                    child: Slider(
                      value: currentValue,
                      min: 0,
                      max: 100,
                      activeColor: currentValue > 50
                          ? Colors.orange
                          : color, // Visual warning color
                      inactiveColor: color.withAlpha(50),
                      onChanged: onChanged,
                    ),
                  ),
                ),
                Text(
                  '100%',
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                ),
              ],
            ),
            if (currentValue > 50)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Cuidado! Alocar mais de 50% em uma única categoria pode comprometer sua saúde financeira.',
                  style: TextStyle(
                    color: Colors.orange[300],
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
