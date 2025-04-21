import 'package:bloc_test/model/subject.dart';
import 'package:bloc_test/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SubjectService {
  Future<List<Subject>> getAllSubjects() async {
    try {
      final response = await ApiService.instance.get('/subjects');
      
      debugPrint('Réponse API (raw): ${response.data}');
     
      if (response.data is List) {
        return (response.data as List).map((e) => Subject.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw FormatException('La réponse n\'est pas une liste');
      }
    } on DioException catch (e) {
      debugPrint('Erreur Dio: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Erreur inattendue: $e');
      throw Exception('Erreur de chargement des matières');
    }
  }
}