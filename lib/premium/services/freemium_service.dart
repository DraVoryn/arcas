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
    final usage = await _getOrCreateUsageEntry(now.month, now.year);
    return usage!.reportsGenerated;
  }

  Future<int> getPredictionsGeneratedThisMonth() async {
    final now = DateTime.now();
    final usage = await _getOrCreateUsageEntry(now.month, now.year);
    return usage!.predictionsGenerated;
  }

  Future<bool> canGenerateReport({required bool isVip, required bool isPremium}) async {
    final generated = await getReportsGeneratedThisMonth();
    return _limits.canGenerateBasicReport(
      reportsGeneratedThisMonth: generated,
      isVip: isVip,
      isPremium: isPremium,
    );
  }

  Future<bool> canGenerateAdvancedReport({required bool isVip, required bool isPremium}) async {
    final generated = await getReportsGeneratedThisMonth();
    return _limits.canGenerateAdvancedReport(
      advancedReportsGeneratedThisMonth: generated,
      isVip: isVip,
      isPremium: isPremium,
    );
  }

  Future<bool> canGeneratePrediction({required bool isVip, required bool isPremium}) async {
    final generated = await getPredictionsGeneratedThisMonth();
    return _limits.canGeneratePrediction(
      predictionsGeneratedThisMonth: generated,
      isVip: isVip,
      isPremium: isPremium,
    );
  }

  Future<int> getRemainingReports({required bool isVip, required bool isPremium}) async {
    final generated = await getReportsGeneratedThisMonth();
    return _limits.remainingBasicReports(
      reportsGeneratedThisMonth: generated,
      isVip: isVip,
      isPremium: isPremium,
    );
  }

  Future<int> getRemainingAdvancedReports({required bool isVip, required bool isPremium}) async {
    final generated = await getReportsGeneratedThisMonth();
    return _limits.remainingAdvancedReports(
      advancedReportsGeneratedThisMonth: generated,
      isVip: isVip,
      isPremium: isPremium,
    );
  }

  Future<int> getRemainingPredictions({required bool isVip, required bool isPremium}) async {
    final generated = await getPredictionsGeneratedThisMonth();
    return _limits.remainingPredictions(
      predictionsGeneratedThisMonth: generated,
      isVip: isVip,
      isPremium: isPremium,
    );
  }

  Future<void> incrementUsage() async {
    final now = DateTime.now();
    final usage = await _getOrCreateUsageEntry(now.month, now.year);
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

  Future<void> incrementPredictionUsage() async {
    final now = DateTime.now();
    final usage = await _getOrCreateUsageEntry(now.month, now.year);
    if (usage == null) return;
    
    await (_db.update(_db.reportUsage)
          ..where((t) => t.id.equals(usage.id)))
    .write(
      ReportUsageCompanion(
        predictionsGenerated: Value(usage.predictionsGenerated + 1),
        lastPredictionDate: Value(now),
      ),
    );
  }

  Future<ReportUsageData?> _getOrCreateUsageEntry(int month, int year) async {
    print('[FreemiumService] _getOrCreateUsageEntry($month, $year)');
    
    // Usar query segura que nunca tira "too many elements"
    final query = _db.select(_db.reportUsage)
      ..where((t) => t.month.equals(month) & t.year.equals(year));
    
    // Usar .get() en lugar de .getSingle() para evitar el error
    final existing = await query.get();
    print('[FreemiumService] Found ${existing.length} rows for month=$month, year=$year');
    
    if (existing.isEmpty) {
      // No existe, insertar con ON CONFLICT para evitar duplicados
      print('[FreemiumService] No existing record, inserting...');
      await _db.into(_db.reportUsage).insert(
        ReportUsageCompanion.insert(
          month: month,
          year: year,
        ),
        mode: InsertMode.insertOrReplace,
      );
      
      // Verificar que se insertó correctamente
      final afterInsert = await query.get();
      print('[FreemiumService] After insert: ${afterInsert.length} rows');
      
      if (afterInsert.isEmpty) {
        print('[FreemiumService] ERROR: Insert failed');
        return null;
      }
      return afterInsert.first;
    } else if (existing.length == 1) {
      //刚好一行，返回它
      print('[FreemiumService] Returning existing record');
      return existing.first;
    } else {
      // Múltiples filas (duplicados) - 返回第一行并清理
      print('[FreemiumService] WARNING: ${existing.length} duplicates found, using first');
      // En producción, deberías limpiar los duplicados aquí
      return existing.first;
    }
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