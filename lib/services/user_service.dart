import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class UserService {
  final AuthService _authService = AuthService();

  /// Get pending users (Admin only)
  Future<List<User>> getPendingUsers() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${ApiConfig.usersEndpoint}/pending'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> usersJson = data['data'];
          return usersJson.map((json) => User.fromJson(json)).toList();
        }
      }

      return [];
    } catch (e) {
      print('Error fetching pending users: $e');
      return [];
    }
  }

  /// Approve user (Admin only)
  Future<Map<String, dynamic>> approveUser(int userId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token'};
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.usersEndpoint}/$userId/approve'),
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

  /// Reject user (Admin only)
  Future<Map<String, dynamic>> rejectUser(int userId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token'};
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.usersEndpoint}/$userId/reject'),
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
