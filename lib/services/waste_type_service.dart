import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/waste_type.dart';
import '../services/auth_service.dart';

class WasteTypeService {
  final AuthService _authService = AuthService();

  /// Get all waste types
  Future<List<WasteType>> getWasteTypes() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse(ApiConfig.wasteTypesEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> wasteTypesJson = data['data'];
          return wasteTypesJson
              .map((json) => WasteType.fromJson(json))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('Error fetching waste types: $e');
      return [];
    }
  }

  /// Create waste type (Admin only)
  Future<Map<String, dynamic>> createWasteType({
    required String name,
    required double pricePerKg,
    required double bonusThreshold,
    required double bonusAmount,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token'};
      }

      final response = await http.post(
        Uri.parse(ApiConfig.wasteTypesEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'price_per_kg': pricePerKg,
          'bonus_threshold': bonusThreshold,
          'bonus_amount': bonusAmount,
        }),
      );

      final Map<String, dynamic> data = json.decode(response.body);

      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Operation completed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Update waste type (Admin only)
  Future<Map<String, dynamic>> updateWasteType({
    required int id,
    required String name,
    required double pricePerKg,
    required double bonusThreshold,
    required double bonusAmount,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token'};
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.wasteTypesEndpoint}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'price_per_kg': pricePerKg,
          'bonus_threshold': bonusThreshold,
          'bonus_amount': bonusAmount,
        }),
      );

      final Map<String, dynamic> data = json.decode(response.body);

      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Operation completed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Delete waste type (Admin only)
  Future<Map<String, dynamic>> deleteWasteType(int id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token'};
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.wasteTypesEndpoint}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> data = json.decode(response.body);

      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Operation completed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
