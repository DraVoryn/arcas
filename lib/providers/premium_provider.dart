import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcas/premium/models/premium_plan.dart';
import 'package:arcas/premium/models/subscription.dart' as model;
import 'package:arcas/premium/models/report.dart' as model;
import 'package:arcas/premium/models/freemium_limits.dart';
import 'package:arcas/premium/services/freemium_service.dart';
import 'package:arcas/premium/services/report_service.dart';
import 'package:arcas/premium/services/purchase_service.dart';
import 'package:arcas/providers/database_provider.dart';

final freemiumServiceProvider = Provider<FreemiumService>((ref) {
  final db = ref.watch(databaseProvider);
  return FreemiumService(db);
});

final reportServiceProvider = Provider<ReportService>((ref) {
  final db = ref.watch(databaseProvider);
  return ReportService(db);
});

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final db = ref.watch(databaseProvider);
  return PurchaseService(db);
});

final freemiumLimitsProvider = Provider<FreemiumLimits>((ref) {
  return const FreemiumLimits();
});

class PremiumState {
  final bool isPremium;
  final model.Subscription? subscription;
  final int reportsGeneratedThisMonth;
  final bool isLoading;
  final String? error;

  const PremiumState({
    this.isPremium = false,
    this.subscription,
    this.reportsGeneratedThisMonth = 0,
    this.isLoading = false,
    this.error,
  });

  PremiumState copyWith({
    bool? isPremium,
    model.Subscription? subscription,
    int? reportsGeneratedThisMonth,
    bool? isLoading,
    String? error,
  }) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      subscription: subscription ?? this.subscription,
      reportsGeneratedThisMonth: reportsGeneratedThisMonth ?? this.reportsGeneratedThisMonth,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get remainingReports {
    if (isPremium) return -1;
    final limits = const FreemiumLimits();
    return limits.remainingReports(
      reportsGeneratedThisMonth: reportsGeneratedThisMonth,
      isPremium: isPremium,
    );
  }

  bool canGenerateReport() {
    final limits = const FreemiumLimits();
    return limits.canGenerateReport(
      reportsGeneratedThisMonth: reportsGeneratedThisMonth,
      isPremium: isPremium,
    );
  }
}

class PremiumNotifier extends StateNotifier<PremiumState> {
  final PurchaseService _purchaseService;
  final FreemiumService _freemiumService;

  PremiumNotifier(this._purchaseService, this._freemiumService)
      : super(const PremiumState(isLoading: true)) {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final subscription = await _purchaseService.getCurrentSubscription();
      final reportsGenerated = await _freemiumService.getReportsGeneratedThisMonth();
      
      state = state.copyWith(
        isPremium: subscription?.isPremium ?? false,
        subscription: subscription,
        reportsGeneratedThisMonth: reportsGenerated,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await _loadState();
  }

  Future<PurchaseResult> purchasePlan(PremiumPlan plan) async {
    try {
      final result = await _purchaseService.purchasePlan(plan);
      if (result.success) {
        await _loadState();
      }
      if (result.error != null && result.errorMessage != null) {
        state = state.copyWith(error: result.errorMessage);
      }
      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return PurchaseResult.error(PurchaseErrorType.unknown, e.toString());
    }
  }

  Future<bool> restorePurchases() async {
    try {
      final success = await _purchaseService.restorePurchases();
      if (success) {
        await _loadState();
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final premiumNotifierProvider =
    StateNotifierProvider<PremiumNotifier, PremiumState>((ref) {
  final purchaseService = ref.watch(purchaseServiceProvider);
  final freemiumService = ref.watch(freemiumServiceProvider);
  return PremiumNotifier(purchaseService, freemiumService);
});

class ReportGenerationState {
  final bool isGenerating;
  final model.Report? lastReport;
  final String? error;

  const ReportGenerationState({
    this.isGenerating = false,
    this.lastReport,
    this.error,
  });

  ReportGenerationState copyWith({
    bool? isGenerating,
    model.Report? lastReport,
    String? error,
  }) {
    return ReportGenerationState(
      isGenerating: isGenerating ?? this.isGenerating,
      lastReport: lastReport ?? this.lastReport,
      error: error,
    );
  }
}

class ReportGenerationNotifier extends StateNotifier<ReportGenerationState> {
  final ReportService _reportService;
  final FreemiumService _freemiumService;
  final PremiumNotifier _premiumNotifier;

  ReportGenerationNotifier(
    this._reportService,
    this._freemiumService,
    this._premiumNotifier,
  ) : super(const ReportGenerationState());

  Future<model.Report?> generateReport({
    required model.ReportType type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final premiumState = _premiumNotifier.state;
    if (!premiumState.canGenerateReport()) {
      state = state.copyWith(error: 'Report limit reached');
      return null;
    }

    state = state.copyWith(isGenerating: true, error: null);

    try {
      final report = await _reportService.generateReport(
        type: type,
        startDate: startDate,
        endDate: endDate,
      );

      if (!premiumState.isPremium) {
        await _freemiumService.incrementUsage();
        await _premiumNotifier.refresh();
      }

      state = state.copyWith(
        isGenerating: false,
        lastReport: report,
      );

      return report;
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
      );
      return null;
    }
  }
}

final reportGenerationProvider =
    StateNotifierProvider<ReportGenerationNotifier, ReportGenerationState>((ref) {
  final reportService = ref.watch(reportServiceProvider);
  final freemiumService = ref.watch(freemiumServiceProvider);
  final premiumNotifier = ref.watch(premiumNotifierProvider.notifier);
  return ReportGenerationNotifier(reportService, freemiumService, premiumNotifier);
});

final latestReportProvider = FutureProvider<model.Report?>((ref) async {
  final reportService = ref.watch(reportServiceProvider);
  return reportService.getLatestReport();
});