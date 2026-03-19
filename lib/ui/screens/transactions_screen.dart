import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcas/database/app_database.dart';
import 'package:arcas/ui/dialogs/add_transaction_dialog.dart';
import 'package:arcas/providers/database_provider.dart';

final transactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllTransactions();
});

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(
              child: Text('No transactions yet'),
            );
          }
          final sortedTransactions = [...transactions]
            ..sort((a, b) => b.date.compareTo(a.date));
          return ListView.builder(
            itemCount: sortedTransactions.length,
            itemBuilder: (context, index) {
              final tx = sortedTransactions[index];
              return Dismissible(
                key: Key(tx.id.toString()),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Transaction'),
                      content: Text('Are you sure you want to delete "${tx.description}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  ) ?? false;
                },
                onDismissed: (direction) {
                  ref.read(databaseProvider).deleteTransaction(tx.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${tx.description} deleted'),
                      backgroundColor: const Color(0xFF2A9D8F),
                    ),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  onTap: () => _showEditDialog(context, ref, tx),
                  leading: CircleAvatar(
                    backgroundColor: tx.type == 'income'
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
                    child: Icon(
                      tx.type == 'income'
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: tx.type == 'income' ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(tx.description),
                  subtitle: Text(tx.date.toString().substring(0, 10)),
                  trailing: Text(
                    '\$${tx.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: tx.type == 'income' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AddTransactionDialog.show(context);
        },
        backgroundColor: const Color(0xFF2A9D8F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Transaction transaction) {
    AddTransactionDialog.show(context, transaction: transaction);
  }
}
