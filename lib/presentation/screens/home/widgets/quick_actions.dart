import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class QuickActions extends StatelessWidget {
  final VoidCallback onRefresh;

  const QuickActions({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionButton(
            icon: Icons.add_circle_outline_rounded,
            label: 'Receita',
            color: Colors.green,
            onTap: () async {
              final result = await context.push(
                '/add-transaction',
                extra: 'income',
              );
              if (result == true) onRefresh();
            },
          ),
          _ActionButton(
            icon: Icons.remove_circle_outline_rounded,
            label: 'Despesa',
            color: Colors.red,
            onTap: () async {
              final result = await context.push(
                '/add-transaction',
                extra: 'expense',
              );
              if (result == true) onRefresh();
            },
          ),
          _ActionButton(
            icon: Icons.savings_outlined,
            label: 'Meta',
            color: AppTheme.primaryColor,
            onTap: () {
              context.go('/savings-goals');
            },
          ),
          _ActionButton(
            icon: Icons.more_horiz_rounded,
            label: 'Mais',
            color: Colors.grey,
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.import_export),
                        title: const Text('Exportar Dados'),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.pie_chart_outline),
                        title: const Text('Relatórios Detalhados'),
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
