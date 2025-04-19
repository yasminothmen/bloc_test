class AppUser {
  final String id;
  final String imagePath;
  final String firstname;
  final String role; // 'teacher' ou 'student'
  final String email;
  final String about;
  final bool isDarkMode;

  const AppUser({
    required this.id,
    required this.imagePath,
    required this.firstname,
    required this.role,
    required this.email,
    required this.about,
    required this.isDarkMode,
  });

  AppUser copy({
    String? id,
    String? imagePath,
    String? firstname,
    String? role,
    String? email,
    String? about,
    bool? isDarkMode,
  }) =>
      AppUser(
        id: id ?? this.id,
        imagePath: imagePath ?? this.imagePath,
        firstname: firstname ?? this.firstname,
        role: role ?? this.role,
        email: email ?? this.email,
        about: about ?? this.about,
        isDarkMode: isDarkMode ?? this.isDarkMode,
      );

  static AppUser fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        imagePath: json['imagePath'],
        firstname: json['firstname'],
        role: json['role'],
        email: json['email'],
        about: json['about'],
        isDarkMode: json['isDarkMode'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'name': firstname,
        'role': role,
        'email': email,
        'about': about,
        'isDarkMode': isDarkMode,
      };
}
