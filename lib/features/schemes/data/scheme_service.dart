import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/config/app_config.dart';

class SchemeService {
  static String get baseUrl => AppConfig.baseUrl; 
  final _storage = const FlutterSecureStorage();

  // --- GET: Fetch Schemes ---
  Future<List<Map<String, dynamic>>> getActiveSchemes() async {
    // Since AppConfig.baseUrl already includes '/api/customer-app', 
    // we just append '/schemes' directly to it.
    final url = Uri.parse('$baseUrl/schemes');
    final token = await _storage.read(key: 'jwt_token');

    debugPrint('Fetch schemes request: $url');
    debugPrint('Scheme token exists: ${token != null && token.isNotEmpty}');
    final tokenPreview = (token != null && token.length >= 10) ? token.substring(0, 10) : token;
    debugPrint('Scheme token preview: ${tokenPreview ?? "null"}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // --- ADDED DEBUG PRINT TO CHECK THE RESPONSE STRUCTURE ---
        debugPrint('--- API RESPONSE BODY START ---');
        debugPrint(response.body);
        debugPrint('--- API RESPONSE BODY END ---');

        final dynamic data = jsonDecode(response.body);
        
        // Added a quick safety check in case the API wraps the list in a map, e.g., {"data": [...]}
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map<String, dynamic> && data.containsKey('data')) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          return [data as Map<String, dynamic>];
        }

      } else {
        debugPrint('Failed Response Body: ${response.body}');
        throw Exception('Failed to load schemes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error fetching schemes: $e');
    }
  }
}