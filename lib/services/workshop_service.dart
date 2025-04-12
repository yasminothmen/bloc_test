import 'package:bloc_test/data/models/cours.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WorkshopService {
  static const String baseUrl =
      'http://192.168.155.117:8080/workshops/all';

  final http.Client _client;

  WorkshopService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Cours>> getAllWorkshops() async {
    try{
final response = await _client.get(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
       final utf8Body = utf8.decode(response.bodyBytes);
      return workshopListFromJson(utf8Body); } else {
      throw Exception('Failed to load workshops');
    }
    }catch (e) {
    debugPrint('Error loading workshops: $e');
    rethrow;
  }
    
  }
}
