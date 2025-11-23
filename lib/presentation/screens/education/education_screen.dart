import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/module_card.dart';
import 'widgets/lesson_item.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aprender'),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            onPressed: () =>
                context.push('/education/admin'), // TODO: Check admin role
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const ModuleCard(
              title: 'Módulo 1: Introdução',
              description: 'Conceitos básicos de finanças pessoais.',
              progress: 0.6,
            ),
            const SizedBox(height: 20),
            // Path visualization
            _buildPath(context),
            const SizedBox(height: 40),
            const ModuleCard(
              title: 'Módulo 2: Investimentos',
              description: 'Começando a investir seu dinheiro.',
              progress: 0.0,
              isLocked: true,
            ),
            // Add extra padding for bottom nav
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildPath(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LessonItem(id: 1, isCompleted: true, isLocked: false, onTap: () {}),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 40),
            LessonItem(id: 2, isCompleted: true, isLocked: false, onTap: () {}),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            LessonItem(id: 3, isCurrent: true, isLocked: false, onTap: () {}),
            const SizedBox(width: 40),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [LessonItem(id: 4, isLocked: true, onTap: () {})],
        ),
      ],
    );
  }
}
