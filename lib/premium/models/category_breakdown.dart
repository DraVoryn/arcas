class CategoryBreakdown {
  final int categoryId;
  final String categoryName;
  final double amount;
  final double percentage;
  final String? icon;
  final String? color;

  const CategoryBreakdown({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
    this.icon,
    this.color,
  });

  CategoryBreakdown copyWith({
    int? categoryId,
    String? categoryName,
    double? amount,
    double? percentage,
    String? icon,
    String? color,
  }) {
    return CategoryBreakdown(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      amount: amount ?? this.amount,
      percentage: percentage ?? this.percentage,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'amount': amount,
      'percentage': percentage,
      'icon': icon,
      'color': color,
    };
  }

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }
}