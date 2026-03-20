import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arcas/l10n/app_localizations.dart';
import 'package:arcas/providers/premium_provider.dart';
import 'package:arcas/core/utils/date_formatter.dart';

class PremiumSettingsScreen extends ConsumerWidget {
  const PremiumSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final premiumState = ref.watch(premiumNotifierProvider).value ?? const PremiumState();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.premium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusCard(context, premiumState, l10n),
          const SizedBox(height: 24),
          if (premiumState.isPremium)
            _buildSubscriptionDetails(context, premiumState, l10n)
          else
            _buildUpgradePrompt(context, l10n),
          const SizedBox(height: 24),
          _buildFeaturesList(context, l10n),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, PremiumState premiumState, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: premiumState.isPremium
                    ? Colors.amber.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                premiumState.isPremium ? Icons.star : Icons.star_border,
                size: 32,
                color: premiumState.isPremium ? Colors.amber : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    premiumState.isPremium ? l10n.premiumActive : l10n.freePlan,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    premiumState.isPremium
                        ? l10n.premiumDescription
                        : '${premiumState.reportsGeneratedThisMonth}/3 ${l10n.reportsThisMonth}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionDetails(BuildContext context, PremiumState premiumState, AppLocalizations l10n) {
    final subscription = premiumState.subscription;
    final dateFormat = (DateTime d) => DateFormatter.formatDate(d, context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.yourSubscription,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (subscription != null) ...[
              _buildDetailRow(
                context,
                l10n.plan,
                subscription.planId == 'monthly' ? l10n.monthlyReport.split(' ')[0] : l10n.yearly,
              ),
              _buildDetailRow(
                context,
                l10n.started,
                dateFormat(subscription.startDate),
              ),
              if (subscription.expirationDate != null)
                _buildDetailRow(
                  context,
                  l10n.expires,
                  dateFormat(subscription.expirationDate!),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradePrompt(BuildContext context, AppLocalizations l10n) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              l10n.upgradeToPremium,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.upgradePromptDescription,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.push('/paywall'),
              icon: const Icon(Icons.star),
              label: Text(l10n.viewPlans),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context, AppLocalizations l10n) {
    final features = [
      (Icons.receipt_long, l10n.unlimitedReports),
      (Icons.picture_as_pdf, l10n.exportToPdf),
      (Icons.analytics, l10n.advancedAnalytics),
      (Icons.support_agent, l10n.prioritySupport),
      (Icons.new_releases, l10n.earlyAccessFeatures),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.premiumFeatures,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    feature.$1,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(feature.$2),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
