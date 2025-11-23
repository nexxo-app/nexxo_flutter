import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class LessonItem extends StatelessWidget {
  final int id;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLocked;
  final VoidCallback onTap;

  const LessonItem({
    super.key,
    required this.id,
    this.isCompleted = false,
    this.isCurrent = false,
    this.isLocked = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color iconColor;
    IconData icon;

    if (isCompleted) {
      backgroundColor = Colors.amber;
      iconColor = Colors.white;
      icon = Icons.check;
    } else if (isCurrent) {
      backgroundColor = AppTheme.primaryColor;
      iconColor = Colors.white;
      icon = Icons.star;
    } else {
      backgroundColor = Colors.grey.withOpacity(0.3);
      iconColor = Colors.grey;
      icon = Icons.lock;
    }

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : null,
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 4),
        ),
        child: Icon(icon, color: iconColor, size: 32),
      ),
    );
  }
}
