import '../model/cours.dart';
import 'package:flutter/material.dart';
import 'package:bloc_test/services/api_service.dart';
import 'package:dio/dio.dart';

class WorkshopService {
  Future<void> addWorkshop(Cours workshop) async {
    try {
      final response = await ApiService.instance.post(
        '/workshops/add',
        data: workshop.toJson(),
      );

      if (response.statusCode != 201) {
        throw Exception(
            'Failed to add workshop. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Error adding workshop: ${e.response?.data ?? e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error adding workshop: $e');
      rethrow;
    }
  }

  // methode get :
  // Dans api_service.dart
  Future<List<Cours>> getAllWorkshops() async {
    try {
      final response = await ApiService.instance.get('/workshops/all');
      if (response.statusCode == 200) {
        // Ajoutez un print pour debugger la structure des données
        print('API Response: ${response.data}');

        final List<dynamic> responseData = response.data;
        return responseData.map<Cours>((json) {
          // Debug chaque élément
          print('Processing item: $json');
          return Cours.fromJson(json);
        }).toList();
      }
      throw Exception('Error fetching workshops: ${response.statusCode}');
    } on DioException catch (e) {
      debugPrint('Dio error: ${e.message}');
      rethrow;
    }
  }
}
