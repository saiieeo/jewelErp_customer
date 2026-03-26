import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';

class DiscoveryService {
  static String get baseUrl => AppConfig.baseUrl;

  // --- GET: Fetch Live Catalog ---
  Future<List<Map<String, dynamic>>> getLiveCatalog(String storeId) async {
    final url = Uri.parse('$baseUrl/catalog/$storeId');
    final response = await ApiClient().get(url);

    if (response.statusCode == 200) {
      final List<dynamic> rawData = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(rawData);
    } else {
      throw Exception('Failed to load catalog for this boutique.');
    }
  }

  // --- GET: Fetch Live Rates (Fallback) ---
  Future<Map<String, String>> getLiveRates() async {
    final url = Uri.parse('$baseUrl/rates/live');
    try {
      final response = await ApiClient().get(url);
      if (response.statusCode == 200) {
        return Map<String, String>.from(jsonDecode(response.body));
      }
    } catch (e) {
      // Fallback if rates API is down
    }
    return {
      "24K": "₹ 7,450 / gm",
      "22K": "₹ 6,830 / gm",
      "18K": "₹ 5,587 / gm",
    };
  }

  // --- Add to Wishlist ---
  Future<void> addToWishlist(String jewelryItemId) async {
    final url = Uri.parse('$baseUrl/wishlist/$jewelryItemId');
    
    debugPrint('POST wishlist request: $url');
    final response = await ApiClient().post(url);
    
    debugPrint('POST wishlist response: ${response.statusCode}');
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to add item to wishlist');
    }
  }

  // --- Remove from Wishlist ---
  Future<void> removeFromWishlist(String jewelryItemId) async {
    final url = Uri.parse('$baseUrl/wishlist/$jewelryItemId');
    final response = await ApiClient().delete(url);
    
    debugPrint('DELETE wishlist response: ${response.statusCode}');
    
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to remove item from wishlist');
    }
  }

  // --- GET: Fetch Wishlist ---
  Future<List<Map<String, dynamic>>> getWishlist() async {
    final url = Uri.parse('$baseUrl/wishlist');
    
    debugPrint('GET wishlist request: $url');
    final response = await ApiClient().get(url);
    
    if (response.statusCode == 200) {
      final List<dynamic> rawData = jsonDecode(response.body);
      return rawData.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    } else {
      throw Exception('Failed to load wishlist from server.');
    }
  }

  // --- GET: Fetch Today's Live Rates ---
  Future<Map<String, dynamic>> getTodayRates() async {
    String ratesBaseUrl = baseUrl; 
    if (ratesBaseUrl.endsWith('/customer-app')) {
      ratesBaseUrl = ratesBaseUrl.replaceAll('/customer-app', '');
    }
    
    final url = Uri.parse('$ratesBaseUrl/rates');
    debugPrint('GET live rates request: $url');
    
    try {
      final response = await ApiClient().get(url);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load live rates: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Live rates fetch failed: $e');
      throw Exception('Network error fetching rates');
    }
  }

 Future<String?> uploadEnquiryImage(File imageFile) async {
    final url = Uri.parse('$baseUrl/images/upload');
    final token = await const FlutterSecureStorage().read(key: 'jwt_token');

    debugPrint('Upload token exists: ${token != null && token.isNotEmpty}');

    final extension = imageFile.path.split('.').last.toLowerCase();
    String mimeType = 'jpeg';
    if (extension == 'png') {
      mimeType = 'png';
    } else if (extension == 'gif') {
      mimeType = 'gif';
    } else if (extension == 'webp') {
      mimeType = 'webp';
    }

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer ${token ?? ''}' 
      ..files.add(await http.MultipartFile.fromPath(
        'file', 
        imageFile.path,
        contentType: MediaType('image', mimeType), 
      ));

    debugPrint('Uploading image request: $url (image/$mimeType)');
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    
    debugPrint('Uploading image response: ${response.statusCode}');

    if (response.statusCode == 200) {
      final body = jsonDecode(responseBody);
      return body['imageUrl'] as String;
    } else {
      throw Exception('Image upload failed: $responseBody');
    }
  }

  // --- POST: Submit Enquiry (Supports Both Products & Custom Designs) ---
 Future<void> submitEnquiry({
    int? jewelryItemId, 
    required String subject, 
    required String message,
    String? imageUrl,   
  }) async {
    final url = Uri.parse('$baseUrl/enquiry');
    
    final token = await const FlutterSecureStorage().read(key: 'jwt_token');
    
    final body = jsonEncode({
      if (jewelryItemId != null) ...{"jewelryItemId": jewelryItemId},
      "subject": subject,
      "message": message,
      if (imageUrl != null) ...{"imageUrl": imageUrl},
    });

    debugPrint('POST enquiry request: $url');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token ?? ''}',
      },
      body: body,
    );
    
    debugPrint('POST enquiry response: ${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to submit enquiry');
    }
  }
}