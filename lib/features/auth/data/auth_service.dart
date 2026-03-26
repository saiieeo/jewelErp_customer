import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/config/app_config.dart';

class AuthService {
  static String get baseUrl => AppConfig.baseUrl;
  final _storage = const FlutterSecureStorage();

  // --- NEW: THE ERROR PARSER HELPER ---
  // Extracts the clean "message" string from the backend's JSON error response
  String _parseApiError(String responseBody, String defaultMessage) {
    try {
      final Map<String, dynamic> errorData = jsonDecode(responseBody);
      
      if (errorData.containsKey('message') && errorData['message'] != null) {
        return errorData['message'].toString();
      }
      return defaultMessage;
    } catch (_) {
      // Failsafe in case AWS sends an HTML page instead of JSON
      return defaultMessage;
    }
  }

  // --- FETCH STORES 🌐 ---
  Future<List<Map<String, dynamic>>> getStores() async {
    final url = Uri.parse('$baseUrl/stores');
    http.Response response;

    try {
      response = await http.get(url);
    } catch (e) {
      // Only triggers if there is no internet or the AWS server is completely offline
      throw Exception('Network error: Could not connect to AWS.');
    }

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      final cleanError = _parseApiError(response.body, 'Failed to load boutiques from server.');
      throw Exception(cleanError);
    }
  }

  // --- SIGNUP API 🌐 ---
  Future<void> registerCustomer({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required int storeId,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    http.Response response;

    try {
      response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "firstName": firstName,
          "lastName": lastName,
          "phone": phone,
          "email": email,
          "password": password,
          "storeId": storeId,
        }),
      );
    } catch (e) {
      throw Exception('Network error: Could not connect to AWS.');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return; // Success!
    } else {
      // 🚨 Passes the specific AWS error to the UI (e.g., "Phone number already exists")
      final cleanError = _parseApiError(response.body, 'Registration failed. Please try again.');
      throw Exception(cleanError);
    }
  }
  
  // --- LOGIN API 🌐 ---
  Future<void> loginCustomer(String phone, String password, int storeId) async {
    final url = Uri.parse('$baseUrl/login');
    http.Response response;

    try {
      response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "phone": phone,
          "password": password,
          "storeId": storeId, 
        }),
      );
    } catch (e) {
      throw Exception('Network error: Could not connect to AWS.');
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // 1. Securely save the tokens
      await _storage.write(key: 'jwt_token', value: data['token']);
      
      // Safety check for refreshToken (some backends don't send this initially)
      if (data.containsKey('refreshToken') && data['refreshToken'] != null) {
        await _storage.write(key: 'refresh_token', value: data['refreshToken']);
      }
      
      // 2. Save user details for the Profile Screen
      await _storage.write(key: 'customer_id', value: data['customerId'].toString());
      await _storage.write(key: 'customer_name', value: data['name']);
      await _storage.write(key: 'customer_phone', value: data['phone']);
      await _storage.write(key: 'customer_email', value: data['email']);
      await _storage.write(key: 'store_id', value: data['storeId'].toString());
      await _storage.write(key: 'store_name', value: data['storeName']);
      
    } else {
      // 🚨 Passes the specific AWS error to the UI (e.g., "Invalid password")
      final cleanError = _parseApiError(response.body, 'Invalid Phone Number or Password.');
      throw Exception(cleanError);
    }
  }

  // --- AUTH CHECK ---
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt_token'); 
    return token != null && token.isNotEmpty;
  }

  // --- LOGOUT / CLEAR SECURE STORAGE 🗑️ ---
  Future<void> logoutCustomer() async {
    await _storage.deleteAll(); 
  }
}