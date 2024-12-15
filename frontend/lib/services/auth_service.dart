import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Fix import statement for shared_preferences
import '../models/api_response.dart';

class AuthService {
  static const String baseUrl = 'https://bubtcr.pythonanywhere.com/api';

  Future<ApiResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      final apiResponse = ApiResponse.fromJson(data);

      if (apiResponse.status && apiResponse.token != null) {
        // Store token and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', apiResponse.token!);
        await prefs.setString('user', jsonEncode(data['user']));
      }

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred: ${e.toString()}',
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }
}
