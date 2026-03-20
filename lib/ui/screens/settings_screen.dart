import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:arcas/providers/theme_provider.dart';
import 'package:arcas/providers/locale_provider.dart';
import 'package:arcas/providers/auth_provider.dart';
import 'package:arcas/providers/currency_provider.dart';
import 'package:arcas/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeNotifierProvider);
    final currentLocale = ref.watch(currentLocaleProvider);
    final currentCurrency = ref.watch(currencyNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader(l10n.appearance),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2A9D8F).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.dark_mode,
                color: Color(0xFF2A9D8F),
              ),
            ),
            title: Text(l10n.darkMode),
            trailing: Switch(
              value: themeMode == AppThemeMode.dark,
              activeThumbColor: const Color(0xFF2A9D8F),
              onChanged: (value) {
                ref.read(themeNotifierProvider.notifier).toggleTheme();
              },
            ),
          ),

          const Divider(),

          // Language Section
          _buildSectionHeader(l10n.language),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.language,
                color: Color(0xFF007AFF),
              ),
            ),
            title: Text(l10n.language),
            subtitle: Text(_getLocaleName(currentLocale)),
            onTap: () => _showLanguageSelector(context, ref, currentLocale),
          ),

          // Currency Section
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.attach_money_rounded,
                color: Color(0xFF10B981),
              ),
            ),
            title: Text(l10n.currency),
            subtitle: Text(currentCurrency.getLocalizedName(Localizations.localeOf(context))),
            onTap: () => _showCurrencySelector(context, ref, currentCurrency),
          ),

          const Divider(),

          // Premium Section
          _buildSectionHeader(l10n.premium),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.star,
                color: Color(0xFFFFD700),
              ),
            ),
            title: Text(l10n.premium),
            subtitle: Text(l10n.manageSubscription),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/premium-settings'),
          ),

          const Divider(),

          // About Section
          _buildSectionHeader(l10n.about),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF6B7280).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Color(0xFF6B7280),
              ),
            ),
            title: Text(l10n.aboutArcas),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Arcas',
                applicationVersion: '1.0.0',
                applicationLegalese: l10n.appTitle,
                applicationIcon: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A9D8F),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              );
            },
          ),

          const Divider(),

          // Security Section
          _buildSectionHeader(l10n.security),

          // Logout (lock only — data stays)
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFF8C00).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFFFF8C00),
              ),
            ),
            title: Text(l10n.logout),
            subtitle: Text(l10n.logoutDescription),
            onTap: () => _showLogoutConfirmation(context, ref),
          ),

          // Delete account (full reset — WARNING)
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: Color(0xFFEF4444),
              ),
            ),
            title: Text(l10n.deleteAccount),
            subtitle: Text(l10n.deleteAccountDescription),
            onTap: () => _showDeleteAccountConfirmation(context, ref),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Lock only — PIN and data stay intact
              ref.read(authNotifierProvider.notifier).lock();
              if (context.mounted) {
                context.go('/lock');
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF8C00),
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).deleteAccount();
              if (context.mounted) {
                context.go('/onboarding');
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: Text(l10n.deleteAccount),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  String _getLocaleName(Locale? locale) {
    if (locale == null) return 'Sistema';
    switch (locale.languageCode) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      default:
        return locale.languageCode;
    }
  }

  void _showLanguageSelector(
      BuildContext context, WidgetRef ref, Locale? currentLocale) {
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.selectLanguage,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),

                // Opción: Sistema
                _buildLanguageOption(
                  context: context,
                  ref: ref,
                  locale: null,
                  title: l10n.system,
                  subtitle: l10n.useDeviceSettings,
                  icon: Icons.settings_suggest,
                  isSelected: currentLocale == null,
                ),

                // Opción: Español
                _buildLanguageOption(
                  context: context,
                  ref: ref,
                  locale: const Locale('es'),
                  title: 'Español',
                  subtitle: l10n.language,
                  icon: Icons.translate,
                  isSelected:
                      currentLocale?.languageCode == 'es',
                ),

                // Opción: English
                _buildLanguageOption(
                  context: context,
                  ref: ref,
                  locale: const Locale('en'),
                  title: 'English',
                  subtitle: l10n.language,
                  icon: Icons.translate,
                  isSelected:
                      currentLocale?.languageCode == 'en',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required WidgetRef ref,
    required Locale? locale,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF2A9D8F) : const Color(0xFF6B7280),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? const Color(0xFF2A9D8F) : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF2A9D8F))
          : null,
      onTap: () {
        ref.read(localeNotifierProvider.notifier).setLocale(locale);
        Navigator.pop(context);
      },
    );
  }

  void _showCurrencySelector(
      BuildContext context, WidgetRef ref, Currency currentCurrency) {
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.selectCurrency,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: supportedCurrencies.map((currency) {
                  final isSelected = currency == currentCurrency;
                  return ListTile(
                    leading: Text(
                      currency.symbol,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? const Color(0xFF2A9D8F)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                    title: Text(
                      currency.getLocalizedName(Localizations.localeOf(context)),
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? const Color(0xFF2A9D8F) : null,
                      ),
                    ),
                    subtitle: Text(currency.code),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Color(0xFF2A9D8F))
                        : null,
                    onTap: () {
                      ref.read(currencyNotifierProvider.notifier).setCurrency(currency);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
                ),
              ),
              ],
            ),
          ),
        );
      },
    );
  }
}
