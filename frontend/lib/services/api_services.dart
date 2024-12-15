import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://bubtcr.pythonanywhere.com/api';
  final String token;

  ApiService({required this.token});

  // Fetch Upcoming Exams
  Future<List<Map<String, dynamic>>> getUpcomingExams() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/upcoming-exams/'),
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print('Error fetching upcoming exams: $e');
      return [];
    }
  }

  // Fetch Announcements
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/announcements/'),
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print('Error fetching announcements: $e');
      return [];
    }
  }

  // Add Exam
  Future<bool> addExam({
    required String examName,
    required String courseName,
    required String courseCode,
    required DateTime date,
    required String topic,
    required String detail,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/upcoming-exams/'),
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'exam_name': examName,
          'course_name': courseName,
          'course_code': courseCode,
          'date':
              "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
          'topic': topic,
          'detail': detail,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error adding exam: $e');
      return false;
    }
  }

  // Fetch Exam Details
  Future<Map<String, dynamic>> getExamDetails(String examId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/upcoming-exams/update/$examId/'), // Correct endpoint
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to load exam details with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching exam details: $e');
      rethrow;
    }
  }

  // Update Exam
  Future<bool> updateExam({
    required String examId,
    required String examName,
    required String courseName,
    required String courseCode,
    required DateTime date,
    required String topic,
    required String detail,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/upcoming-exams/update/$examId/'),
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'exam_name': examName,
          'course_name': courseName,
          'course_code': courseCode,
          'date':
              "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
          'topic': topic,
          'detail': detail,
        }),
      );

      if (response.statusCode == 200) {
        print('Exam updated successfully.');
        return true;
      } else {
        print(
            'Failed to update exam. Status Code: ${response.statusCode}, Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating exam: $e');
      return false;
    }
  }

  // Delete Exam
  Future<bool> deleteExam(String examId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/upcoming-exams/delete/$examId/'),
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 204) {
        print('Exam deleted successfully.');
        return true;
      } else {
        print(
            'Failed to delete exam. Status Code: ${response.statusCode}, Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting exam: $e');
      return false;
    }
  }

// Logout User
  Future<bool> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout/'),
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('token'); // Remove token from storage
        print('Logout successful.');
        return true;
      } else {
        print('Failed to logout. Status Code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }
}
