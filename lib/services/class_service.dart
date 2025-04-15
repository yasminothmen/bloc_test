import 'dart:convert';

import 'package:bloc_test/constants/strings.dart';

import '../data/models/classes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;


  class ClassService {
  final http.Client _client;

  ClassService({http.Client? client}) : _client = client ?? http.Client();

 Future<List<ClassEntity>> getAllClasses() async {
  try {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/classes'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
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
