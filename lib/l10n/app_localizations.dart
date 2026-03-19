import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Arcas - Finanzas Personales'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get home;

  /// No description provided for @transactions.
  ///
  /// In es, this message translates to:
  /// **'Transacciones'**
  String get transactions;

  /// No description provided for @reports.
  ///
  /// In es, this message translates to:
  /// **'Reportes'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Configuracion'**
  String get settings;

  /// No description provided for @addTransaction.
  ///
  /// In es, this message translates to:
  /// **'Agregar Transaccion'**
  String get addTransaction;

  /// No description provided for @addCategory.
  ///
  /// In es, this message translates to:
  /// **'Agregar Categoria'**
  String get addCategory;

  /// No description provided for @description.
  ///
  /// In es, this message translates to:
  /// **'Descripcion'**
  String get description;

  /// No description provided for @amount.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get date;

  /// No description provided for @category.
  ///
  /// In es, this message translates to:
  /// **'Categoria'**
  String get category;

  /// No description provided for @type.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get type;

  /// No description provided for @income.
  ///
  /// In es, this message translates to:
  /// **'Ingreso'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In es, this message translates to:
  /// **'Gasto'**
  String get expense;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @darkMode.
  ///
  /// In es, this message translates to:
  /// **'Modo Oscuro'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @about.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get about;

  /// No description provided for @version.
  ///
  /// In es, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @noTransactions.
  ///
  /// In es, this message translates to:
  /// **'Sin transacciones'**
  String get noTransactions;

  /// No description provided for @noCategories.
  ///
  /// In es, this message translates to:
  /// **'Sin categorias'**
  String get noCategories;

  /// No description provided for @premium.
  ///
  /// In es, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @upgrade.
  ///
  /// In es, this message translates to:
  /// **'Mejorar'**
  String get upgrade;

  /// No description provided for @generateReport.
  ///
  /// In es, this message translates to:
  /// **'Generar Reporte'**
  String get generateReport;

  /// No description provided for @monthlyReport.
  ///
  /// In es, this message translates to:
  /// **'Reporte Mensual'**
  String get monthlyReport;

  /// No description provided for @yearlyReport.
  ///
  /// In es, this message translates to:
  /// **'Reporte Anual'**
  String get yearlyReport;

  /// No description provided for @totalIncome.
  ///
  /// In es, this message translates to:
  /// **'Ingresos Totales'**
  String get totalIncome;

  /// No description provided for @totalExpense.
  ///
  /// In es, this message translates to:
  /// **'Gastos Totales'**
  String get totalExpense;

  /// No description provided for @balance.
  ///
  /// In es, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @selectDateRange.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Rango'**
  String get selectDateRange;

  /// No description provided for @startDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de Inicio'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de Fin'**
  String get endDate;

  /// No description provided for @totalBalance.
  ///
  /// In es, this message translates to:
  /// **'Balance Total'**
  String get totalBalance;

  /// No description provided for @expenses.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get expenses;

  /// No description provided for @recentTransactions.
  ///
  /// In es, this message translates to:
  /// **'Transacciones Recientes'**
  String get recentTransactions;

  /// No description provided for @deleteTransactionConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Transaccion'**
  String get deleteTransactionConfirmTitle;

  /// No description provided for @deleteTransactionConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar'**
  String get deleteTransactionConfirmMessage;

  /// No description provided for @transactionDeleted.
  ///
  /// In es, this message translates to:
  /// **'transaccion eliminada'**
  String get transactionDeleted;

  /// No description provided for @reportType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de Reporte'**
  String get reportType;

  /// No description provided for @weekly.
  ///
  /// In es, this message translates to:
  /// **'Semanal'**
  String get weekly;

  /// No description provided for @custom.
  ///
  /// In es, this message translates to:
  /// **'Personalizado'**
  String get custom;

  /// No description provided for @from.
  ///
  /// In es, this message translates to:
  /// **'Desde'**
  String get from;

  /// No description provided for @to.
  ///
  /// In es, this message translates to:
  /// **'Hasta'**
  String get to;

  /// No description provided for @generating.
  ///
  /// In es, this message translates to:
  /// **'Generando...'**
  String get generating;

  /// No description provided for @latestReport.
  ///
  /// In es, this message translates to:
  /// **'Ultimo Reporte'**
  String get latestReport;

  /// No description provided for @noReportsYet.
  ///
  /// In es, this message translates to:
  /// **'Sin reportes generados'**
  String get noReportsYet;

  /// No description provided for @errorLoadingReport.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar reporte'**
  String get errorLoadingReport;

  /// No description provided for @reportGeneratedSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Reporte generado exitosamente!'**
  String get reportGeneratedSuccess;

  /// No description provided for @appearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get appearance;

  /// No description provided for @manageSubscription.
  ///
  /// In es, this message translates to:
  /// **'Gestionar suscripcion'**
  String get manageSubscription;

  /// No description provided for @aboutArcas.
  ///
  /// In es, this message translates to:
  /// **'Acerca de Arcas'**
  String get aboutArcas;

  /// No description provided for @selectLanguage.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Idioma'**
  String get selectLanguage;

  /// No description provided for @system.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get system;

  /// No description provided for @useDeviceSettings.
  ///
  /// In es, this message translates to:
  /// **'Usar configuracion del dispositivo'**
  String get useDeviceSettings;

  /// No description provided for @errorLoadingTransactions.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar transacciones'**
  String get errorLoadingTransactions;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
