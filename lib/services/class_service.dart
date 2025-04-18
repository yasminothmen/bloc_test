import 'package:bloc_test/model/classes.dart';
import 'package:bloc_test/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ClassService {
  Future<List<ClassEntity>> getAllClasses() async {
    try {
      final response = await ApiService.instance.get('/api/classes');

      if (kDebugMode) {
        print('Réponse brute: ${response.data}');
        print('Type de la réponse: ${response.data.runtimeType}');
      }

      // Vérification du type de réponse
      if (response.data is! List) {
        throw FormatException('La réponse API n\'est pas une liste');
      }

      // Conversion directe sans jsonDecode
      return (response.data as List).map<ClassEntity>((classJson) {
        try {
          return ClassEntity.fromJson(classJson as Map<String, dynamic>);
        } catch (e) {
          if (kDebugMode) {
            print('Erreur parsing classe: $e');
            print('Données problématiques: $classJson');
          }
          throw FormatException('Format de classe invalide');
        }
      }).toList();

    } on DioException catch (e) {
      if (kDebugMode) {
        print('Erreur Dio: ${e.message}');
        print('Statut: ${e.response?.statusCode}');
        print('Réponse: ${e.response?.data}');
      }
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('Erreur inattendue: $e');
      }
      throw Exception('Erreur de chargement des classes');
    }
  }
}