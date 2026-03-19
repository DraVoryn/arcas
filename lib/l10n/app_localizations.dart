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
  /// **'Seleccionar idioma'**
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

  /// No description provided for @totalBalance.
  ///
  /// In es, this message translates to:
  /// **'Balance Total'**
  String get totalBalance;

  /// No description provided for @recentTransactions.
  ///
  /// In es, this message translates to:
  /// **'Transacciones Recientes'**
  String get recentTransactions;

  /// No description provided for @expenses.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get expenses;

  /// No description provided for @deleteTransactionConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Transaccion'**
  String get deleteTransactionConfirmTitle;

  /// No description provided for @deleteTransactionConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'Estas seguro de eliminar'**
  String get deleteTransactionConfirmMessage;

  /// No description provided for @transactionDeleted.
  ///
  /// In es, this message translates to:
  /// **'eliminado'**
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
  /// **'Sin reportes aun'**
  String get noReportsYet;

  /// No description provided for @errorLoadingReport.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar reporte'**
  String get errorLoadingReport;

  /// No description provided for @reportGeneratedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Reporte generado exitosamente'**
  String get reportGeneratedSuccess;

  /// No description provided for @errorLoadingTransactions.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar transacciones'**
  String get errorLoadingTransactions;

  /// No description provided for @newIncome.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Ingreso'**
  String get newIncome;

  /// No description provided for @newExpense.
  ///
  /// In es, this message translates to:
  /// **'Nuevo Gasto'**
  String get newExpense;

  /// No description provided for @editIncome.
  ///
  /// In es, this message translates to:
  /// **'Editar Ingreso'**
  String get editIncome;

  /// No description provided for @editExpense.
  ///
  /// In es, this message translates to:
  /// **'Editar Gasto'**
  String get editExpense;

  /// No description provided for @incomeUpdated.
  ///
  /// In es, this message translates to:
  /// **'Ingreso actualizado'**
  String get incomeUpdated;

  /// No description provided for @expenseUpdated.
  ///
  /// In es, this message translates to:
  /// **'Gasto actualizado'**
  String get expenseUpdated;

  /// No description provided for @incomeAdded.
  ///
  /// In es, this message translates to:
  /// **'Ingreso agregado'**
  String get incomeAdded;

  /// No description provided for @expenseAdded.
  ///
  /// In es, this message translates to:
  /// **'Gasto agregado'**
  String get expenseAdded;

  /// No description provided for @enterDescription.
  ///
  /// In es, this message translates to:
  /// **'Ingrese una descripcion'**
  String get enterDescription;

  /// No description provided for @enterAmount.
  ///
  /// In es, this message translates to:
  /// **'Ingrese un monto'**
  String get enterAmount;

  /// No description provided for @invalidAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto invalido'**
  String get invalidAmount;

  /// No description provided for @max255Chars.
  ///
  /// In es, this message translates to:
  /// **'Maximo 255 caracteres'**
  String get max255Chars;

  /// No description provided for @update.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get update;

  /// No description provided for @upgradeToPremium.
  ///
  /// In es, this message translates to:
  /// **'Mejorar a Premium'**
  String get upgradeToPremium;

  /// No description provided for @unlockPremium.
  ///
  /// In es, this message translates to:
  /// **'Desbloquear Premium'**
  String get unlockPremium;

  /// No description provided for @unlockPremiumFeatures.
  ///
  /// In es, this message translates to:
  /// **'Obtén reportes ilimitados y funciones avanzadas'**
  String get unlockPremiumFeatures;

  /// No description provided for @subscribeMonthly.
  ///
  /// In es, this message translates to:
  /// **'Suscribirse Mensual'**
  String get subscribeMonthly;

  /// No description provided for @subscribeYearly.
  ///
  /// In es, this message translates to:
  /// **'Suscribirse Anual'**
  String get subscribeYearly;

  /// No description provided for @saveWithYearly.
  ///
  /// In es, this message translates to:
  /// **'Ahorra 40%'**
  String get saveWithYearly;

  /// No description provided for @restorePurchases.
  ///
  /// In es, this message translates to:
  /// **'Restaurar Compras'**
  String get restorePurchases;

  /// No description provided for @purchaseFailed.
  ///
  /// In es, this message translates to:
  /// **'Error en la compra. Intenta de nuevo.'**
  String get purchaseFailed;

  /// No description provided for @noPurchasesFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron compras para restaurar.'**
  String get noPurchasesFound;

  /// No description provided for @premiumActivated.
  ///
  /// In es, this message translates to:
  /// **'¡Premium activado!'**
  String get premiumActivated;

  /// No description provided for @purchasesRestored.
  ///
  /// In es, this message translates to:
  /// **'¡Compras restauradas!'**
  String get purchasesRestored;

  /// No description provided for @premiumActive.
  ///
  /// In es, this message translates to:
  /// **'Premium Activo'**
  String get premiumActive;

  /// No description provided for @freePlan.
  ///
  /// In es, this message translates to:
  /// **'Plan Gratis'**
  String get freePlan;

  /// No description provided for @yourSubscription.
  ///
  /// In es, this message translates to:
  /// **'Tu Suscripcion'**
  String get yourSubscription;

  /// No description provided for @started.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get started;

  /// No description provided for @expires.
  ///
  /// In es, this message translates to:
  /// **'Expira'**
  String get expires;

  /// No description provided for @plan.
  ///
  /// In es, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @yearly.
  ///
  /// In es, this message translates to:
  /// **'Anual'**
  String get yearly;

  /// No description provided for @upgradePromptDescription.
  ///
  /// In es, this message translates to:
  /// **'Obtén reportes ilimitados, exporta a PDF y analisis avanzados.'**
  String get upgradePromptDescription;

  /// No description provided for @viewPlans.
  ///
  /// In es, this message translates to:
  /// **'Ver Planes'**
  String get viewPlans;

  /// No description provided for @premiumFeatures.
  ///
  /// In es, this message translates to:
  /// **'Funciones Premium'**
  String get premiumFeatures;

  /// No description provided for @unlimitedReports.
  ///
  /// In es, this message translates to:
  /// **'Reportes Ilimitados'**
  String get unlimitedReports;

  /// No description provided for @exportToPdf.
  ///
  /// In es, this message translates to:
  /// **'Exportar a PDF'**
  String get exportToPdf;

  /// No description provided for @advancedAnalytics.
  ///
  /// In es, this message translates to:
  /// **'Analisis Avanzado'**
  String get advancedAnalytics;

  /// No description provided for @prioritySupport.
  ///
  /// In es, this message translates to:
  /// **'Soporte Prioritario'**
  String get prioritySupport;

  /// No description provided for @earlyAccessFeatures.
  ///
  /// In es, this message translates to:
  /// **'Funciones Anticipadas'**
  String get earlyAccessFeatures;

  /// No description provided for @premiumDescription.
  ///
  /// In es, this message translates to:
  /// **'Reportes y funciones ilimitadas'**
  String get premiumDescription;

  /// No description provided for @reportsThisMonth.
  ///
  /// In es, this message translates to:
  /// **'Reportes este mes'**
  String get reportsThisMonth;

  /// No description provided for @remaining.
  ///
  /// In es, this message translates to:
  /// **'restantes'**
  String get remaining;

  /// No description provided for @premiumFeature.
  ///
  /// In es, this message translates to:
  /// **'Funcion Premium'**
  String get premiumFeature;

  /// No description provided for @upgradeNow.
  ///
  /// In es, this message translates to:
  /// **'Mejorar Ahora'**
  String get upgradeNow;

  /// No description provided for @upgradeMessage.
  ///
  /// In es, this message translates to:
  /// **'Has alcanzado el limite de reportes gratis. ¡Mejora a Premium para reportes ilimitados y mas!'**
  String get upgradeMessage;

  /// No description provided for @topCategories.
  ///
  /// In es, this message translates to:
  /// **'Top Categorias'**
  String get topCategories;

  /// No description provided for @weeklyReport.
  ///
  /// In es, this message translates to:
  /// **'Reporte Semanal'**
  String get weeklyReport;

  /// No description provided for @customReport.
  ///
  /// In es, this message translates to:
  /// **'Reporte Personalizado'**
  String get customReport;

  /// No description provided for @never.
  ///
  /// In es, this message translates to:
  /// **'Nunca'**
  String get never;

  /// No description provided for @cancelSubscription.
  ///
  /// In es, this message translates to:
  /// **'Cancelar Suscripcion'**
  String get cancelSubscription;

  /// No description provided for @manageInStore.
  ///
  /// In es, this message translates to:
  /// **'Gestionar en Tienda'**
  String get manageInStore;

  /// No description provided for @appLocked.
  ///
  /// In es, this message translates to:
  /// **'Arcas esta bloqueado'**
  String get appLocked;

  /// No description provided for @enterPinToContinue.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu PIN para continuar'**
  String get enterPinToContinue;

  /// No description provided for @attemptsRemaining.
  ///
  /// In es, this message translates to:
  /// **'Intentos restantes: {count}'**
  String attemptsRemaining(int count);

  /// No description provided for @forgotPin.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu PIN?'**
  String get forgotPin;

  /// No description provided for @tooManyAttempts.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Usa \'Olvidaste mi PIN\' para reiniciar.'**
  String get tooManyAttempts;

  /// No description provided for @fingerprint.
  ///
  /// In es, this message translates to:
  /// **'Huella digital'**
  String get fingerprint;

  /// No description provided for @faceId.
  ///
  /// In es, this message translates to:
  /// **'Face ID'**
  String get faceId;

  /// No description provided for @usePin.
  ///
  /// In es, this message translates to:
  /// **'Usar PIN'**
  String get usePin;

  /// No description provided for @skip.
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get getStarted;

  /// No description provided for @onboardingTitle1.
  ///
  /// In es, this message translates to:
  /// **'Control total,\nsin complicaciones'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In es, this message translates to:
  /// **'Registra tus ingresos y gastos de forma simple.\nTu informacion, solo en tu telefono.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In es, this message translates to:
  /// **'Privacidad\na tu manera'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In es, this message translates to:
  /// **'Sin cloud, sin terceros, sin sorpresas.\nTus datos viajan solo entre vos y tu dispositivo.'**
  String get onboardingDesc2;

  /// No description provided for @createPin.
  ///
  /// In es, this message translates to:
  /// **'Crea tu PIN'**
  String get createPin;

  /// No description provided for @confirmPin.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu PIN'**
  String get confirmPin;

  /// No description provided for @enterFourDigitPin.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un PIN de 4-6 digitos'**
  String get enterFourDigitPin;

  /// No description provided for @confirmYourPin.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el mismo PIN nuevamente'**
  String get confirmYourPin;

  /// No description provided for @pinProtectionHint.
  ///
  /// In es, this message translates to:
  /// **'Este codigo protegera tus datos'**
  String get pinProtectionHint;

  /// No description provided for @pinsDoNotMatch.
  ///
  /// In es, this message translates to:
  /// **'Los PINs no coinciden. Intenta de nuevo.'**
  String get pinsDoNotMatch;

  /// No description provided for @pinTooWeak.
  ///
  /// In es, this message translates to:
  /// **'PIN muy debil'**
  String get pinTooWeak;

  /// No description provided for @pinWeakAdvice.
  ///
  /// In es, this message translates to:
  /// **'Evita usar fechas o numeros consecutivos'**
  String get pinWeakAdvice;

  /// No description provided for @enableBiometric.
  ///
  /// In es, this message translates to:
  /// **'Activar biometria'**
  String get enableBiometric;

  /// No description provided for @useBiometricToUnlock.
  ///
  /// In es, this message translates to:
  /// **'Desbloquea Arcas con solo\ntu {biometricType}'**
  String useBiometricToUnlock(String biometricType);

  /// No description provided for @enable.
  ///
  /// In es, this message translates to:
  /// **'Activar'**
  String get enable;

  /// No description provided for @forgotPinResetWarning.
  ///
  /// In es, this message translates to:
  /// **'Si reinicias la app, vas a perder el PIN y toda la configuracion. Vas a tener que configurar todo de nuevo.'**
  String get forgotPinResetWarning;

  /// No description provided for @resetApp.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar app'**
  String get resetApp;

  /// No description provided for @biometricFaster.
  ///
  /// In es, this message translates to:
  /// **'Mas rapido'**
  String get biometricFaster;

  /// No description provided for @biometricFasterDesc.
  ///
  /// In es, this message translates to:
  /// **'Accede al instante'**
  String get biometricFasterDesc;

  /// No description provided for @biometricSafer.
  ///
  /// In es, this message translates to:
  /// **'Mas seguro'**
  String get biometricSafer;

  /// No description provided for @biometricSaferDesc.
  ///
  /// In es, this message translates to:
  /// **'Datos unicos de tu dispositivo'**
  String get biometricSaferDesc;

  /// No description provided for @biometricEasier.
  ///
  /// In es, this message translates to:
  /// **'Mas facil'**
  String get biometricEasier;

  /// No description provided for @biometricEasierDesc.
  ///
  /// In es, this message translates to:
  /// **'Sin recordar contrasenas'**
  String get biometricEasierDesc;

  /// No description provided for @skipForNow.
  ///
  /// In es, this message translates to:
  /// **'Omitir por ahora'**
  String get skipForNow;

  /// No description provided for @biometricEnableError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo activar. Podes intentar mas tarde.'**
  String get biometricEnableError;
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
