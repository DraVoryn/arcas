import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcas/providers/theme_provider.dart';
import 'package:arcas/providers/locale_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final currentLocale = ref.watch(currentLocaleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Appearance Section
          _buildSectionHeader('Apariencia'),
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
            title: const Text('Modo Oscuro'),
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
          _buildSectionHeader('Idioma'),
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
            title: const Text('Idioma'),
            subtitle: Text(_getLocaleName(currentLocale)),
            onTap: () => _showLanguageSelector(context, ref, currentLocale),
          ),

          const Divider(),

          // About Section
          _buildSectionHeader('Acerca de'),
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
            title: const Text('Acerca de Arcas'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Arcas',
                applicationVersion: '1.0.0',
                applicationLegalese: 'Tu app de finanzas personales',
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
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Seleccionar Idioma',
                    style: TextStyle(
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
                  title: 'Sistema',
                  subtitle: 'Usar configuración del dispositivo',
                  icon: Icons.settings_suggest,
                  isSelected: currentLocale == null,
                ),

                // Opción: Español
                _buildLanguageOption(
                  context: context,
                  ref: ref,
                  locale: const Locale('es'),
                  title: 'Español',
                  subtitle: 'Idioma de la app',
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
                  subtitle: 'App language',
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
}
