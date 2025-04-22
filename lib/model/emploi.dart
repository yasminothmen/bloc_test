class EmploiDuTemps {
  final String id;
  final String classeId;
  final String titre;
  final String fileUrl;
  final Map<String, List<Cours>> jours;

  EmploiDuTemps({
    required this.id,
    required this.classeId,
    required this.titre,
    required this.fileUrl,
    required this.jours,
  });
}

class Cours {
  final String heure;
  final String matiere;
  final String enseignant;

  Cours({
    required this.heure,
    required this.matiere,
    required this.enseignant,
  });
}
