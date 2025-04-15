import 'package:bloc_test/data/models/emploi.dart';
import 'package:bloc_test/services/emploi.dart';
import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ScheduleApiService _apiService = ScheduleApiService();
  List<Schedule> _classSchedules = [];
  List<Schedule> _teacherSchedules = [];
  bool _isLoading = false;

  // Pour la classe
  Future<void> _loadClassSchedule(String className) async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getScheduleForClass(className);
      setState(() {
        _classSchedules = data.map((json) => Schedule.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Pour l'enseignant
  Future<void> _loadTeacherSchedule(String teacherName) async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getScheduleForTeacher(teacherName);
      setState(() {
        _teacherSchedules = data.map((json) => Schedule.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Schedules')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                ElevatedButton(
                  onPressed: () => _loadClassSchedule('Classe A'),
                  child: Text('Load Class Schedule'),
                ),
                ElevatedButton(
                  onPressed: () => _loadTeacherSchedule('M. Dupont'),
                  child: Text('Load Teacher Schedule'),
                ),
                // Afficher les emplois du temps
                Expanded(
                  child: ListView.builder(
                    itemCount: _classSchedules.length + _teacherSchedules.length,
                    itemBuilder: (context, index) {
                      if (index < _classSchedules.length) {
                        return _buildScheduleCard(_classSchedules[index]);
                      } else {
                        final teacherIndex = index - _classSchedules.length;
                        return _buildScheduleCard(_teacherSchedules[teacherIndex]);
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildScheduleCard(Schedule schedule) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Class: ${schedule.className}', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Level: ${schedule.level}'),
            ...schedule.sessions.map((session) => ListTile(
                  title: Text(session.subject),
                  subtitle: Text('${session.day} ${session.time} - ${session.teacher}'),
                )),
          ],
        ),
      ),
    );
  }
}