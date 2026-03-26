import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/config/app_config.dart';

class SchemeService {
  static String get baseUrl => AppConfig.baseUrl; 
  final _storage = const FlutterSecureStorage();

  // --- GET: Fetch All Active Schemes ---
  Future<List<Map<String, dynamic>>> getActiveSchemes() async {
    String schemesBaseUrl = baseUrl; 
    if (schemesBaseUrl.endsWith('/customer-app')) {
      schemesBaseUrl = schemesBaseUrl.replaceAll('/customer-app', '');
    }
    
    final url = Uri.parse('$schemesBaseUrl/schemes');
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
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load schemes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error fetching schemes: $e');
    }
  }
}