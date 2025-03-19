class Workshop {
  final String title;
  final String category; // Science, Math, etc.
  final String instructor;
  final String objective;
  final String exercise;
  final String time;
  // final int completedLessons;
  // final int totalLessons;
  // final String imageUrl;

  Workshop({
    required this.title,
    required this.instructor,
    // required this.completedLessons,
    // required this.totalLessons,
    // required this.imageUrl,
    required this.category,
    required this.objective,
    required this.exercise,
    required this.time,
  });
}
