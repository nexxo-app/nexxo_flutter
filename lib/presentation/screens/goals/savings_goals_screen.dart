import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/supabase_models.dart';
import '../../../../data/repositories/supabase_repository.dart';
import '../../widgets/glass_container.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  final SupabaseRepository _repository = SupabaseRepository();
  late Future<List<SavingsGoal>> _goalsFuture;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  void _loadGoals() {
    setState(() {
      _goalsFuture = _repository.getSavingsGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas de Economia'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await context.push('/add-savings-goal');
            if (result == true) {
              _loadGoals();
            }
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<SavingsGoal>>(
        future: _goalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final goals = snapshot.data ?? [];

          if (goals.isEmpty) {
            return const Center(child: Text('Nenhuma meta encontrada.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              final progress = goal.targetAmount > 0
                  ? goal.currentAmount / goal.targetAmount
                  : 0.0;

              final color = Color(int.parse(goal.color));
              final percentage = (progress * 100).clamp(0, 100).toInt();
              final remaining = goal.targetAmount - goal.currentAmount;

              IconData getIconData(String iconName) {
                switch (iconName) {
                  case 'flight':
                    return Icons.flight;
                  case 'directions_car':
                    return Icons.directions_car;
                  case 'home':
                    return Icons.home;
                  case 'school':
                    return Icons.school;
                  case 'computer':
                    return Icons.computer;
                  case 'shopping_bag':
                    return Icons.shopping_bag;
                  case 'favorite':
                    return Icons.favorite;
                  case 'savings':
                  default:
                    return Icons.savings;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              getIconData(goal.icon),
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
                                  goal.title,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                if (goal.deadline != null)
                                  Text(
                                    'Meta: ${DateFormat('dd/MM/yyyy').format(goal.deadline!)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () async {
                              final result = await context.push(
                                '/add-savings-goal',
                                extra: goal,
                              );
                              if (result == true) {
                                _loadGoals();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.grey,
                            ),
                            onPressed: () async {
                              await _repository.deleteSavingsGoal(goal.id);
                              _loadGoals();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'R\$ ${goal.currentAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: color,
                            ),
                          ),
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: color.withValues(alpha: 0.1),
                          color: color,
                          minHeight: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'De R\$ ${goal.targetAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                          if (remaining > 0)
                            Text(
                              'Faltam R\$ ${remaining.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
