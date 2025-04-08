// To parse this JSON data, do
//
import 'dart:convert';

List<Subject> subjectFromJson(String str) =>
    List<Subject>.from(json.decode(str).map((x) => Subject.fromJson(x)));

String subjectToJson(List<Subject> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Subject {
  String id;
  String name;
  String type;
  String nombreHeures;
  List<String> level;

  Subject({
    required this.id,
    required this.name,
    required this.type,
    required this.nombreHeures,
    required this.level,
  });

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        nombreHeures: json["nombreHeures"],
        level: List<String>.from(json["level"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "nombreHeures": nombreHeures,
        "level": List<dynamic>.from(level.map((x) => x)),
      };
}

//
