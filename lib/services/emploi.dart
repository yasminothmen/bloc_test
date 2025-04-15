import 'dart:convert';
import 'package:http/http.dart' as http;

class ScheduleApiService {
  static const String _baseUrl = 'http://192.168.131.117:8080/schedules'; // Remplacez par votre URL

  Future<List<dynamic>> getScheduleForClass(String className) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$className'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load schedule for class');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<dynamic>> getScheduleForTeacher(String teacherName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/teacher/$teacherName'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load teacher schedule');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}