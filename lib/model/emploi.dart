class Schedule {
  final String id;
  final String className;
  final String level;
  final List<Session> sessions;

  Schedule({
    required this.id,
    required this.className,
    required this.level,
    required this.sessions,
  });

  // Convertir depuis JSON
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['_id']?.toString() ?? '',
      className: json['class_name']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      sessions: (json['sessions'] as List<dynamic>?)
              ?.map((e) => Session.fromJson(e))
              .toList() ??
          [],
    );
  }

  // Convertir vers JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'class_name': className,
      'level': level,
      'sessions': sessions.map((e) => e.toJson()).toList(),
    };
  }
}

class Session {
  final String day;
  final String time;
  final String teacher;
  final String subject;

  Session({
    required this.day,
    required this.time,
    required this.teacher,
    required this.subject,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      day: json['day']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      teacher: json['teacher']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'time': time,
      'teacher': teacher,
      'subject': subject,
    };
  }
}