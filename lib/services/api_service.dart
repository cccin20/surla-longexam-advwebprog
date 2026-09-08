import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class ApiException implements Exception {
  final String message;
  final int status;
  ApiException(this.message, [this.status = 0]);
  @override
  String toString() => message;
}

class ApiService {
  final http.Client client;
  ApiService({http.Client? client}) : client = client ?? http.Client();
  Future<Map<String, dynamic>> request(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final uri = Uri.parse('$host$path');
    try {
      final response =
          await (body == null
                  ? client.get(uri, headers: headers)
                  : client.post(uri, headers: headers, body: jsonEncode(body)))
              .timeout(const Duration(seconds: 20));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          data['message'] ?? 'Request failed',
          response.statusCode,
        );
      }
      return data;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Unable to connect. Check your connection and try again.',
      );
    }
  }
}
