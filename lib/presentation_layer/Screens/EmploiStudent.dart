import '../../model/emploi.dart';
import '../../services/emploi.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Emploistudent extends StatefulWidget {
  const Emploistudent({super.key});

  @override
  _EmploistudentState createState() => _EmploistudentState();
}

class _EmploistudentState extends State<Emploistudent> {
  List<String> jours = [
    "Lundi",
    "Mardi",
    "Mercredi",
    "Jeudi",
    "Vendredi",
    "Samedi"
  ];
  List<String> heures = [];
  Map<String, List<Cours>> emploiDuTemps = {};
  String classeSelectionnee = '';
  bool chargement = false;
  String messageErreur = '';
  bool classeTrouvee = false;
  Map<String, Color> couleursMatiere = {};
  final ScheduleApiService _scheduleApiService = ScheduleApiService();
  final List<String> timeOptions = [
    '8am-10am',
    '10am-12pm',
    '1pm-3pm',
    '3pm-5pm'
  ];

  final List<Color> couleursPredefinies = [
    Color(0xFFFF5733),
    Color(0xFF33FF57),
    Color(0xFF3357FF),
    Color(0xFFF2C300),
    Color(0xFFFF8C00),
    Color(0xFF8A2BE2),
    Color(0xFFFF1493),
    Color(0xFF20B2AA),
    Color(0xFFFFD700),
    Color(0xFFADFF2F),
    Color(0xFFF08080),
    Color(0xFFC71585),
    Color(0xFF4682B4),
    Color(0xFF7FFF00),
    Color(0xFFD2691E)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
        ),
        title: const Text(
          "Emploi du Temps",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Sélectionnez une classe',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                onChanged: (value) {
                  setState(() {
                    classeSelectionnee = value;
                  });
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: chargerEmploiDuTemps,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Charger'),
              ),
              SizedBox(height: 16),
              if (chargement) Center(child: CircularProgressIndicator()),
              if (messageErreur.isNotEmpty)
                Text(
                  messageErreur,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              if (heures.isNotEmpty && classeTrouvee) ...[
                SizedBox(height: 24),
                Center(
                  child: Text(
                    'Emploi du temps de la classe : $classeSelectionnee',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    dataRowHeight:
                        80.0, 
                    headingRowHeight:
                        50.0,
                    columns: [
                      DataColumn(label: Text('Heure')),
                      ...jours
                          .map((jour) => DataColumn(label: Text(jour)))
                          .toList(),
                    ],
                    rows: heures.map((heure) {
                      return DataRow(
                        cells: [
                          DataCell(Text(heure)),
                          ...jours.map((jour) {
                            final coursList = emploiDuTemps[jour]
                                ?.where((c) => c.time == heure)
                                .toList();
                            if (coursList != null && coursList.isNotEmpty) {
                              final cours = coursList.first;
                              return DataCell(
                                Container(
                                  decoration: BoxDecoration(
                                    color: couleursMatiere[cours.matiere] ??
                                        Colors.transparent,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: EdgeInsets.all(8),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(cours.matiere,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(cours.enseignant,
                                          style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return DataCell(Text('-'));
                            }
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: exporterPDF,
                    icon: Icon(Icons.picture_as_pdf),
                    label: Text('Exporter en PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> chargerEmploiDuTemps() async {
    if (classeSelectionnee.trim().isEmpty) {
      setState(() {
        messageErreur = 'Veuillez entrer une classe valide.';
        classeTrouvee = false;
      });
      return;
    }

    setState(() {
      chargement = true;
      messageErreur = '';
      heures = [];
      emploiDuTemps = {};
    });

    try {
      final List<Schedule> schedules =
          await _scheduleApiService.getScheduleForClass(classeSelectionnee);

      
      final Map<String, List<Cours>> tempEmploiDuTemps = {};
      final Set<String> heuresSet = {};

      for (var schedule in schedules) {
        for (var session in schedule.sessions) {
          if (!tempEmploiDuTemps.containsKey(session.day)) {
            tempEmploiDuTemps[session.day] = [];
          }

          tempEmploiDuTemps[session.day]!.add(Cours(
            time: session.time,
            matiere: session.subject,
            enseignant: session.teacher,
          ));

          heuresSet.add(session.time);
          attribuerCouleurMatiere(session.subject);
        }
      }

      
      setState(() {
        emploiDuTemps = tempEmploiDuTemps;
        heures = heuresSet.toList()..sort((a, b) => comparerHeures(a, b));
        classeTrouvee = true;
        chargement = false;
      });
    } catch (e) {
      setState(() {
        messageErreur =
            'Erreur lors du chargement de l\'emploi du temps: ${e.toString()}';
        chargement = false;
        classeTrouvee = false;
      });
    }
  }

  int comparerHeures(String a, String b) {
    
    try {
      int h1 = int.parse(a.split('am').first.split('pm').first);
      int h2 = int.parse(b.split('am').first.split('pm').first);

     
      if (a.contains('pm') && !a.startsWith('12')) h1 += 12;
      if (b.contains('pm') && !b.startsWith('12')) h2 += 12;

      return h1.compareTo(h2);
    } catch (e) {
      return a.compareTo(b);
    }
  }

  void attribuerCouleurMatiere(String matiere) {
    if (!couleursMatiere.containsKey(matiere)) {
      couleursMatiere[matiere] = obtenirCouleurUnique(matiere);
    }
  }

  Color obtenirCouleurUnique(String matiere) {
    int hash = matiere.hashCode;
    return couleursPredefinies[hash.abs() % couleursPredefinies.length];
  }

  Future<void> exporterPDF() async {
    if (!classeTrouvee || classeSelectionnee.isEmpty) return;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Emploi du temps de la classe : $classeSelectionnee',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                data: [
                  ['Heure', ...jours],
                  ...heures
                      .map((heure) => [
                            heure,
                            ...jours.map((jour) {
                              final coursList = emploiDuTemps[jour]
                                  ?.where((c) => c.time == heure)
                                  .toList();
                              if (coursList != null && coursList.isNotEmpty) {
                                final cours = coursList.first;
                                return '${cours.matiere}\n${cours.enseignant}';
                              } else {
                                return '-';
                              }
                            }).toList(),
                          ])
                      .toList(),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}

class Cours {
  final String time;
  final String matiere;
  final String enseignant;

  Cours({
    required this.time,
    required this.matiere,
    required this.enseignant,
  });
}
