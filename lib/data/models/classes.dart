import 'dart:convert';

List<ClassEntity> classListFromJson(String str) => 
    List<ClassEntity>.from(json.decode(str).map((x) => ClassEntity.fromJson(x)));

String classListToJson(List<ClassEntity> data) => 
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClassEntity {
  final String id;
  final String name;
  final String level;
  final int studentsCount;
  final List<Student> students;

  ClassEntity({
    required this.id,
    required this.name,
    required this.level,
    required this.studentsCount,
    required this.students,
  });

  factory ClassEntity.fromJson(Map<String, dynamic> json) => ClassEntity(
        id: json["id"]?.toString() ?? '', // Conversion et gestion de null
        name: json["name"]?.toString() ?? '',
        level: json["level"]?.toString() ?? '',
        studentsCount: json["studentsCount"] is int? 
            ? (json["studentsCount"] ?? 0)
            : int.tryParse(json["studentsCount"]?.toString() ?? '0') ?? 0,
        students: (json["students"] is List)
            ? List<Student>.from(
                json["students"].map((x) => Student.fromJson(x ?? {})))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "level": level,
        "studentsCount": studentsCount,
        "students": List<dynamic>.from(students.map((x) => x.toJson())),
      };
}

class Student {
  final String id;
  final String? firstname;
  final String? lastname;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String? username;
  final String? role;

  Student({
    required this.id,
    this.firstname,
    this.lastname,
    required this.email,
    this.password,
    this.confirmPassword,
    this.username,
    this.role,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json["id"]?.toString() ?? '',
        firstname: json["firstname"]?.toString(),
        lastname: json["lastname"]?.toString(),
        email: json["email"]?.toString() ?? '',
        password: json["password"]?.toString(),
        confirmPassword: json["confirmPassword"]?.toString(),
        username: json["username"]?.toString(),
        role: json["role"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstname": firstname,
        "lastname": lastname,
        "email": email,
        "password": password,
        "confirmPassword": confirmPassword,
        "username": username,
        "role": role,
      };
}