class AppUser {
  final String id;
  final String imagePath;
  final String name;
  final String role; // 'teacher' ou 'student'
  final String email;
  final String about;
  final bool isDarkMode;

  const AppUser({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.role,
    required this.email,
    required this.about,
    required this.isDarkMode,
  });

  AppUser copy({
    String? id,
    String? imagePath,
    String? name,
    String? role,
    String? email,
    String? about,
    bool? isDarkMode,
  }) =>
      AppUser(
        id: id ?? this.id,
        imagePath: imagePath ?? this.imagePath,
        name: name ?? this.name,
        role: role ?? this.role,
        email: email ?? this.email,
        about: about ?? this.about,
        isDarkMode: isDarkMode ?? this.isDarkMode,
      );

  static AppUser fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        imagePath: json['imagePath'],
        name: json['name'],
        role: json['role'],
        email: json['email'],
        about: json['about'],
        isDarkMode: json['isDarkMode'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'name': name,
        'role': role,
        'email': email,
        'about': about,
        'isDarkMode': isDarkMode,
      };
}
