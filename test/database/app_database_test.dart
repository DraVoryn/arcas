import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:arcas/database/app_database.dart';

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => '.';
  
  @override
  Future<String?> getTemporaryPath() async => '.';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUpAll(() {
    PathProviderPlatform.instance = FakePathProviderPlatform();
  });

  group('AppDatabase', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    group('Transactions', () {
      test('should insert and retrieve transaction', () async {
        final id = await database.insertTransaction(
          TransactionsCompanion.insert(
            description: 'Test transaction',
            amount: 100.0,
            date: DateTime.now(),
            type: 'income',
          ),
        );

        expect(id, greaterThan(0));

        final transactions = await database.getAllTransactions();
        expect(transactions.length, 1);
        expect(transactions.first.description, 'Test transaction');
        expect(transactions.first.amount, 100.0);
      });

      test('should update transaction', () async {
        await database.insertTransaction(
          TransactionsCompanion.insert(
            description: 'Original',
            amount: 50.0,
            date: DateTime.now(),
            type: 'expense',
          ),
        );

        final transactions = await database.getAllTransactions();
        final transaction = transactions.first;

        await database.updateTransaction(
          transaction.copyWith(description: 'Updated'),
        );

        final updated = await database.getAllTransactions();
        expect(updated.first.description, 'Updated');
      });

      test('should delete transaction', () async {
        final id = await database.insertTransaction(
          TransactionsCompanion.insert(
            description: 'To delete',
            amount: 25.0,
            date: DateTime.now(),
            type: 'income',
          ),
        );

        await database.deleteTransaction(id);

        final transactions = await database.getAllTransactions();
        expect(transactions.isEmpty, isTrue);
      });

      test('should get transactions by date range', () async {
        final now = DateTime.now();
        
        await database.insertTransaction(
          TransactionsCompanion.insert(
            description: 'Last week',
            amount: 100.0,
            date: now.subtract(const Duration(days: 7)),
            type: 'income',
          ),
        );

        await database.insertTransaction(
          TransactionsCompanion.insert(
            description: 'Today',
            amount: 50.0,
            date: now,
            type: 'income',
          ),
        );

        final result = await database.getTransactionsByDateRange(
          now.subtract(const Duration(days: 5)),
          now.add(const Duration(days: 1)),
        );

        expect(result.length, 1);
        expect(result.first.description, 'Today');
      });
    });

    group('Categories', () {
      test('should insert and retrieve category', () async {
        final id = await database.insertCategory(
          CategoriesCompanion.insert(
            name: 'Food',
            icon: 'restaurant',
            color: '#FF5733',
          ),
        );

        expect(id, greaterThan(0));

        final categories = await database.getAllCategories();
        expect(categories.length, 1);
        expect(categories.first.name, 'Food');
      });

      test('should delete category', () async {
        final id = await database.insertCategory(
          CategoriesCompanion.insert(
            name: 'To delete',
            icon: 'icon',
            color: '#000000',
          ),
        );

        await database.deleteCategory(id);

        final categories = await database.getAllCategories();
        expect(categories.isEmpty, isTrue);
      });
    });

    group('Streams', () {
      test('should watch transactions', () async {
        await database.insertTransaction(
          TransactionsCompanion.insert(
            description: 'Stream test',
            amount: 10.0,
            date: DateTime.now(),
            type: 'income',
          ),
        );

        await expectLater(
          database.watchAllTransactions(),
          emits(predicate<List<Transaction>>((list) => list.length == 1)),
        );
      });

      test('should watch categories', () async {
        await database.insertCategory(
          CategoriesCompanion.insert(
            name: 'Test category',
            icon: 'icon',
            color: '#FFFFFF',
          ),
        );

        await expectLater(
          database.watchAllCategories(),
          emits(predicate<List<Category>>((list) => list.length == 1)),
        );
      });
    });
  });
}