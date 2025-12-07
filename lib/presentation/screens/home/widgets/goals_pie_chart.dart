import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../data/models/supabase_models.dart';
import '../../../widgets/glass_container.dart';

class GoalsPieChart extends StatelessWidget {
  final List<SavingsGoal> goals;
  final VoidCallback onRefresh;

  const GoalsPieChart({
    super.key,
    required this.goals,
    required this.onRefresh,
  });

  IconData _getIconData(String iconName) {
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

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Metas de Economia',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => context.push('/savings-goals'),
                child: const Text('Ver todas'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: goals.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final goal = goals[index];
                final progress = goal.targetAmount > 0
                    ? goal.currentAmount / goal.targetAmount
                    : 0.0;
                final color = Color(int.parse(goal.color));

                return GestureDetector(
                  onTap: () async {
                    final result = await context.push(
                      '/add-savings-goal',
                      extra: goal,
                    );
                    if (result == true) {
                      onRefresh();
                    }
                  },
                  child: GlassContainer(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: progress.clamp(0.0, 1.0),
                                  strokeWidth: 6,
                                  backgroundColor: color.withAlpha(51),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    color,
                                  ),
                                ),
                                Icon(
                                  _getIconData(goal.icon),
                                  color: color,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            goal.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
