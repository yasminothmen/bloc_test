class AppUser {
  final String id;
  final String? profileImageId;
  final String firstname;
  final String lastname;
  final String role; // 'teacher' ou 'student'
  final String email;
  final String about;
  final bool isDarkMode;

  const AppUser({
    required this.id,
    this.profileImageId,
    required this.firstname,
    required this.lastname,
    required this.role,
    required this.email,
    required this.about,
    required this.isDarkMode,
  });

  AppUser copy({
    String? id,
    String? profileImageId,
    String? firstname,
    String? lastname,
    String? role,
    String? email,
    String? about,
    bool? isDarkMode,
  }) =>
      AppUser(
        id: id ?? this.id,
        profileImageId: profileImageId ?? this.profileImageId,
        firstname: firstname ?? this.firstname,
        lastname: lastname ?? this.lastname,
        role: role ?? this.role,
        email: email ?? this.email,
        about: about ?? this.about,
        isDarkMode: isDarkMode ?? this.isDarkMode,
      );

  static AppUser fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'],
        profileImageId: json['profileImageId'],
        firstname: json['firstname'],
        lastname: json['lastname'],
        role: json['role'],
        email: json['email'],
        about: json['about'],
        isDarkMode: json['isDarkMode'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'profileImageId': profileImageId,
        'firstname': firstname,
        'lastname': lastname,
        'role': role,
        'email': email,
        'about': about,
        'isDarkMode': isDarkMode,
      };
}
