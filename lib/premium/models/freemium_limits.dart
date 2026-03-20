class FreemiumLimits {
  final int freeBasicReportLimit;
  final int vipAdvancedReportLimit;
  final int vipPredictionLimit;
  final int reportResetDays;

  const FreemiumLimits({
    this.freeBasicReportLimit = 3,
    this.vipAdvancedReportLimit = 5,
    this.vipPredictionLimit = 2, // 2 predictions per month for VIP
    this.reportResetDays = 30,
  });

  bool canGenerateBasicReport({
    required int reportsGeneratedThisMonth,
    required bool isVip,
    required bool isPremium,
  }) {
    if (isVip || isPremium) return true;
    return reportsGeneratedThisMonth < freeBasicReportLimit;
  }

  bool canGenerateAdvancedReport({
    required int advancedReportsGeneratedThisMonth,
    required bool isVip,
    required bool isPremium,
  }) {
    if (isPremium) return true;
    if (isVip) return advancedReportsGeneratedThisMonth < vipAdvancedReportLimit;
    return false; // Free tier cannot generate advanced reports
  }

  bool canGeneratePrediction({
    required int predictionsGeneratedThisMonth,
    required bool isVip,
    required bool isPremium,
  }) {
    if (isPremium) return true;
    if (isVip) return predictionsGeneratedThisMonth < vipPredictionLimit;
    return false; // Free tier cannot generate predictions
  }

  int remainingBasicReports({
    required int reportsGeneratedThisMonth,
    required bool isVip,
    required bool isPremium,
  }) {
    if (isVip || isPremium) return -1;
    final remaining = freeBasicReportLimit - reportsGeneratedThisMonth;
    return remaining < 0 ? 0 : remaining;
  }

  int remainingAdvancedReports({
    required int advancedReportsGeneratedThisMonth,
    required bool isVip,
    required bool isPremium,
  }) {
    if (isPremium) return -1;
    if (isVip) {
      final remaining = vipAdvancedReportLimit - advancedReportsGeneratedThisMonth;
      return remaining < 0 ? 0 : remaining;
    }
    return 0; // Free tier has 0 advanced reports
  }

  int remainingPredictions({
    required int predictionsGeneratedThisMonth,
    required bool isVip,
    required bool isPremium,
  }) {
    if (isPremium) return -1;
    if (isVip) {
      final remaining = vipPredictionLimit - predictionsGeneratedThisMonth;
      return remaining < 0 ? 0 : remaining;
    }
    return 0; // Free tier has 0 predictions
  }

  double basicUsagePercentage({
    required int reportsGeneratedThisMonth,
    required bool isVip,
    required bool isPremium,
  }) {
    if (isVip || isPremium) return 0.0;
    return (reportsGeneratedThisMonth / freeBasicReportLimit).clamp(0.0, 1.0);
  }

  double advancedUsagePercentage({
    required int advancedReportsGeneratedThisMonth,
    required bool isVip,
    required bool isPremium,
  }) {
    if (isPremium) return 0.0;
    if (isVip) {
      return (advancedReportsGeneratedThisMonth / vipAdvancedReportLimit).clamp(0.0, 1.0);
    }
    return 0.0; // Free tier
  }

  double predictionUsagePercentage({
    required int predictionsGeneratedThisMonth,
    required bool isVip,
    required bool isPremium,
  }) {
    if (isPremium) return 0.0;
    if (isVip) {
      return (predictionsGeneratedThisMonth / vipPredictionLimit).clamp(0.0, 1.0);
    }
    return 0.0; // Free tier
  }
}