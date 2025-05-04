class AppUser {
  final String? id;
  final String? firstname;
  final String? lastname;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String? username;
  final String? role;
  final String? profileImageId;
  final List<String>? matieresEnseignees;
  final String? about;
  final bool? isDarkMode;

  const AppUser({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.role,
    this.password,
    this.confirmPassword,
    this.username,
    this.profileImageId,
    this.matieresEnseignees,
    this.about,
    this.isDarkMode,
  });

  AppUser copyWith({
    String? id,
    String? firstname,
    String? lastname,
    String? email,
    String? role,
    String? password,
    String? confirmPassword,
    String? username,
    String? profileImageId,
    List<String>? matieresEnseignees,
    String? about,
    bool? isDarkMode,
  }) =>
      AppUser(
        id: id ?? this.id,
        firstname: firstname ?? this.firstname,
        lastname: lastname ?? this.lastname,
        email: email ?? this.email,
        role: role ?? this.role,
        password: password ?? this.password,
        confirmPassword: confirmPassword ?? this.confirmPassword,
        username: username ?? this.username,
        profileImageId: profileImageId ?? this.profileImageId,
        matieresEnseignees: matieresEnseignees ?? this.matieresEnseignees,
        about: about ?? this.about,
        isDarkMode: isDarkMode ?? this.isDarkMode,
      );

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id']?.toString(),
        firstname: json['firstname']?.toString(),
        lastname: json['lastname']?.toString(),
        email: json['email'],
        role: json['role']?.toString(),
        password: json['password']?.toString(),
        confirmPassword: json['confirmPassword']?.toString(),
        username: json['username']?.toString(),
        profileImageId: json['profileImageId']?.toString(),
        matieresEnseignees: json['matieresEnseignees'] != null
            ? List<String>.from(
                json['matieresEnseignees'].map((x) => x.toString()))
            : null,
        about: json['about']?.toString(),
        isDarkMode: json['isDarkMode'] as bool?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'username': username,
        'role': role,
        'profileImageId': profileImageId,
        'matieresEnseignees': matieresEnseignees,
        'about': about,
        'isDarkMode': isDarkMode,
      };
}
