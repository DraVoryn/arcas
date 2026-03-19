import 'category_breakdown.dart';

enum ReportType { weekly, monthly, custom }

class Report {
  final int? id;
  final ReportType type;
  final DateTime startDate;
  final DateTime endDate;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final List<CategoryBreakdown> categoryBreakdown;
  final DateTime? generatedAt;

  const Report({
    this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.categoryBreakdown,
    this.generatedAt,
  });

  Report copyWith({
    int? id,
    ReportType? type,
    DateTime? startDate,
    DateTime? endDate,
    double? totalIncome,
    double? totalExpense,
    double? balance,
    List<CategoryBreakdown>? categoryBreakdown,
    DateTime? generatedAt,
  }) {
    return Report(
      id: id ?? this.id,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      balance: balance ?? this.balance,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': balance,
      'categoryBreakdown': categoryBreakdown.map((e) => e.toJson()).toList(),
      'generatedAt': generatedAt?.toIso8601String(),
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as int?,
      type: ReportType.values.firstWhere((e) => e.name == json['type']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalExpense: (json['totalExpense'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      categoryBreakdown: (json['categoryBreakdown'] as List)
          .map((e) => CategoryBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'] as String)
          : null,
    );
  }
}