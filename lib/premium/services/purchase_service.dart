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

  PurchaseService(this._db, {InAppPurchase? inAppPurchase})
      : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  Future<void> initialize() async {
    final isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      return;
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

  Future<bool> purchasePlan(PremiumPlan plan) async {
    final isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      return false;
    }

    final productId = plan.id == 'monthly' ? _productMonthly : _productYearly;
    final products = await getAvailableProducts();
    
    final product = products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Product not found'),
    );

    final purchaseParam = PurchaseParam(productDetails: product);
    
    try {
      final success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      if (success) {
        await _saveSubscription(plan);
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveSubscription(PremiumPlan plan) async {
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
    // TODO: Implement restore logic with platform-specific verification
    return false;
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