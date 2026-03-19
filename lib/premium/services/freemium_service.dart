import 'package:drift/drift.dart';
import 'package:arcas/database/app_database.dart';
import 'package:arcas/premium/models/freemium_limits.dart';

class FreemiumService {
  final AppDatabase _db;
  final FreemiumLimits _limits;

  FreemiumService(this._db, {FreemiumLimits? limits})
      : _limits = limits ?? const FreemiumLimits();

  Future<int> getReportsGeneratedThisMonth() async {
    final now = DateTime.now();
    final usage = await _getOrCreateUsage(now.month, now.year);
    return usage!.reportsGenerated;
  }

  Future<bool> canGenerateReport({required bool isPremium}) async {
    final generated = await getReportsGeneratedThisMonth();
    return _limits.canGenerateReport(
      reportsGeneratedThisMonth: generated,
      isPremium: isPremium,
    );
  }

  Future<int> getRemainingReports({required bool isPremium}) async {
    final generated = await getReportsGeneratedThisMonth();
    return _limits.remainingReports(
      reportsGeneratedThisMonth: generated,
      isPremium: isPremium,
    );
  }

  Future<void> incrementUsage() async {
    final now = DateTime.now();
    final usage = await _getOrCreateUsage(now.month, now.year);
    if (usage == null) return;
    
    await (_db.update(_db.reportUsage)
          ..where((t) => t.id.equals(usage.id)))
        .write(
      ReportUsageCompanion(
        reportsGenerated: Value(usage.reportsGenerated + 1),
        lastReportDate: Value(now),
      ),
    );
  }

  Future<ReportUsageData?> _getOrCreateUsage(int month, int year) async {
    final query = _db.select(_db.reportUsage)
      ..where((t) => t.month.equals(month) & t.year.equals(year));
    
    var usage = await query.getSingleOrNull();
    
    if (usage == null) {
      await _db.into(_db.reportUsage).insert(
        ReportUsageCompanion.insert(
          month: month,
          year: year,
        ),
      );
      usage = await query.getSingle();
    }
    
    return usage;
  }

  Future<void> resetMonthlyUsage() async {
    final now = DateTime.now();
    final lastMonth = now.month == 1 ? 12 : now.month - 1;
    final lastYear = now.month == 1 ? now.year - 1 : now.year;
    
    await (_db.delete(_db.reportUsage)
          ..where((t) => t.month.equals(lastMonth) & t.year.equals(lastYear)))
        .go();
  }
}