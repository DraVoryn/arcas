enum SubscriptionStatus { active, expired, cancelled, pending }

class Subscription {
  final int? id;
  final String planId;
  final DateTime startDate;
  final DateTime? expirationDate;
  final SubscriptionStatus status;
  final String? storeTransactionId;
  final DateTime? createdAt;

  const Subscription({
    this.id,
    required this.planId,
    required this.startDate,
    this.expirationDate,
    required this.status,
    this.storeTransactionId,
    this.createdAt,
  });

  bool get isActive =>
      status == SubscriptionStatus.active &&
      (expirationDate == null || expirationDate!.isAfter(DateTime.now()));

  bool get isPremium => isActive && (planId == 'monthly' || planId == 'yearly');

  Subscription copyWith({
    int? id,
    String? planId,
    DateTime? startDate,
    DateTime? expirationDate,
    SubscriptionStatus? status,
    String? storeTransactionId,
    DateTime? createdAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      startDate: startDate ?? this.startDate,
      expirationDate: expirationDate ?? this.expirationDate,
      status: status ?? this.status,
      storeTransactionId: storeTransactionId ?? this.storeTransactionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}