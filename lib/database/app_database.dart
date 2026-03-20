import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text().withLength(min: 1, max: 255)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  IntColumn get categoryId => integer().nullable()();
  TextColumn get type => text().withLength(min: 1, max: 10)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get icon => text().withLength(min: 1, max: 50)();
  TextColumn get color => text().withLength(min: 1, max: 7)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Subscriptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get planId => text().withLength(min: 1, max: 50)();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get expirationDate => dateTime().nullable()();
  TextColumn get status => text().withLength(min: 1, max: 20)();
  TextColumn get storeTransactionId => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class ReportUsage extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get month => integer()();
  IntColumn get year => integer()();
  IntColumn get reportsGenerated => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastReportDate => dateTime().nullable()();
  
  @override
  List<Set<Column>> get uniqueKeys => [{month, year}];
}

class Reports extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text().withLength(min: 1, max: 20)();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  RealColumn get totalIncome => real()();
  RealColumn get totalExpense => real()();
  RealColumn get balance => real()();
  TextColumn get categoryBreakdownJson => text()();
  DateTimeColumn get generatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Transactions, Categories, Subscriptions, ReportUsage, Reports])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations go here
        // Example for v2 -> v3:
        // if (from < 3) {
        //   await m.addColumn('transactions', transactions.newColumn);
        // }
      },
      beforeOpen: (details) async {
        // Enable foreign keys and optimize
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  @override
  int get schemaVersion => 3;

  Future<List<Transaction>> getAllTransactions() => select(transactions).get();

  Stream<List<Transaction>> watchAllTransactions() => select(transactions).watch();

  Future<int> insertTransaction(TransactionsCompanion entry) =>
      into(transactions).insert(entry);

  Future<bool> updateTransaction(Transaction entry) =>
      update(transactions).replace(entry);

  Future<int> deleteTransaction(int id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();

  Future<List<Category>> getAllCategories() => select(categories).get();

  Stream<List<Category>> watchAllCategories() => select(categories).watch();

  Future<int> insertCategory(CategoriesCompanion entry) =>
      into(categories).insert(entry);

  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((t) => t.id.equals(id))).go();

  Future<void> updateCategory(Category category) {
    return (update(categories)..where((t) => t.id.equals(category.id)))
        .write(CategoriesCompanion(
          name: Value(category.name),
          icon: Value(category.icon),
          color: Value(category.color),
        ));
  }

  Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end) {
    return (select(transactions)
          ..where((t) => t.date.isBetweenValues(start, end)))
        .get();
  }

  Future<List<Subscription>> getActiveSubscriptions() async {
    final now = DateTime.now();
    return (select(subscriptions)
          ..where((s) => s.status.equals('active')))
        .get()
        .then((list) => list.where((sub) =>
            sub.expirationDate == null || sub.expirationDate!.isAfter(now)).toList());
  }

  Future<int> insertSubscription(SubscriptionsCompanion entry) =>
      into(subscriptions).insert(entry);

  Future<Subscription?> getCurrentSubscription() async {
    final subs = await getActiveSubscriptions();
    return subs.isEmpty ? null : subs.first;
  }

  Future<int> insertReport(ReportsCompanion entry) =>
      into(reports).insert(entry);

  Future<List<Report>> getReportsByDateRange(DateTime start, DateTime end) {
    return (select(reports)
          ..where((r) => r.startDate.isBetweenValues(start, end)))
        .get();
  }

  Future<Report?> getLatestReport() async {
    // Usar .get() + first para evitar "too many elements" si hay duplicados
    final results = await (select(reports)
          ..orderBy([(t) => OrderingTerm.desc(t.generatedAt)]))
        .get();
    return results.isEmpty ? null : results.first;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'arcas.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
