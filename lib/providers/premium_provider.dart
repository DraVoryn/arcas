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

class PremiumNotifier extends AsyncNotifier<PremiumState> {
  @override
  Future<PremiumState> build() async {
    return _loadState();
  }

  Future<PremiumState> _loadState() async {
    try {
      final purchaseService = ref.read(purchaseServiceProvider);
      final freemiumService = ref.read(freemiumServiceProvider);
      final subscription = await purchaseService.getCurrentSubscription();
      final reportsGenerated = await freemiumService.getReportsGeneratedThisMonth();
      
      return PremiumState(
        isPremium: subscription?.isPremium ?? false,
        subscription: subscription,
        reportsGeneratedThisMonth: reportsGenerated,
        isLoading: false,
      );
    } catch (e) {
      return PremiumState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _loadState());
  }

  Future<PurchaseResult> purchasePlan(PremiumPlan plan) async {
    try {
      final purchaseService = ref.read(purchaseServiceProvider);
      final result = await purchaseService.purchasePlan(plan);
      if (result.success) {
        await refresh();
      }
      if (result.error != null && result.errorMessage != null) {
        state = state.whenData((s) => s.copyWith(error: result.errorMessage));
      }
      return result;
    } catch (e) {
      state = state.whenData((s) => s.copyWith(error: e.toString()));
      return PurchaseResult.error(PurchaseErrorType.unknown, e.toString());
    }
  }

  Future<bool> restorePurchases() async {
    try {
      final purchaseService = ref.read(purchaseServiceProvider);
      final success = await purchaseService.restorePurchases();
      if (success) {
        await refresh();
      }
      return success;
    } catch (e) {
      state = state.whenData((s) => s.copyWith(error: e.toString()));
      return false;
    }
  }
}

final premiumNotifierProvider =
    AsyncNotifierProvider<PremiumNotifier, PremiumState>(PremiumNotifier.new);

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

class ReportGenerationNotifier extends Notifier<ReportGenerationState> {
  @override
  ReportGenerationState build() {
    return const ReportGenerationState();
  }

  Future<model.Report?> generateReport({
    required model.ReportType type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final premiumStateAsync = ref.read(premiumNotifierProvider);
    final premiumState = premiumStateAsync.value ?? const PremiumState();
    
    if (!premiumState.canGenerateReport()) {
      state = state.copyWith(error: 'Report limit reached');
      return null;
    }

    state = state.copyWith(isGenerating: true, error: null);

    try {
      final reportService = ref.read(reportServiceProvider);
      final freemiumService = ref.read(freemiumServiceProvider);
      
      final report = await reportService.generateReport(
        type: type,
        startDate: startDate,
        endDate: endDate,
      );

      if (!premiumState.isPremium) {
        await freemiumService.incrementUsage();
        ref.read(premiumNotifierProvider.notifier).refresh();
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
    NotifierProvider<ReportGenerationNotifier, ReportGenerationState>(
        ReportGenerationNotifier.new);

final latestReportProvider = FutureProvider<model.Report?>((ref) async {
  final reportService = ref.watch(reportServiceProvider);
  return reportService.getLatestReport();
});
