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
      extendBody: true, // Important for glass effect
      bottomNavigationBar: const GlassBottomNavBar(),
    );
  }
}

class GlassBottomNavBar extends StatelessWidget {
  const GlassBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GlassContainer(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavBarItem(
              icon: Icons.home_rounded,
              label: 'Início',
              isSelected: GoRouterState.of(context).uri.toString() == '/',
              onTap: () => context.go('/'),
            ),
            _NavBarItem(
              icon: Icons.school_rounded,
              label: 'Aprender',
              isSelected:
                  GoRouterState.of(context).uri.toString() == '/education',
              onTap: () => context.go('/education'),
            ),
            _NavBarItem(
              icon: Icons.newspaper_rounded,
              label: 'Notícias',
              isSelected: GoRouterState.of(context).uri.toString() == '/news',
              onTap: () => context.go('/news'),
            ),
            _NavBarItem(
              icon: Icons.person_rounded,
              label: 'Perfil',
              isSelected:
                  GoRouterState.of(context).uri.toString() == '/profile',
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
        : theme.colorScheme.onSurface.withOpacity(0.6);

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
