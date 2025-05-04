import 'package:bloc_test/model/user.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';

class UserService {
  Future<List<AppUser>> getAllUsers() async {
    try {
      Response response = await ApiService.instance.get('/api/user');

      // 🔍 LOG des données brutes reçues
      print('📦 Données reçues des users : ${response.data}');

      return (response.data as List)
          .map((json) => AppUser.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Erreur dans UserService.getAllUsers(): $e');
      rethrow;
    }
  }
}
