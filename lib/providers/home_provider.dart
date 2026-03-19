import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcas/database/app_database.dart';
import 'package:arcas/providers/database_provider.dart';

final totalBalanceProvider = StreamProvider<double>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllTransactions().map((transactions) {
    double balance = 0;
    for (final tx in transactions) {
      if (tx.type == 'income') {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }
    return balance;
  });
});

final recentTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllTransactions().map((transactions) {
    final sorted = [...transactions]
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(10).toList();
  });
});

final monthlyStatsProvider = StreamProvider<MonthlyStats>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllTransactions().map((transactions) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    
    double income = 0;
    double expense = 0;
    
    for (final tx in transactions) {
      if (tx.date.isAfter(monthStart) || tx.date.isAtSameMomentAs(monthStart)) {
        if (tx.type == 'income') {
          income += tx.amount;
        } else {
          expense += tx.amount;
        }
      }
    }
    
    return MonthlyStats(
      income: income,
      expense: expense,
      balance: income - expense,
    );
  });
});

class MonthlyStats {
  final double income;
  final double expense;
  final double balance;
  
  const MonthlyStats({
    required this.income,
    required this.expense,
    required this.balance,
  });
}

final allCategoriesProvider = StreamProvider<List<Category>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllCategories();
});

final topCategoriesProvider = StreamProvider<List<CategorySpending>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllTransactions().map((transactions) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    
    final Map<int, double> spendingByCategory = {};
    
    for (final tx in transactions) {
      if (tx.type == 'expense' && 
          (tx.date.isAfter(monthStart) || tx.date.isAtSameMomentAs(monthStart))) {
        final catId = tx.categoryId ?? 0;
        spendingByCategory[catId] = (spendingByCategory[catId] ?? 0) + tx.amount;
      }
    }
    
    final sorted = spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(5).map((e) => CategorySpending(
      categoryId: e.key,
      amount: e.value,
    )).toList();
  });
});

class CategorySpending {
  final int categoryId;
  final double amount;
  
  const CategorySpending({
    required this.categoryId,
    required this.amount,
  });
}
