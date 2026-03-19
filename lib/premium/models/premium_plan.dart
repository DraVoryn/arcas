class PremiumPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String billingPeriod;
  final List<String> features;

  const PremiumPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.billingPeriod,
    required this.features,
  });

  PremiumPlan copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? billingPeriod,
    List<String>? features,
  }) {
    return PremiumPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      billingPeriod: billingPeriod ?? this.billingPeriod,
      features: features ?? this.features,
    );
  }

  static const List<PremiumPlan> defaultPlans = [
    PremiumPlan(
      id: 'monthly',
      name: 'Premium Monthly',
      description: 'Unlock unlimited reports and premium features',
      price: 4.99,
      billingPeriod: 'month',
      features: [
        'Unlimited reports',
        'Export to PDF',
        'Advanced analytics',
        'Priority support',
      ],
    ),
    PremiumPlan(
      id: 'yearly',
      name: 'Premium Yearly',
      description: 'Save 40% with annual billing',
      price: 35.99,
      billingPeriod: 'year',
      features: [
        'Unlimited reports',
        'Export to PDF',
        'Advanced analytics',
        'Priority support',
        'Early access to new features',
      ],
    ),
  ];
}