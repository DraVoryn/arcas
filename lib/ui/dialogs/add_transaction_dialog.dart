import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:arcas/database/app_database.dart';
import 'package:arcas/providers/database_provider.dart';
import 'package:arcas/providers/currency_provider.dart';
import 'package:arcas/l10n/app_localizations.dart';

class AddTransactionDialog extends ConsumerStatefulWidget {
  final Transaction? transaction;
  
  const AddTransactionDialog({super.key, this.transaction});

  @override
  ConsumerState<AddTransactionDialog> createState() =>
      _AddTransactionDialogState();

  static Future<void> show(BuildContext context, {Transaction? transaction}) {
    return showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(transaction: transaction),
    );
  }
}

class _AddTransactionDialogState extends ConsumerState<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'expense';
  bool _isLoading = false;
  
  bool get _isEditMode => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _descriptionController.text = widget.transaction!.description;
      _amountController.text = widget.transaction!.amount.toString();
      _selectedDate = widget.transaction!.date;
      _selectedType = widget.transaction!.type;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF2A9D8F),
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);

      if (_isEditMode) {
        await db.updateTransaction(
          widget.transaction!.copyWith(
            description: _descriptionController.text.trim(),
            amount: double.parse(_amountController.text),
            date: _selectedDate,
            type: _selectedType,
          ),
        );
      } else {
        await db.insertTransaction(
          TransactionsCompanion(
            description: Value(_descriptionController.text.trim()),
            amount: Value(double.parse(_amountController.text)),
            date: Value(_selectedDate),
            type: Value(_selectedType),
            createdAt: Value(DateTime.now()),
          ),
        );
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        Navigator.of(context).pop();
        _showSuccessSnackBar(l10n: l10n, isEdit: _isEditMode);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar({required AppLocalizations l10n, bool isEdit = false}) {
    String message;
    if (isEdit) {
      message = _selectedType == 'income' ? l10n.incomeUpdated : l10n.expenseUpdated;
    } else {
      message = _selectedType == 'income' ? l10n.incomeAdded : l10n.expenseAdded;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF2A9D8F),
        behavior: SnackBarBehavior.fixed,  // Fixed: abajo del todo, no tapa el FAB
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),  // 1 segundo: suficiente, no estorba
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyNotifierProvider);
    final isExpense = _selectedType == 'expense';
    final accentColor = isExpense
        ? const Color(0xFFE63946)
        : const Color(0xFF2A9D8F);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isExpense
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        color: accentColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _isEditMode 
                          ? (isExpense ? l10n.editExpense : l10n.editIncome)
                          : (isExpense ? l10n.newExpense : l10n.newIncome),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Type selector
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedType = 'expense'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedType == 'expense'
                                  ? const Color(0xFFE63946)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              l10n.expense,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _selectedType == 'expense'
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedType = 'income'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedType == 'income'
                                  ? const Color(0xFF2A9D8F)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              l10n.income,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _selectedType == 'income'
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.description,
                    hintText: 'Ej: Almuerzo, Sueldo...',
                    prefixIcon: const Icon(Icons.description_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.enterDescription;
                    }
                    if (value.length > 255) {
                      return l10n.max255Chars;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Amount
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: '${l10n.amount} (${currency.code})',
                    hintText: '0.00',
                    prefixIcon: const Icon(Icons.attach_money),
                    prefixText: '${currency.symbol} ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.enterAmount;
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return l10n.invalidAmount;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Fecha',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_isEditMode ? l10n.update : l10n.save),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
