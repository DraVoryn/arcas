import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcas/database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Database not initialized');
});

/// Extension para agregar métodos de limpieza de datos
extension DatabaseClearExtension on AppDatabase {
  /// Borra todos los datos de la base de datos.
  /// Útil para "Borrar cuenta" o "Reset app".
  Future<void> clearAllData() async {
    await delete(transactions).go();
    await delete(categories).go();
    await delete(subscriptions).go();
    await delete(reportUsage).go();
    await delete(reports).go();
  }
}
