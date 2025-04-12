import 'package:bloc_test/data/models/classes.dart';
import 'package:bloc_test/data/models/subject.dart';
import 'package:bloc_test/services/class_service.dart';
import 'package:bloc_test/services/subject_service.dart';
import 'package:bloc_test/services/workshop_service.dart';
import 'package:flutter/material.dart';
import 'package:bloc_test/data/models/cours.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {

  @override
  void initState() {
    super.initState();
    _loadWorkshops();
    getSubjects();
    getAllClasses();
  }

  List<Cours> coursList = [];

  String? errorMessage;
 Future<void> _loadWorkshops() async {
  try {
    final data = await WorkshopService().getAllWorkshops();
    debugPrint("Données brutes: ${data.toString()}"); // <-- Ajoutez cette ligne
    print("Nombre de workshops récupérés : ${data.length}");
    
    setState(() {
      coursList = data;
    });
  } catch (e) {
    debugPrint("Erreur lors du chargement des workshops: $e");
    setState(() {
      errorMessage = "Échec du chargement des ateliers";
    });
  }
}

  // methode pour recuperer les matiere de la bd
  String? selectedSubject;
  List<Subject> subjects = [];
  Future<void> getSubjects() async {
    final data = await SubjectService().getAllSubjects();
    print("Matières récupérées : ${data.length}");
    setState(() {
      subjects = data;
    });
  }
  // methode pour recuperer les classes de la bd

  String? selectedClass;
  List<ClassEntity> classesList = [];
  Future<void> getAllClasses() async {
    try {
      final data = await ClassService().getAllClasses();
      print("Données brutes reçues: ${data.toString()}");
      setState(() {
        classesList = data;
      });
    } catch (e) {
      print("Erreur lors de la récupération des classes: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Cours> filteredCours = coursList.where((cours) {
      final classeMatch =
          selectedClass == null || cours.classe == selectedClass;
      final matiereMatch =
          selectedSubject == null || cours.matiere == selectedSubject;
      return classeMatch && matiereMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Ateliers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () => _showFilterSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWorkshops,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredCours.length,
        itemBuilder: (context, index) {
          final cours = filteredCours[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.task, color: Colors.blue),
              title: Text(cours.titre),
              onTap: () => _showCoursDetails(context, cours),
            ),
          );
        },
      ),
    );
  }

  void _showCoursDetails(BuildContext context, Cours cours) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(cours.titre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date limite: ${cours.dateLimite}'),
            const SizedBox(height: 8),
            Text('Description: ${cours.description}'),
            const SizedBox(height: 8),
            Text('Matière: ${cours.matiere}'),
            const SizedBox(height: 8),
            Text('Classe: ${cours.classe}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtres',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Classe',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Table(
                    children: _buildClassFilterRows(),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Matière',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Table(
                        children: _buildMatiereFilterRows(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Boutons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedClass = null;
                            selectedSubject = null;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Réinitialiser'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {});
                          Navigator.pop(context);
                        },
                        child: const Text('Appliquer'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterItem(
      String title, String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () {
          onChanged(selectedValue == title ? null : title);
        },
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selectedValue == title ? Colors.blue : Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
                color: selectedValue == title
                    ? Colors.blue.withOpacity(0.2)
                    : Colors.transparent,
              ),
              child: selectedValue == title
                  ? const Icon(Icons.check, size: 16, color: Colors.blue)
                  : null,
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  // Nouvelle méthode pour construire les lignes de filtre des classes
  List<TableRow> _buildClassFilterRows() {
    List<TableRow> rows = [];
    List<Widget> currentRowChildren = [];

    for (var i = 0; i < classesList.length; i++) {
      final classe = classesList[i];
      currentRowChildren.add(
        _buildFilterItem(classe.name, selectedClass, (value) {
          setState(() => selectedClass = value);
        }),
      );

      // Crée une nouvelle ligne après chaque 2 éléments
      if (i % 2 == 1 || i == classesList.length - 1) {
        rows.add(TableRow(children: currentRowChildren));
        currentRowChildren = [];
      }
    }

    return rows;
  }

  List<TableRow> _buildMatiereFilterRows() {
    List<TableRow> rows = [];
    List<Widget> currentRowChildren = [];

    for (var i = 0; i < subjects.length; i++) {
      final subject = subjects[i];
      currentRowChildren.add(
        _buildFilterItem(subject.name, selectedSubject, (value) {
          setState(() => selectedSubject = value);
        }),
      );

      // Crée une nouvelle ligne après chaque 2 éléments
      if (i % 2 == 1 || i == subjects.length - 1) {
        rows.add(TableRow(children: currentRowChildren));
        currentRowChildren = [];
      }
    }

    return rows;
  }
}
