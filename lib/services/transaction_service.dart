import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import '../config/api_config.dart';
import '../models/transaction.dart';
import '../services/auth_service.dart';

class TransactionService {
  final AuthService _authService = AuthService();

  /// Submit deposit request (Client)
  Future<Map<String, dynamic>> submitDeposit({
    required int wasteTypeId,
    required double estimatedWeight,
    File? photo,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token'};
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.transactionsEndpoint),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['waste_type_id'] = wasteTypeId.toString();
      request.fields['estimated_weight'] = estimatedWeight.toString();

      // Add location data if provided
      if (latitude != null) {
        request.fields['latitude'] = latitude.toString();
      }
      if (longitude != null) {
        request.fields['longitude'] = longitude.toString();
      }

      if (photo != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo',
            photo.path,
            contentType: http_parser.MediaType('image', 'jpeg'),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final Map<String, dynamic> data = json.decode(response.body);

      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Operation completed',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Get user's transactions (Client)
  Future<List<Transaction>> getUserTransactions() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse(ApiConfig.transactionsEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> transactionsJson = data['data'];
          return transactionsJson
              .map((json) => Transaction.fromJson(json))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  /// Get pending transactions (Admin)
  Future<List<Transaction>> getPendingTransactions() async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${ApiConfig.transactionsEndpoint}/pending'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> transactionsJson = data['data'];
          return transactionsJson
              .map((json) => Transaction.fromJson(json))
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('Error fetching pending transactions: $e');
      return [];
    }
  }

  /// Validate transaction (Admin)
  Future<Map<String, dynamic>> validateTransaction({
    required int transactionId,
    required String action, // 'approve' or 'reject'
    double? actualWeight,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token'};
      }

      final Map<String, dynamic> body = {'action': action};

      if (action == 'approve' && actualWeight != null) {
        body['actual_weight'] = actualWeight;
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.transactionsEndpoint}/$transactionId/validate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      final Map<String, dynamic> data = json.decode(response.body);

      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Operation completed',
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
