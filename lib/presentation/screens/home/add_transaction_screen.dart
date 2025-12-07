import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../widgets/glass_container.dart';
import '../../../../data/models/supabase_models.dart';
import '../../../../data/repositories/supabase_repository.dart';

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

  final List<String> _categories = [
    'Alimentação',
    'Transporte',
    'Moradia',
    'Lazer',
    'Saúde',
    'Educação',
    'Salário',
    'Investimentos',
    'Outros',
  ];

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
                        setState(() => _type = 'expense');
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
                        setState(() => _type = 'income');
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
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
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
