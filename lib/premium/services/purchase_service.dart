import 'dart:async';
import 'package:drift/drift.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:arcas/database/app_database.dart';
import 'package:arcas/premium/models/premium_plan.dart';
import 'package:arcas/premium/models/subscription.dart' as model;

class PurchaseService {
  final AppDatabase _db;
  final InAppPurchase _inAppPurchase;
  
  static const String _productMonthly = 'premium_monthly';
  static const String _productYearly = 'premium_yearly';

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  Completer<bool>? _purchaseCompleter;

  PurchaseService(this._db, {InAppPurchase? inAppPurchase})
      : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  Future<void> initialize() async {
    final isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      return;
    }

    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdate,
      onError: _handlePurchaseError,
    );
  }

  void dispose() {
    _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final details in purchaseDetailsList) {
      switch (details.status) {
        case PurchaseStatus.purchased:
          _handlePurchased(details);
          break;
        case PurchaseStatus.restored:
          _handleRestored(details);
          break;
        case PurchaseStatus.error:
          _handleError(details);
          break;
        case PurchaseStatus.pending:
        case PurchaseStatus.canceled:
          break;
      }
    }
  }

  void _handlePurchased(PurchaseDetails details) {
    if (_purchaseCompleter != null && !_purchaseCompleter!.isCompleted) {
      _purchaseCompleter!.complete(true);
    }
  }

  void _handleRestored(PurchaseDetails details) {
    if (_purchaseCompleter != null && !_purchaseCompleter!.isCompleted) {
      _purchaseCompleter!.complete(true);
    }
  }

  void _handleError(PurchaseDetails details) {
    if (_purchaseCompleter != null && !_purchaseCompleter!.isCompleted) {
      _purchaseCompleter!.complete(false);
    }
  }

  void _handlePurchaseError(Object error) {
    if (_purchaseCompleter != null && !_purchaseCompleter!.isCompleted) {
      _purchaseCompleter!.complete(false);
    }
  }

  Future<List<ProductDetails>> getAvailableProducts() async {
    final isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      return [];
    }

    try {
      final productIds = <String>{_productMonthly, _productYearly};
      final response = await _inAppPurchase.queryProductDetails(productIds);
      return response.productDetails;
    } catch (e) {
      return [];
    }
  }

  String _getProductId(String planId) {
    return planId == 'monthly' ? _productMonthly : _productYearly;
  }

  PremiumPlan? _getPlanFromProductId(String productId) {
    if (productId == _productMonthly) {
      return PremiumPlan.defaultPlans.firstWhere(
        (p) => p.id == 'monthly',
        orElse: () => PremiumPlan.defaultPlans.first,
      );
    } else if (productId == _productYearly) {
      return PremiumPlan.defaultPlans.firstWhere(
        (p) => p.id == 'yearly',
        orElse: () => PremiumPlan.defaultPlans.last,
      );
    }
    return null;
  }

  Future<bool> purchasePlan(PremiumPlan plan) async {
    final isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      return false;
    }

    final productId = _getProductId(plan.id);
    final products = await getAvailableProducts();
    
    if (products.isEmpty) {
      return false;
    }

    final product = products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Product not found: $productId'),
    );

    _purchaseCompleter = Completer<bool>();
    final purchaseParam = PurchaseParam(productDetails: product);

    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

    final result = await _purchaseCompleter!.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () => false,
    );

    _purchaseCompleter = null;

    if (result) {
      await _saveSubscriptionFromPurchase(productId);
    }

    return result;
  }

  Future<void> _saveSubscriptionFromPurchase(String productId) async {
    final plan = _getPlanFromProductId(productId);
    if (plan == null) return;

    final now = DateTime.now();
    DateTime? expiration;
    
    if (plan.billingPeriod == 'month') {
      expiration = DateTime(now.year, now.month + 1, now.day);
    } else if (plan.billingPeriod == 'year') {
      expiration = DateTime(now.year + 1, now.month, now.day);
    }

    await _db.into(_db.subscriptions).insert(
      SubscriptionsCompanion.insert(
        planId: plan.id,
        startDate: now,
        expirationDate: Value(expiration),
        status: 'active',
      ),
    );
  }

  Future<bool> restorePurchases() async {
    final isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      return false;
    }

    _purchaseCompleter = Completer<bool>();
    
    try {
      await _inAppPurchase.restorePurchases(
        applicationUserName: null,
      );
      
      final result = await _purchaseCompleter!.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => false,
      );

      _purchaseCompleter = null;
      return result;
    } catch (e) {
      _purchaseCompleter = null;
      return false;
    }
  }

  Future<model.Subscription?> getCurrentSubscription() async {
    final dbSub = await _db.getCurrentSubscription();
    if (dbSub == null) return null;

    return model.Subscription(
      id: dbSub.id,
      planId: dbSub.planId,
      startDate: dbSub.startDate,
      expirationDate: dbSub.expirationDate,
      status: model.SubscriptionStatus.values.firstWhere(
        (s) => s.name == dbSub.status,
        orElse: () => model.SubscriptionStatus.pending,
      ),
      storeTransactionId: dbSub.storeTransactionId,
      createdAt: dbSub.createdAt,
    );
  }

  Future<bool> isPremium() async {
    final sub = await getCurrentSubscription();
    return sub?.isPremium ?? false;
  }
}
