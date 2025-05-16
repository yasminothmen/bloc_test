import 'api_service.dart';

import '../model/model chat.dart';

class MessageService {
  static Future<List<ModelChat>> getMessagesByChatRoomId(String chatRoomId) async {
    try {
      final response = await ApiService.get(
        '/api/conversation/$chatRoomId/messages', 
      );

      if (response.statusCode == 200) {
       
        return (response.data as List)
            .map((json) => ModelChat.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }
}