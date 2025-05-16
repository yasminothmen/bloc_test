import '../model/conversation.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';

class ConversationService {
  Future<Conversation> getconversationBymembers(
      String senderId, String receiverId) async {
    try {
      Response response = await ApiService.instance
          .get('/api/conversation/between/$senderId/$receiverId');
      print('📦  conversation : $response');

      // 🔍 LOG des données brutes reçues
      print('messages : ${response.data}');

      return Conversation.fromJson(response.data);
    } catch (e) {
      print('❌ Erreur : $e');
      rethrow;
    }
  }

  // methode fetch all discussions of the user connected
  Future<List<Conversation>> getChatroomsByuserId(String senderId) async {
    try {
      Response response =
          await ApiService.instance.get('/api/conversation/user/$senderId');
      print('📦 all disscussions of the user connected : $response');
      return (response.data as List)
          .map((json) => Conversation.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Erreur : $e');
      rethrow;
    }
  }
}
