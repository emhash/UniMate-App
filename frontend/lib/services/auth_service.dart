import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';

class AuthService {
  static const String baseUrl = 'https://bubtcr.pythonanywhere.com/api';

  /// Logs in the user
  Future<Map<String, dynamic>> login(String email, String password) async {
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

      // Handle different cases based on the 'case' field
      if (data['case'] == 1 && data['status'] == true) {
        // Successful login and approved account
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('user', jsonEncode(data['user']));

        return {
          'status': true,
          'case': data['case'],
          'token': data['token'],
          'user': data['user'],
          'message': data['message']
        };
      } else if (data['case'] == 3 && data['status'] == false) {
        // Incomplete registration
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        return {
          'status': false,
          'case': data['case'],
          'token': data['token'],
          'message': data['message']
        };
      } else if (data['case'] == 2 && data['status'] == false) {
        // Account pending approval
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        return {
          'status': false,
          'case': data['case'],
          'token': data['token'],
          'message': data['message']
        };
      } else if ([4, 5].contains(data['case']) && data['status'] == false) {
        // Other cases requiring registration completion
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        return {
          'status': false,
          'case': data['case'],
          'token': data['token'],
          'message': data['message']
        };
      } else if (data['case'] == 0 && data['status'] == false) {
        // Validation errors
        return {
          'status': false,
          'case': data['case'],
          'message': data['message'],
        };
      } else if (data['case'] == 6 && data['status'] == false) {
        // Unauthorized role or invalid credentials
        return {
          'status': false,
          'case': data['case'],
          'message': data['message'],
        };
      } else {
        // Handle unexpected cases
        return {
          'status': false,
          'case': -1,
          'message': 'An unexpected error occurred.',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'case': -1,
        'message': 'An error occurred: ${e.toString()}'
      };
    }
  }

  /// Registers a new user
  Future<Map<String, dynamic>> register({
    required String role,
    required String email,
    required String password1,
    required String password2,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'role': role,
          'email': email,
          'password1': password1,
          'password2': password2,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || data['status'] == true) {
        return {'status': true, 'message': 'User registered successfully!'};
      } else {
        // If errors are present, concatenate them into a single string
        String errorMessage = data['errors'] != null
            ? data['errors'].values.map((e) => e.join(', ')).join('\n')
            : 'Registration failed. Please try again.';

        return {'status': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'status': false, 'message': 'An error occurred: $e'};
    }
  }

  /// Logs out the user by clearing stored data
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Checks if the user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  /// Fetches the stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Fetches user profile data
  Future<ApiResponse> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        return ApiResponse(
          status: false,
          message: 'Unauthorized: No token found.',
        );
      }

      final response = await http.get(
        Uri.parse('$baseUrl/profile/'),
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      return ApiResponse.fromJson(data);
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'An error occurred while fetching profile: ${e.toString()}',
      );
    }
  }
}
