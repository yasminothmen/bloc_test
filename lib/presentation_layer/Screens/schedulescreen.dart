import 'package:bloc_test/model/emploi.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:iconly/iconly.dart';

class EmploiDuTempsScreen extends StatefulWidget {
  @override
  _EmploiDuTempsScreenState createState() => _EmploiDuTempsScreenState();
}

class _EmploiDuTempsScreenState extends State<EmploiDuTempsScreen> {
  EmploiDuTemps? emploi;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmploiDuTemps();
  }

  Future<void> _fetchEmploiDuTemps() async {
    // Remplacer par votre appel API réel
    final response = await http.get(Uri.parse('URL_API/emploi-du-temps'));

    if (response.statusCode == 200) {
      setState(() {
        // emploi = EmploiDuTemps.fromJson(json.decode(response.body));
        isLoading = false;
      });
    } else {
      // Gérer l'erreur
      setState(() => isLoading = false);
    }
  }

  Future<void> _downloadEmploi() async {
    // Implémenter le téléchargement du fichier
    // Utiliser le package flutter_downloader ou dio
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        centerTitle: true,
        title: const Text(
          "Mon Emploi",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        actions: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: IconButton(
                  onPressed: _downloadEmploi,
                  icon: Icon(
                    IconlyBold.download,
                    size: 30,
                    color: Colors.black,
                  )))
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (emploi != null) ...[
                      Text(emploi!.titre,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      _buildEmploiTable(),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmploiTable() {
    return Table(
      border: TableBorder.all(),
      children: [
        TableRow(
          children: [
            TableCell(child: Center(child: Text('Heure'))),
            TableCell(child: Center(child: Text('Lundi'))),
            TableCell(child: Center(child: Text('Mardi'))),
            // Ajouter les autres jours...
          ],
        ),
        // Ajouter les lignes pour chaque créneau horaire
        TableRow(
          children: [
            TableCell(child: Center(child: Text('8h-10h'))),
            TableCell(
                child: Center(
                    child: Text(emploi!.jours['Lundi']?[0].matiere ?? ''))),
            TableCell(
                child: Center(
                    child: Text(emploi!.jours['Mardi']?[0].matiere ?? ''))),
          ],
        ),
        // Continuer pour les autres créneaux...
      ],
    );
  }
}
