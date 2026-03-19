class FreemiumLimits {
  final int freeReportLimit;
  final int reportResetDays;

  const FreemiumLimits({
    this.freeReportLimit = 3,
    this.reportResetDays = 30,
  });

  bool canGenerateReport({
    required int reportsGeneratedThisMonth,
    required bool isPremium,
  }) {
    if (isPremium) return true;
    return reportsGeneratedThisMonth < freeReportLimit;
  }

  int remainingReports({
    required int reportsGeneratedThisMonth,
    required bool isPremium,
  }) {
    if (isPremium) return -1;
    final remaining = freeReportLimit - reportsGeneratedThisMonth;
    return remaining < 0 ? 0 : remaining;
  }

  double usagePercentage({
    required int reportsGeneratedThisMonth,
    required bool isPremium,
  }) {
    if (isPremium) return 0.0;
    return (reportsGeneratedThisMonth / freeReportLimit).clamp(0.0, 1.0);
  }
}