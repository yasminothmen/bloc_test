import 'dart:convert';

import 'package:flutter/foundation.dart';

List<ClassEntity> classListFromJson(String str) => List<ClassEntity>.from(
    json.decode(str).map((x) => ClassEntity.fromJson(x)));

String classListToJson(List<ClassEntity> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClassEntity {
  final String id;
  final String name;
  final String level;
  final int studentsCount;

  ClassEntity({
    required this.id,
    required this.name,
    required this.level,
    required this.studentsCount,
  });

  factory ClassEntity.fromJson(Map<String, dynamic> json) {
    
    if (kDebugMode) {
      print('JSON reçu pour ClassEntity: $json');
    }

    return ClassEntity(
      id: json["id"]?.toString() ?? '0000',
      name: json["name"]?.toString() ?? 'Classe sans nom',
      level: json["level"]?.toString() ?? 'Niveau non spécifié',
      studentsCount: _safeParseInt(json["studentsCount"]),
    );
  }

  static int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "level": level,
        "studentsCount": studentsCount,
      };
}
