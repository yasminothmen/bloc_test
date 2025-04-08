import 'package:equatable/equatable.dart';

abstract class WebSocketEvent extends Equatable {
  const WebSocketEvent();

  @override
  List<Object> get props => [];
}

class ConnectWebSocket extends WebSocketEvent {
  final String url;
  final String userId; // Ajout du paramètre userId
  final String token; // Ajout du token
  const ConnectWebSocket(this.url, {required this.userId, required this.token});

  @override
  List<Object> get props => [url, userId, token];
}

class SendWebSocketMessage extends WebSocketEvent {
  final String chatRoomId;
  final String sender;
  final String content;
  final String type;

  const SendWebSocketMessage({
    required this.chatRoomId,
    required this.sender,
    required this.content,
    required this.type,
  });

  @override
  List<Object> get props => [chatRoomId, sender, content, type];
}

// Nouveaux événements
class JoinChatEvent extends WebSocketEvent {
  final String userId;
  final String chatRoomId;

  const JoinChatEvent(this.userId, this.chatRoomId);

  @override
  List<Object> get props => [userId, chatRoomId];
}

class SendChatMessage extends WebSocketEvent {
  final String chatRoomId;
  final String sender;
  final String content;
  final String type;

  const SendChatMessage({
    required this.chatRoomId,
    required this.sender,
    required this.content,
    required this.type,
  });

  @override
  List<Object> get props => [chatRoomId, sender, content, type];
}

class DisconnectWebSocket extends WebSocketEvent {}
