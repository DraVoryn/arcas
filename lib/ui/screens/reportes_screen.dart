import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcas/core/utils/date_formatter.dart';
import 'package:arcas/providers/premium_provider.dart';
import 'package:arcas/premium/models/report.dart';
import 'package:arcas/premium/widgets/report_limit_indicator.dart';
import 'package:arcas/premium/widgets/upgrade_prompt.dart';
import 'package:arcas/premium/widgets/report_card.dart';
import 'package:arcas/premium/widgets/premium_badge.dart';
import 'package:arcas/l10n/app_localizations.dart';

class ReportesScreen extends ConsumerStatefulWidget {
  const ReportesScreen({super.key});

  @override
  ConsumerState<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends ConsumerState<ReportesScreen> {
  ReportType? _selectedType;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final premiumState = ref.watch(premiumNotifierProvider).value ?? const PremiumState();
    final reportState = ref.watch(reportGenerationProvider);
    final latestReportAsync = ref.watch(latestReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reports),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: PremiumBadge(),
          ),
        ],
      ),
      body: premiumState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(premiumNotifierProvider.notifier).refresh();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (!premiumState.isPremium) ...[
                    const ReportLimitIndicator(),
                    const SizedBox(height: 16),
                  ],
                  if (!premiumState.canGenerateReport()) ...[
                    const UpgradePrompt(),
                  ] else ...[
                    _buildGenerateReportSection(context, reportState),
                  ],
                  const SizedBox(height: 24),
                  _buildReportHistory(context, latestReportAsync),
                ],
              ),
            ),
    );
  }

  Widget _buildGenerateReportSection(
      BuildContext context, ReportGenerationState reportState) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.generateReport,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.reportType,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<ReportType>(
              segments: [
                ButtonSegment(
                  value: ReportType.weekly,
                  label: Text(l10n.weekly),
                  icon: const Icon(Icons.view_week),
                ),
                ButtonSegment(
                  value: ReportType.monthly,
                  label: Text(l10n.monthlyReport),
                  icon: const Icon(Icons.calendar_month),
                ),
                ButtonSegment(
                  value: ReportType.custom,
                  label: Text(l10n.custom),
                  icon: const Icon(Icons.date_range),
                ),
              ],
              selected: {_selectedType ?? ReportType.weekly},
              onSelectionChanged: (selection) {
                setState(() {
                  _selectedType = selection.first;
                  _updateDateRange(selection.first);
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    context,
                    l10n.from,
                    _startDate,
                    (date) => setState(() => _startDate = date),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    context,
                    l10n.to,
                    _endDate,
                    (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: reportState.isGenerating
                    ? null
                    : () => _generateReport(context),
                icon: reportState.isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.bar_chart),
                label: Text(
                    reportState.isGenerating ? l10n.generating : l10n.generateReport),
              ),
            ),
            if (reportState.error != null) ...[
              const SizedBox(height: 16),
              Text(
                reportState.error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    DateTime date,
    ValueChanged<DateTime> onSelect,
  ) {
    final dateFormat = (DateTime d) => DateFormatter.formatDate(d, context);
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          onSelect(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(dateFormat(date)),
      ),
    );
  }

  Widget _buildReportHistory(
    BuildContext context,
    AsyncValue<Report?> latestReportAsync,
  ) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.latestReport,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        latestReportAsync.when(
          data: (report) {
            if (report == null) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noReportsYet,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return ReportCard(report: report);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('${l10n.errorLoadingReport}: $error'),
            ),
          ),
        ),
      ],
    );
  }

  void _updateDateRange(ReportType type) {
    final now = DateTime.now();
    switch (type) {
      case ReportType.weekly:
        _startDate = now.subtract(const Duration(days: 7));
        _endDate = now;
        break;
      case ReportType.monthly:
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
        break;
      case ReportType.custom:
        break;
    }
  }

  Future<void> _generateReport(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final type = _selectedType ?? ReportType.weekly;
    final report = await ref.read(reportGenerationProvider.notifier).generateReport(
      type: type,
      startDate: _startDate,
      endDate: _endDate,
    );

    if (report != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.reportGeneratedSuccess)),
      );
      ref.invalidate(latestReportProvider);
    }
  }
}