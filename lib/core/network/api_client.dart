import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient extends http.BaseClient {
  // The actual HTTP client running under the hood
  final http.Client _inner = http.Client();
  final _storage = const FlutterSecureStorage();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // 1. Grab the securely stored JWT token
    final token = await _storage.read(key: 'jwt_token');

    // 2. If the user is logged in, attach the token to the Authorization header
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // 3. Set standard JSON headers for the Java backend
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'application/json';

    // 4. Send the request on its way to AWS
    return _inner.send(request);
  }
}