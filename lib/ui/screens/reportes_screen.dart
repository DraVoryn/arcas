import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:arcas/providers/premium_provider.dart';
import 'package:arcas/premium/models/report.dart';
import 'package:arcas/premium/widgets/report_limit_indicator.dart';
import 'package:arcas/premium/widgets/upgrade_prompt.dart';
import 'package:arcas/premium/widgets/report_card.dart';
import 'package:arcas/premium/widgets/premium_badge.dart';

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
    final premiumState = ref.watch(premiumNotifierProvider);
    final reportState = ref.watch(reportGenerationProvider);
    final latestReportAsync = ref.watch(latestReportProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: PremiumBadge(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/premium-settings'),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generate Report',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Report Type',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<ReportType>(
              segments: const [
                ButtonSegment(
                  value: ReportType.weekly,
                  label: Text('Weekly'),
                  icon: Icon(Icons.view_week),
                ),
                ButtonSegment(
                  value: ReportType.monthly,
                  label: Text('Monthly'),
                  icon: Icon(Icons.calendar_month),
                ),
                ButtonSegment(
                  value: ReportType.custom,
                  label: Text('Custom'),
                  icon: Icon(Icons.date_range),
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
                    'From',
                    _startDate,
                    (date) => setState(() => _startDate = date),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    context,
                    'To',
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
                    reportState.isGenerating ? 'Generating...' : 'Generate Report'),
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
    final dateFormat = DateFormat.yMMMd();
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
        child: Text(dateFormat.format(date)),
      ),
    );
  }

  Widget _buildReportHistory(
    BuildContext context,
    AsyncValue<Report?> latestReportAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Latest Report',
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
                          'No reports generated yet',
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
              child: Text('Error loading report: $error'),
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
    final type = _selectedType ?? ReportType.weekly;
    final report = await ref.read(reportGenerationProvider.notifier).generateReport(
      type: type,
      startDate: _startDate,
      endDate: _endDate,
    );

    if (report != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report generated successfully!')),
      );
      ref.invalidate(latestReportProvider);
    }
  }
}