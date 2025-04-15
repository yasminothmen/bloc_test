import 'dart:convert';
import 'package:bloc_test/constants/strings.dart';

import '../data/models/subject.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SubjectService {

  final http.Client _client;

  SubjectService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Subject>> getAllSubjects() async {
    try {
      final response = await _client.get(
        Uri.parse( '$baseUrl/subjects'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept-Charset': 'UTF-8',
        },
      );

      if (response.statusCode == 200) {
        // Décodage explicite en UTF-8
        final responseBody = utf8.decode(response.bodyBytes);

        // Debug: afficher la réponse brute
        debugPrint('Réponse API (raw): $responseBody');

        final List<Subject> subjects = subjectFromJson(responseBody);

        // Debug: afficher les sujets décodés
        debugPrint('Sujets décodés: ${subjects.map((s) => s.name).toList()}');

        return subjects;
      } else {
        throw Exception('Échec du chargement: Statut ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur dans SubjectService: $e');
      throw Exception('Erreur de chargement des matières: ${e.toString()}');
    }
  }
}
