import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';

class ProfileService {
  static String get baseUrl => AppConfig.baseUrl;

  // --- GET: Fetch Customer Profile ---
  Future<Map<String, dynamic>> getProfile() async {
    final url = Uri.parse('$baseUrl/profile');
    
    debugPrint('GET profile request: $url');
    final response = await ApiClient().get(url);
    
    debugPrint('GET profile response: ${response.statusCode}');

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load profile details');
    }
  }

 // --- GET: Fetch My Enquiries History ---
  Future<List<Map<String, dynamic>>> getMyEnquiries() async {
    final url = Uri.parse('$baseUrl/enquiries'); 
    
    debugPrint('GET enquiries request: $url');
    final response = await ApiClient().get(url);
    
    debugPrint('GET enquiries response: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> rawData = jsonDecode(response.body);
      return rawData.map((item) => Map<String, dynamic>.from(item)).toList();
    } else {
      throw Exception('Failed to load enquiry history');
    }
  }
}