import 'package:flutter/material.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Espace Étudiant')),
      body: Center(child: Text('Contenu réservé aux étudiants')),
    );
  }
}
