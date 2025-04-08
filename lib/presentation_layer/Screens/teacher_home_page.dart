import 'package:flutter/material.dart';

class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Espace Enseignant')),
      body: Center(child: Text('Contenu réservé aux enseignants')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action spécifique aux enseignants
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
