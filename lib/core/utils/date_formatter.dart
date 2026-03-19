import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Helper para formatear fechas usando el locale de la app
class DateFormatter {
  /// Formatea una fecha con el locale de la app
  static String formatDate(DateTime date, BuildContext context) {
    final locale = Localizations.localeOf(context);
    return DateFormat.yMMMd(locale.languageCode).format(date);
  }

  /// Formatea una fecha corta (día y mes)
  static String formatShortDate(DateTime date, BuildContext context) {
    final locale = Localizations.localeOf(context);
    return DateFormat.MMMd(locale.languageCode).format(date);
  }

  /// Formatea mes y año
  static String formatMonthYear(DateTime date, BuildContext context) {
    final locale = Localizations.localeOf(context);
    return DateFormat.yMMMM(locale.languageCode).format(date);
  }
}
