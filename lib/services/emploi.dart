import '../model/emploi.dart';
import 'api_service.dart';
import 'package:flutter/foundation.dart';

class ScheduleApiService {
  /// Récupère l'emploi du temps pour une classe spécifique
  Future<List<Schedule>> getScheduleForClass(String className) async {
    try {
      final response = await ApiService.get('/schedules/$className');
      
      if (kDebugMode) {
        print('┌───────────────────────────────────────────────────────');
        print('│ [GET Schedule for Class] $className');
        print('│ Data: ${response.data}');
        print('└───────────────────────────────────────────────────────');
      }
      
      // Convertir la réponse en liste de Schedule
      final List<dynamic> data = response.data;
      return data.map((json) => Schedule.fromJson(json)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('┌───────────────────────────────────────────────────────');
        print('│ [ERROR Schedule for Class] $className');
        print('│ Error: $e');
        print('└───────────────────────────────────────────────────────');
      }
      throw Exception('Failed to load schedule for class: $e');
    }
  }

  /// Récupère l'emploi du temps pour un enseignant spécifique
  Future<List<Schedule>> getScheduleForTeacher(String teacherName) async {
  try {
    final response = await ApiService.get('/schedules/teacher/$teacherName');
    
    if (kDebugMode) {
      print('┌───────────────────────────────────────────────────────');
      print('│ [GET Schedule for Teacher] $teacherName');
      print('│ Raw Data: ${response.data}');
      print('└───────────────────────────────────────────────────────');
    }
    
    // Convertir la réponse en liste de Schedule
    final List<dynamic> data = response.data;
    
    return data.map((item) {
      // Créer une session pour chaque élément
      final session = Session(
        day: item['day']?.toString() ?? '',
        time: item['time']?.toString() ?? '',
        teacher: item['teacher']?.toString() ?? '',
        subject: item['subject']?.toString() ?? '',
      );
      
      // Créer un Schedule avec cette session unique
      return Schedule(
        id: item['_id']?.toString() ?? '',
        className: item['className']?.toString() ?? '',
        level: item['level']?.toString() ?? '',
        sessions: [session], // Liste avec une seule session
      );
    }).toList();
  } catch (e) {
    if (kDebugMode) {
      print('┌───────────────────────────────────────────────────────');
      print('│ [ERROR Schedule for Teacher] $teacherName');
      print('│ Error: $e');
      print('└───────────────────────────────────────────────────────');
    }
    throw Exception('Failed to load teacher schedule: $e');
  }
}
}