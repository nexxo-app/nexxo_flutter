import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../widgets/glass_container.dart';
import '../../../../data/models/supabase_models.dart';
import '../../../../data/repositories/supabase_repository.dart';
import '../../../../core/services/sound_manager.dart';

class AddTransactionScreen extends StatefulWidget {
  final String? initialType;
  final TransactionModel? transaction; // For editing

  const AddTransactionScreen({super.key, this.initialType, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _scrollController = ScrollController();
  late String _type;
  String _category = 'Outros';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  List<CategoryModel> _categories = [];

  Key _rebuildKey = UniqueKey();

  bool get isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      // Editing mode - pre-fill fields
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _type = widget.transaction!.type;
      _category = widget.transaction!.category;
      _selectedDate = widget.transaction!.date;
    } else {
      _type = widget.initialType ?? 'expense';
    }
    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _unfocusAndRebuild() {
    FocusScope.of(context).unfocus();
    if (_scrollController.hasClients) {
      final currentOffset = _scrollController.offset;
      _scrollController.jumpTo(currentOffset + 1);
      _scrollController.jumpTo(currentOffset);
    }
    setState(() {
      _rebuildKey = UniqueKey();
    });
  }

  void _updateCategoryForType() {
    final categoriesForType = _categories
        .where((c) => c.type == _type)
        .toList();
    if (categoriesForType.isNotEmpty) {
      if (!categoriesForType.any((c) => c.name == _category)) {
        // Try to find a default "Outros" or fallback to first
        final defaultCat = categoriesForType.firstWhere(
          (c) => c.name.startsWith('Outros'),
          orElse: () => categoriesForType.first,
        );
        _category = defaultCat.name;
      }
    } else {
      // Fallback if no categories loaded yet (shouldn't happen often if loader works)
      _category = _type == 'income' ? 'Salário' : 'Alimentação';
    }
  }

  Future<void> _loadCategories() async {
    try {
      final repository = SupabaseRepository();
      final categories = await repository.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          _updateCategoryForType();
        });
      }
    } catch (e) {
      if (mounted) {
        // Fallback or error handling
      }
    }
  }

  Future<void> _saveTransaction() async {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      final repository = SupabaseRepository();

      if (isEditing) {
        await repository.updateTransaction(
          id: widget.transaction!.id,
          title: _titleController.text,
          amount: amount,
          type: _type,
          category: _category,
          date: _selectedDate,
        );
      } else {
        await repository.addTransaction(
          title: _titleController.text,
          amount: amount,
          type: _type,
          category: _category,
          date: _selectedDate,
        );
      }

      if (mounted) {
        if (_type == 'income') {
          SoundManager().playIncome();
        } else {
          SoundManager().playExpense();
        }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _rebuildKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Transação' : 'Nova Transação'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isEditing && !_isLoading)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Excluir Transação'),
                    content: const Text(
                      'Tem certeza que deseja excluir esta transação?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Excluir',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  if (!context.mounted) return;
                  setState(() => _isLoading = true);

                  try {
                    await SupabaseRepository().deleteTransaction(
                      widget.transaction!.id,
                    );
                    if (!context.mounted) return;
                    context.pop(true);
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao excluir: $e')),
                    );
                    setState(() => _isLoading = false);
                  }
                }
              },
            ),
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
                    onPressed: _saveTransaction,
                    child: Text(
                      'Salvar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _type == 'income' ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: _unfocusAndRebuild,
        behavior: HitTestBehavior.translucent,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Type Selector
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _unfocusAndRebuild();
                        setState(() {
                          _type = 'expense';
                          _updateCategoryForType();
                        });
                      },
                      child: GlassContainer(
                        color: _type == 'expense'
                            ? Colors.red.withAlpha(51)
                            : null,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'Despesa',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _type == 'expense'
                                  ? Colors.red
                                  : (isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _unfocusAndRebuild();
                        setState(() {
                          _type = 'income';
                          _updateCategoryForType();
                        });
                      },
                      child: GlassContainer(
                        color: _type == 'income'
                            ? Colors.green.withAlpha(51)
                            : null,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'Receita',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _type == 'income'
                                  ? Colors.green
                                  : (isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              GlassContainer(
                child: Column(
                  children: [
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Valor',
                        prefixText: 'R\$ ',
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                    ),
                    const Divider(),
                    DropdownButtonFormField<String>(
                      key: ValueKey(_category),
                      initialValue: _category,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: _categories.where((c) => c.type == _type).map((
                        CategoryModel category,
                      ) {
                        return DropdownMenuItem<String>(
                          value: category.name,
                          child: Row(
                            children: [
                              // Optional: Show icon
                              // Icon(getIconData(category.icon)),
                              // SizedBox(width: 8),
                              Text(category.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() => _category = newValue);
                        }
                      },
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                      ),
                      onTap: () async {
                        _unfocusAndRebuild();
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != _selectedDate) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
