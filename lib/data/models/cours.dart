import 'dart:convert';

List<Cours> workshopListFromJson(String str) =>
    List<Cours>.from(json.decode(str).map((x) => Cours.fromJson(x)));

String workshopListToJson(List<Cours> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Cours {
  final String? id; 
  final String titre;
  final String dateLimite;
  final String description;
  final String matiere;
  final String classe;
  final String? fileUrl;

  Cours({
    this.id,
    required this.titre,
    required this.dateLimite,
    required this.description,
    required this.matiere,
    required this.classe,
    this.fileUrl,
  });

  factory Cours.fromJson(Map<String, dynamic> json) {
    return Cours(
      id: json['id']?.toString(), 
      titre: json['titre'] as String? ?? 'Sans titre', 
      dateLimite: json['dateLimite'] as String? ?? 'Non spécifiée',
      description: json['description'] as String? ?? 'Pas de description',
      matiere: json['matiere'] as String? ?? 'Matière non spécifiée',
      classe: json['classe'] as String? ?? 'Classe non spécifiée',
      fileUrl: json['fileUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'titre': titre,
      'dateLimite': dateLimite,
      'description': description,
      'matiere': matiere,
      'classe': classe,
      'fileUrl': fileUrl,
    };
  }
}
