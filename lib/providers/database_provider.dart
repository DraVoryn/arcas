import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arcas/database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Database not initialized');
});
