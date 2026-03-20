import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_provider.dart';

/// Moneda soportada por la app.
class Currency {
  final String code;
  final String symbol;
  final String name;
  final String nameEs;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.nameEs,
  });

  String getLocalizedName(Locale locale) {
    return locale.languageCode == 'es' ? nameEs : name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

/// Lista de monedas soportadas.
/// Simbolos: USD, EUR, JPY usan simbolos ISO. Para monedas latinoamericanas
/// que usan "$", mostramos el codigo para evitar ambiguedad.
const List<Currency> supportedCurrencies = [
  Currency(code: 'USD', symbol: '\$', name: 'US Dollar', nameEs: 'Dolar estadounidense'),
  Currency(code: 'EUR', symbol: '€', name: 'Euro', nameEs: 'Euro'),
  Currency(code: 'ARS', symbol: '\$ARS', name: 'Argentine Peso', nameEs: 'Peso argentino'),
  Currency(code: 'MXN', symbol: '\$MX', name: 'Mexican Peso', nameEs: 'Peso mexicano'),
  Currency(code: 'COP', symbol: '\$COP', name: 'Colombian Peso', nameEs: 'Peso colombiano'),
  Currency(code: 'CLP', symbol: '\$CLP', name: 'Chilean Peso', nameEs: 'Peso chileno'),
  Currency(code: 'GTQ', symbol: 'Q', name: 'Guatemalan Quetzal', nameEs: 'Quetzal guatemalteco'),
  Currency(code: 'BRL', symbol: 'R\$', name: 'Brazilian Real', nameEs: 'Real brasileiro'),
  Currency(code: 'GBP', symbol: '£', name: 'British Pound', nameEs: 'Libra esterlina'),
  Currency(code: 'JPY', symbol: '¥', name: 'Japanese Yen', nameEs: 'Yen japones'),
];

class CurrencyNotifier extends Notifier<Currency> {
  static const _currencyKey = 'currency_code';

  @override
  Currency build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return _loadCurrency(prefs);
  }

  static Currency _loadCurrency(SharedPreferences prefs) {
    final code = prefs.getString(_currencyKey);
    if (code != null) {
      final found = supportedCurrencies.where((c) => c.code == code).toList();
      if (found.isNotEmpty) return found.first;
    }
    return supportedCurrencies.first; // Default: USD
  }

  Future<void> setCurrency(Currency currency) async {
    state = currency;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_currencyKey, currency.code);
  }
}

final currencyNotifierProvider =
    NotifierProvider<CurrencyNotifier, Currency>(CurrencyNotifier.new);

/// Formatea un monto con el simbolo de la moneda actual.
String formatCurrency(double amount, Currency currency) {
  final formatted = amount.abs().toStringAsFixed(2);
  final sign = amount < 0 ? '-' : '';
  return '$sign${currency.symbol}$formatted';
}
