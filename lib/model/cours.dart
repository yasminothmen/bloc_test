import 'package:flutter/material.dart';

class Cours {
  final String? id;
  final String titre;
  final String description;
  final String instructor;
  final String rating;
  bool bookmarked;
  final String matiere;
  final String classe;
  final String imagePath;
  final List<Lesson> lessons;
  final Exercice exercice;
  final String workshopDuration;
  Cours({
    required this.id,
    required this.rating,
    required this.bookmarked,
    required this.titre,
    required this.description,
    required this.instructor,
    required this.matiere,
    required this.classe,
    required this.imagePath,
    required this.lessons,
    required this.exercice,
    required this.workshopDuration,
  });

  factory Cours.fromJson(Map<String, dynamic> json) {
    // Fonction helper pour le parsing sécurisé
    String parseString(dynamic value) => (value?.toString() ?? '').trim();
    bool parseBool(dynamic value) => value is bool ? value : false;

    return Cours(
      id: parseString(json["_id"] ?? json["id"]),
      titre: parseString(json["titre"]),
      description: parseString(json["description"]),
      instructor: parseString(json["instructor"]),
      rating: parseString(json["rating"] ?? "4.0"), // Valeur par défaut
      bookmarked: parseBool(json["bookmarked"]),
      matiere: parseString(json["matiere"]),
      classe: parseString(json["classe"]),
      workshopDuration: parseString(json["workshopDuration"]),
      imagePath:
          parseString(json["imagePath"] ?? "assets/images/placeholder.jpg"),
      lessons: json["lessons"] is List
          ? List<Lesson>.from(
              (json["lessons"] as List).map((x) => Lesson.fromJson(x ?? {})))
          : <Lesson>[],
      exercice: Exercice.fromJson(json["exercice"] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) '_id': id,
        "titre": titre,
        "description": description,
        "instructor": instructor,
        "rating": rating,
        "workshopDuration": workshopDuration,
        "bookmarked": bookmarked,
        "matiere": matiere,
        "classe": classe,
        "imagePath": imagePath,
        "lessons": lessons.map((x) => x.toJson()).toList(),
        "exercice": exercice.toJson(),
      };

       // Méthode pour basculer l'état bookmark
  void toggleBookmark() {
    bookmarked = !bookmarked;
  }
}

class Exercice {
  final String titre;
  final String exerciceUrl;

  Exercice({
    required this.titre,
    required this.exerciceUrl,
  });

  factory Exercice.fromJson(Map<String, dynamic> json) {
    String parseString(dynamic value) => (value?.toString() ?? '').trim();

    return Exercice(
      titre: parseString(json["titre"]),
      exerciceUrl: parseString(json["exerciceUrl"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "titre": titre,
        "exerciceUrl": exerciceUrl,
      };
}

class Lesson {
  final String id;
  final String titre;
  final String lessonUrl;
  final String lessonDuration;

  Lesson({
    required this.id,  // Ajout de l'id comme paramètre requis
    required this.titre,
    required this.lessonUrl,
    required this.lessonDuration,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    // Fonction helper pour le parsing sécurisé
    String cleanString(dynamic value) {
      if (value == null) {
        debugPrint('ATTENTION: Valeur nulle détectée');
        return '';
      }
      return value.toString().trim();
    }

    // Debug: Affiche les données brutes reçues
    debugPrint('Données lesson reçues: ${json.toString()}');

    final url = cleanString(json["lessonUrl"]);
    if (url.isEmpty) {
      debugPrint('ERREUR: lessonUrl est vide dans les données: $json');
      throw FormatException('URL de la leçon vide ou manquante');
    }

    return Lesson(
      id: cleanString(json["_id"] ?? json["id"] ?? ''),  // Extraction de l'ID
      titre: cleanString(json["titre"]),
      lessonUrl: url,
      lessonDuration: cleanString(json["lessonDuration"]),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) '_id': id,  // On inclut l'ID seulement s'il n'est pas vide
        "titre": titre,
        "lessonUrl": lessonUrl,
        "lessonDuration": lessonDuration,
      };
}
