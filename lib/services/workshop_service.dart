import '../model/cours.dart';
import 'package:flutter/material.dart';
import 'package:bloc_test/services/api_service.dart';
import 'package:dio/dio.dart';

class WorkshopService {
  Future<void> addWorkshop(Cours workshop) async {
    try {
      final response = await ApiService.instance.post(
        '/workshops/add',
        data: workshop.toJson(), // Assurez-vous que votre modèle Cours a une méthode toJson()
      );

      if (response.statusCode != 201 ) {
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
}