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
      description: 'Reportes avanzados, predicciones y funciones pro',
      price: 2.99,
      billingPeriod: 'month',
      features: [
        'Reportes avanzados ilimitados',
        'Modelo de predicciones',
        'Reporte pro con graficos detallados',
        'Exportar a PDF',
        'Soporte prioritario',
      ],
    ),
    PremiumPlan(
      id: 'yearly',
      name: 'Premium Yearly',
      description: 'Ahorra 33% con facturacion anual',
      price: 23.88,
      billingPeriod: 'year',
      features: [
        'Todo lo de Monthly',
        'Reporte pro con graficos detallados',
        'Modelo de predicciones',
        'Acceso anticipado a nuevas funciones',
      ],
    ),
  ];
}