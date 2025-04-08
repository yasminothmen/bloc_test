import 'dart:convert';

import 'package:bloc_test/data/models/classes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;


  class ClassService {
  // static const String baseUrl = 'http://localhost:8080/api/classes'; 
  static const String baseUrl = 'http://192.168.155.117:8080/api/classes'; // Pour iOS/web
  
  final http.Client _client;

  ClassService({http.Client? client}) : _client = client ?? http.Client();

 Future<List<ClassEntity>> getAllClasses() async {
  try {
    final response = await _client.get(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      // Utilisez utf8.decode pour décoder explicitement
      final utf8Body = utf8.decode(response.bodyBytes);
      return classListFromJson(utf8Body);
    } else {
      throw Exception('Failed to load classes');
    }
  } catch (e) {
    debugPrint('Error loading classes: $e');
    rethrow;
  }
}
}
