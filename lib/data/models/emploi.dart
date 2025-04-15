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

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['_id'],
      className: json['className'],
      level: json['level'],
      sessions: List<Session>.from(
          json['sessions'].map((x) => Session.fromJson(x))),
    );
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
      day: json['day'],
      time: json['time'],
      teacher: json['teacher'],
      subject: json['subject'],
    );
  }
}