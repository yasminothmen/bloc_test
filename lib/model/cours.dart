import 'dart:convert';

class Cours {
  final String? id;
  final String titre;
  final String description;
  final String matiere;
  final String classe;
  final String imagePath;
  final List<Lesson> lessons;
  final Exercice exercice;

  Cours({
    this.id,
    required this.titre,
    required this.description,
    required this.matiere,
    required this.classe,
    required this.imagePath,
    required this.lessons,
    required this.exercice,
  });

  factory Cours.fromJson(Map<String, dynamic> json) => Cours(
        id: json["_id"]?.toString() ?? json["id"]?.toString(),
        titre: json["titre"] ?? '',
        description: json["description"] ?? '',
        matiere: json["matiere"] ?? '',
        classe: json["classe"] ?? '',
        imagePath: json["imagePath"] ?? 'placeholder.jpg',
        lessons: List<Lesson>.from(
            (json["lessons"] ?? []).map((x) => Lesson.fromJson(x))),
        exercice: Exercice.fromJson(json["exercice"] ?? {}),
      );

   Map<String, dynamic> toJson() => {
        if (id != null) '_id': id, // Notez le '_id' au lieu de 'id'
        "titre": titre,
        "description": description,
        "matiere": matiere,
        "classe": classe,
        "imagePath": imagePath,
        "lessons": lessons.map((x) => x.toJson()).toList(),
        "exercice": exercice.toJson(),
      };
}

class Exercice {
  final String titre;
  final String exerciceUrl;

  Exercice({
    required this.titre,
    required this.exerciceUrl,
  });

  factory Exercice.fromJson(Map<String, dynamic> json) => Exercice(
        titre: json["titre"] ?? '',
        exerciceUrl: json["exerciceUrl"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "titre": titre,
        "exerciceUrl": exerciceUrl,
      };
}

class Lesson {
  final String titre;
  final String lessonUrl;

  Lesson({
    required this.titre,
    required this.lessonUrl,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        titre: json["titre"] ?? '',
        lessonUrl: json["lessonUrl"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "titre": titre,
        "lessonUrl": lessonUrl,
      };
}