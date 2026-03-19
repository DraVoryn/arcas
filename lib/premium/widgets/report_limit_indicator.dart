import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcas/l10n/app_localizations.dart';
import 'package:arcas/providers/premium_provider.dart';
import 'package:arcas/premium/models/freemium_limits.dart';

class ReportLimitIndicator extends ConsumerWidget {
  const ReportLimitIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final premiumState = ref.watch(premiumNotifierProvider);

    if (premiumState.isPremium) {
      return const SizedBox.shrink();
    }

    final limits = const FreemiumLimits();
    final percentage = limits.usagePercentage(
      reportsGeneratedThisMonth: premiumState.reportsGeneratedThisMonth,
      isPremium: premiumState.isPremium,
    );

    final remaining = premiumState.remainingReports;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.reportsThisMonth,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              Text(
                '$remaining ${l10n.remaining}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: remaining <= 1
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation(
                remaining <= 1
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
