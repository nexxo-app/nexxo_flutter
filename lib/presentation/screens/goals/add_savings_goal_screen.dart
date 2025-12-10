import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/supabase_models.dart';
import '../../../../data/repositories/supabase_repository.dart';
import '../../widgets/glass_container.dart';
import '../../../../core/services/sound_manager.dart';

class AddSavingsGoalScreen extends StatefulWidget {
  final SavingsGoal? goal;

  const AddSavingsGoalScreen({super.key, this.goal});

  @override
  State<AddSavingsGoalScreen> createState() => _AddSavingsGoalScreenState();
}

class _AddSavingsGoalScreenState extends State<AddSavingsGoalScreen> {
  late TextEditingController _titleController;
  late TextEditingController _targetController;
  late TextEditingController _currentController;
  DateTime? _deadline;
  String _selectedIcon = 'savings';
  String _selectedColor = '0xFF4CAF50'; // Green
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal?.title ?? '');
    _targetController = TextEditingController(
      text: widget.goal?.targetAmount.toString() ?? '',
    );
    _currentController = TextEditingController(
      text: widget.goal?.currentAmount.toString() ?? '',
    );
    _deadline = widget.goal?.deadline;
    if (widget.goal != null) {
      _selectedIcon = widget.goal!.icon;
      _selectedColor = widget.goal!.color;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  final List<String> _icons = [
    'savings',
    'flight',
    'directions_car',
    'home',
    'school',
    'computer',
    'shopping_bag',
    'favorite',
  ];

  final List<String> _colors = [
    '0xFF4CAF50', // Green
    '0xFF2196F3', // Blue
    '0xFFFFC107', // Amber
    '0xFFE91E63', // Pink
    '0xFF9C27B0', // Purple
    '0xFFFF5722', // Deep Orange
    '0xFF00BCD4', // Cyan
    '0xFF795548', // Brown
  ];

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

  Future<void> _saveGoal() async {
    if (_titleController.text.isEmpty || _targetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o título e o valor alvo.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = SupabaseRepository();
      final targetAmount = double.parse(
        _targetController.text.replaceAll(',', '.'),
      );
      final currentAmount =
          double.tryParse(_currentController.text.replaceAll(',', '.')) ?? 0.0;

      if (widget.goal != null) {
        await repository.updateSavingsGoal(
          id: widget.goal!.id,
          title: _titleController.text,
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          deadline: _deadline,
          icon: _selectedIcon,
          color: _selectedColor,
        );
      } else {
        await repository.addSavingsGoal(
          title: _titleController.text,
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          deadline: _deadline,
          icon: _selectedIcon,
          color: _selectedColor,
        );
      }

      if (mounted) {
        SoundManager().playGoalComplete();
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.goal != null ? 'Editar Meta' : 'Nova Meta'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        // Save button in AppBar - consistent with AddTransactionScreen
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: _saveGoal,
                    child: Text(
                      'Salvar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(int.parse(_selectedColor)),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassContainer(
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título da Meta',
                      prefixIcon: Icon(Icons.title),
                      border: InputBorder.none,
                    ),
                  ),
                  const Divider(),
                  TextField(
                    controller: _targetController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Valor Alvo (R\$)',
                      prefixIcon: Icon(Icons.flag),
                      border: InputBorder.none,
                    ),
                  ),
                  const Divider(),
                  TextField(
                    controller: _currentController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Valor Já Guardado (R\$)',
                      prefixIcon: Icon(Icons.attach_money),
                      border: InputBorder.none,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      _deadline == null
                          ? 'Data Limite (Opcional)'
                          : DateFormat('dd/MM/yyyy').format(_deadline!),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _deadline = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Ícone',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: _icons.map((icon) {
                    final isSelected = _selectedIcon == icon;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey.withAlpha(26),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIconData(icon),
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Cor',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: _colors.map((colorHex) {
                    final isSelected = _selectedColor == colorHex;
                    final color = Color(int.parse(colorHex));
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = colorHex),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withAlpha(128),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 100), // Bottom padding for scrollability
          ],
        ),
      ),
    );
  }
}
