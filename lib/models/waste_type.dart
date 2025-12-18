class WasteType {
  final int id;
  final String name;
  final double pricePerKg;
  final double bonusThreshold;
  final double bonusAmount;

  WasteType({
    required this.id,
    required this.name,
    required this.pricePerKg,
    required this.bonusThreshold,
    required this.bonusAmount,
  });

  factory WasteType.fromJson(Map<String, dynamic> json) {
    return WasteType(
      id: json['id'] as int,
      name: json['name'] as String,
      pricePerKg: _parseDouble(json['price_per_kg']),
      bonusThreshold: _parseDouble(json['bonus_threshold']),
      bonusAmount: _parseDouble(json['bonus_amount']),
    );
  }

  // Helper to safely parse numeric values
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price_per_kg': pricePerKg,
      'bonus_threshold': bonusThreshold,
      'bonus_amount': bonusAmount,
    };
  }

  // Calculate estimated price
  double calculateEstimate(double weight) {
    if (weight > bonusThreshold) {
      return weight * (pricePerKg + bonusAmount);
    }
    return weight * pricePerKg;
  }
}
