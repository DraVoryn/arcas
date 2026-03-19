import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:arcas/providers/premium_provider.dart';

class PremiumSettingsScreen extends ConsumerWidget {
  const PremiumSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumState = ref.watch(premiumNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusCard(context, premiumState),
          const SizedBox(height: 24),
          if (premiumState.isPremium)
            _buildSubscriptionDetails(context, premiumState)
          else
            _buildUpgradePrompt(context),
          const SizedBox(height: 24),
          _buildFeaturesList(context),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, PremiumState premiumState) {
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
                    premiumState.isPremium ? 'Premium Active' : 'Free Plan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    premiumState.isPremium
                        ? 'Unlimited reports and features'
                        : '${premiumState.reportsGeneratedThisMonth}/3 reports this month',
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

  Widget _buildSubscriptionDetails(BuildContext context, PremiumState premiumState) {
    final subscription = premiumState.subscription;
    final dateFormat = DateFormat.yMMMd();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Subscription',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (subscription != null) ...[
              _buildDetailRow(
                context,
                'Plan',
                subscription.planId == 'monthly' ? 'Monthly' : 'Yearly',
              ),
              _buildDetailRow(
                context,
                'Started',
                dateFormat.format(subscription.startDate),
              ),
              if (subscription.expirationDate != null)
                _buildDetailRow(
                  context,
                  'Expires',
                  dateFormat.format(subscription.expirationDate!),
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

  Widget _buildUpgradePrompt(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Upgrade to Premium',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Get unlimited reports, export to PDF, and advanced analytics.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.push('/paywall'),
              icon: const Icon(Icons.star),
              label: const Text('View Plans'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      ('Icons.receipt_long', 'Unlimited Reports'),
      ('Icons.picture_as_pdf', 'Export to PDF'),
      ('Icons.analytics', 'Advanced Analytics'),
      ('Icons.support_agent', 'Priority Support'),
      ('Icons.new_releases', 'Early Access Features'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Premium Features',
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
                    _getIconFromString(feature.$1),
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

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'Icons.receipt_long':
        return Icons.receipt_long;
      case 'Icons.picture_as_pdf':
        return Icons.picture_as_pdf;
      case 'Icons.analytics':
        return Icons.analytics;
      case 'Icons.support_agent':
        return Icons.support_agent;
      case 'Icons.new_releases':
        return Icons.new_releases;
      default:
        return Icons.star;
    }
  }
}