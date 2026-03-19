import 'dart:convert';
import 'package:arcas/database/app_database.dart';
import 'package:arcas/premium/models/report.dart' as model;
import 'package:arcas/premium/models/category_breakdown.dart';

class ReportService {
  final AppDatabase _db;

  ReportService(this._db);

  Future<model.Report> generateReport({
    required model.ReportType type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final transactions = await _db.getTransactionsByDateRange(startDate, endDate);
    final categories = await _db.getAllCategories();

    double totalIncome = 0;
    double totalExpense = 0;
    final Map<int, double> categoryAmounts = {};

    for (final tx in transactions) {
      if (tx.type == 'income') {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }

      if (tx.categoryId != null) {
        categoryAmounts[tx.categoryId!] =
            (categoryAmounts[tx.categoryId!] ?? 0) + tx.amount;
      }
    }

    final balance = totalIncome - totalExpense;
    final totalAmount = totalIncome + totalExpense;

    final breakdown = <CategoryBreakdown>[];
    for (final entry in categoryAmounts.entries) {
      final category = categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => Category(
          id: 0, 
          name: 'Unknown', 
          icon: 'help', 
          color: 'grey',
          createdAt: DateTime.now(),
        ),
      );
      
      breakdown.add(CategoryBreakdown(
        categoryId: entry.key,
        categoryName: category.name,
        amount: entry.value,
        percentage: totalAmount > 0 ? (entry.value / totalAmount) * 100 : 0,
        icon: category.icon,
        color: category.color,
      ));
    }

    breakdown.sort((a, b) => b.amount.compareTo(a.amount));

    final now = DateTime.now();
    final jsonBreakdown = jsonEncode(breakdown.map((e) => e.toJson()).toList());
    
    final id = await _db.into(_db.reports).insert(
      ReportsCompanion.insert(
        type: type.name,
        startDate: startDate,
        endDate: endDate,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: balance,
        categoryBreakdownJson: jsonBreakdown,
      ),
    );

    return model.Report(
      id: id,
      type: type,
      startDate: startDate,
      endDate: endDate,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: balance,
      categoryBreakdown: breakdown,
      generatedAt: now,
    );
  }

  Future<model.Report?> getLatestReport() async {
    final report = await _db.getLatestReport();
    if (report == null) return null;
    return _mapDbToModel(report);
  }

  Future<List<model.Report>> getReportsByDateRange(
      DateTime start, DateTime end) async {
    final reports = await _db.getReportsByDateRange(start, end);
    return reports.map(_mapDbToModel).toList();
  }

  model.Report _mapDbToModel(Report report) {
    final breakdownJson = jsonDecode(report.categoryBreakdownJson) as List;
    final breakdown = breakdownJson
        .map((e) => CategoryBreakdown.fromJson(e as Map<String, dynamic>))
        .toList();

    return model.Report(
      id: report.id,
      type: model.ReportType.values.firstWhere((e) => e.name == report.type),
      startDate: report.startDate,
      endDate: report.endDate,
      totalIncome: report.totalIncome,
      totalExpense: report.totalExpense,
      balance: report.balance,
      categoryBreakdown: breakdown,
      generatedAt: report.generatedAt,
    );
  }
}