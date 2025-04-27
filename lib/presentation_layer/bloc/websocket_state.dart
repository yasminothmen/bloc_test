import 'package:equatable/equatable.dart';

abstract class WebSocketState extends Equatable {
  const WebSocketState();

  @override
  List<Object> get props => [];
}

class WebSocketInitial extends WebSocketState {}

class WebSocketConnecting extends WebSocketState {}

class WebSocketConnected extends WebSocketState {}

class WebSocketDisconnected extends WebSocketState {}

class WebSocketError extends WebSocketState {
  final String message;

  const WebSocketError(this.message);

  @override
  List<Object> get props => [message];
}

class WebSocketMessageReceived extends WebSocketState {
  final List<String> messages; // Liste de tous les messages

  const WebSocketMessageReceived(this.messages);

  @override
  List<Object> get props => [messages];
}

class NewMessageReceived extends WebSocketState {
  final dynamic message;

  const NewMessageReceived(this.message);

  @override
  List<Object> get props => [message];
}

class NewNotificationReceived extends WebSocketState {
  final String notification;

  const NewNotificationReceived(this.notification);

  @override
  List<Object> get props => [notification];
}
