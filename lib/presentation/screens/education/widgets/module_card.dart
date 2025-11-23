import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/glass_container.dart';

class ModuleCard extends StatelessWidget {
  final String title;
  final String description;
  final double progress;
  final bool isLocked;

  const ModuleCard({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GlassContainer(
        isDark: isLocked,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isLocked ? Colors.grey : null,
                  ),
                ),
                if (isLocked)
                  const Icon(Icons.lock_outline, color: Colors.grey)
                else
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isLocked ? Colors.grey : null,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: isLocked
                  ? Colors.grey.withOpacity(0.2)
                  : AppTheme.primaryColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isLocked ? Colors.grey : AppTheme.primaryColor,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }
}
