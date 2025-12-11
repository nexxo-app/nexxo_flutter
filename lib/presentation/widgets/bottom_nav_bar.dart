import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'glass_container.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: const GlassBottomNavBar(),
    );
  }
}

class GlassBottomNavBar extends StatelessWidget {
  const GlassBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GlassContainer(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavBarItem(
              icon: Icons.home_rounded,
              label: 'Início',
              isSelected: currentRoute == '/',
              onTap: () => context.go('/'),
            ),
            _NavBarItem(
              icon: Icons.emoji_events_rounded,
              label: 'Ranking',
              isSelected: currentRoute == '/ranking',
              onTap: () => context.go('/ranking'),
            ),
            _NavBarItem(
              icon: Icons.flag_rounded,
              label: 'Metas',
              isSelected: currentRoute == '/savings-goals',
              onTap: () => context.go('/savings-goals'),
            ),
            _NavBarItem(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Gastos',
              isSelected: currentRoute == '/expenses',
              onTap: () => context.go('/expenses'),
            ),
            _NavBarItem(
              icon: Icons.bar_chart_rounded,
              label: 'Relatórios',
              isSelected: currentRoute == '/reports',
              onTap: () => context.go('/reports'),
            ),
            _NavBarItem(
              icon: Icons.person_rounded,
              label: 'Perfil',
              isSelected: currentRoute == '/profile',
              onTap: () => context.go('/profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withAlpha(153);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
