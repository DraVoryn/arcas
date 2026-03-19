import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:arcas/premium/models/report.dart';
import 'package:arcas/premium/models/category_breakdown.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback? onTap;

  const ReportCard({
    super.key,
    required this.report,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat.yMMMd();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getReportTypeLabel(report.type),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dateFormat.format(report.generatedAt ?? DateTime.now()),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    context,
                    'Income',
                    currencyFormat.format(report.totalIncome),
                    Colors.green,
                  ),
                  _buildSummaryItem(
                    context,
                    'Expense',
                    currencyFormat.format(report.totalExpense),
                    Colors.red,
                  ),
                  _buildSummaryItem(
                    context,
                    'Balance',
                    currencyFormat.format(report.balance),
                    report.balance >= 0 ? Colors.green : Colors.red,
                  ),
                ],
              ),
              if (report.categoryBreakdown.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Top Categories',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...report.categoryBreakdown.take(3).map(
                  (cat) => _buildCategoryItem(context, cat),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getReportTypeLabel(ReportType type) {
    switch (type) {
      case ReportType.weekly:
        return 'Weekly Report';
      case ReportType.monthly:
        return 'Monthly Report';
      case ReportType.custom:
        return 'Custom Report';
    }
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryBreakdown cat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              cat.categoryName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            '\$${cat.amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${cat.percentage.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}