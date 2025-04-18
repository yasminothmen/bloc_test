class Course {
  final String id;
  final String imageUrl;
  final String rating;
  final bool isBookmarked;
  final String courseTitle;
  final String instructor;
  final String duration;
  final String sectionsLength;
  final List sectionLaps;
  final String quizesLength;
  final List quizLaps;
  final String bonusLength;
  final List bonusLaps;
  String description;

  Course({
    required this.id,
    required this.imageUrl,
    required this.rating,
    required this.isBookmarked,
    required this.courseTitle,
    required this.instructor,
    required this.duration,
    required this.sectionsLength,
    required this.sectionLaps,
    required this.quizesLength,
    required this.quizLaps,
    required this.bonusLength,
    required this.bonusLaps,
    this.description = _description,
  });
}

const _description =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo';
