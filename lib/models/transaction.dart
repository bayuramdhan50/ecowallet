class Transaction {
  final int id;
  final int userId;
  final int wasteTypeId;
  final String? wasteTypeName;
  final double estimatedWeight;
  final double? actualWeight;
  final String? photoUrl;
  final double totalEarning;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final DateTime? updatedAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.wasteTypeId,
    this.wasteTypeName,
    required this.estimatedWeight,
    this.actualWeight,
    this.photoUrl,
    required this.totalEarning,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      wasteTypeId: json['waste_type_id'] as int,
      wasteTypeName: json['waste_type_name'] as String?,
      estimatedWeight: _parseDouble(json['estimated_weight']),
      actualWeight: json['actual_weight'] != null
          ? _parseDouble(json['actual_weight'])
          : null,
      photoUrl: json['photo_url'] as String?,
      totalEarning: _parseDouble(json['total_earning']),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
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
      'user_id': userId,
      'waste_type_id': wasteTypeId,
      'waste_type_name': wasteTypeName,
      'estimated_weight': estimatedWeight,
      'actual_weight': actualWeight,
      'photo_url': photoUrl,
      'total_earning': totalEarning,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
