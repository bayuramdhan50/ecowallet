class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final double balance;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.balance,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'client',
      balance: _parseDouble(json['balance']),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  // Helper to safely parse balance (can be String or num from MySQL)
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
      'email': email,
      'role': role,
      'balance': balance,
      'is_active': isActive ? 1 : 0,
    };
  }
}
