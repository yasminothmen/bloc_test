import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'websocket_event.dart';
import 'websocket_state.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketBloc extends Bloc<WebSocketEvent, WebSocketState> {
  late StompClient stompClient;
  late Completer<void> _connectionCompleter = Completer();
  String? _token;

  WebSocketBloc() : super(WebSocketInitial()) {
    on<ConnectWebSocket>(_onConnect);
    on<DisconnectWebSocket>(_onDisconnect);
    on<SendWebSocketMessage>(_onSendMessage);
    on<JoinChatEvent>(_onJoinChat);
  }

  Future<void> _onConnect(
    ConnectWebSocket event,
    Emitter<WebSocketState> emit,
  ) async {
    _token = event.token; // Stockez le token
    emit(WebSocketConnecting());
    try {
      stompClient = StompClient(
        config: StompConfig(
          // Initialise un StompClient
          url: event.url,
          onConnect: (StompFrame frame) {
            if (!_connectionCompleter.isCompleted) {
              emit(WebSocketConnected());
              _connectionCompleter.complete();
              stompClient.subscribe(
                destination: '/topic/messages/${event.userId}',
                callback: (frame) {
                  try {
                    final message = json.decode(frame.body!);
                    emit(WebSocketMessageReceived(message));
                  } catch (e) {
                    emit(WebSocketError('Failed to parse message: $e'));
                  }
                },
              );
            }
          },
          beforeConnect: () async {
            print('waiting to connect...');
            await Future.delayed(const Duration(milliseconds: 200));
            print('connecting...');
          },
          onWebSocketError: (dynamic error) {
            if (!_connectionCompleter.isCompleted) {
              emit(WebSocketError(error.toString()));
              _connectionCompleter.completeError(error);
            }
          },
          stompConnectHeaders: {'Authorization': 'Bearer ${event.token}'},
          webSocketConnectHeaders: {'Authorization': 'Bearer ${event.token}'},
          connectionTimeout: const Duration(seconds: 5), // Timeout ajouté
        ),
      );

      stompClient.activate();
      await _connectionCompleter.future;
    } catch (e) {
      if (!_connectionCompleter.isCompleted) {
        emit(WebSocketError('Connection failed: $e'));
        _connectionCompleter.completeError(e);
      }
    }
  }

  Future<void> _onDisconnect(
    DisconnectWebSocket event,
    Emitter<WebSocketState> emit,
  ) async {
    stompClient.deactivate();
    emit(WebSocketDisconnected());
    _connectionCompleter = Completer(); // Réinitialiser pour une reconnexion
  }

  Future<void> _onSendMessage(
    SendWebSocketMessage event,
    Emitter<WebSocketState> emit,
  ) async {
    if (state is! WebSocketConnected) {
      emit(WebSocketError('Not connected to WebSocket'));
      return;
    }

    try {
      // Adapter le format du message à ce que attend votre backend
      final chatMessage = {
        'chatRoomId': event.chatRoomId,
        'sender': event.sender,
        'content': event.content,
        'timestamp': DateTime.now().toIso8601String(),
      };
      stompClient.send(
        destination: '/app/chat.sendMessage',
        body: json.encode(chatMessage),
        headers: {'Authorization': 'Bearer $_token'},
      );
      print('message send successfully');
    } catch (e) {
      emit(WebSocketError('Failed to send message: $e'));
    }
  }

// Ajouter une méthode pour rejoindre un chat
  Future<void> _onJoinChat(
    JoinChatEvent event,
    Emitter<WebSocketState> emit,
  ) async {
    try {
      stompClient.send(
        destination: '/app/chat.addUser',
        body: json.encode({
          'sender': event.userId,
          'chatRoomId': event.chatRoomId,
        }),
      );
    } catch (e) {
      emit(WebSocketError('Failed to join chat: $e'));
    }
  }

  @override
  Future<void> close() {
    stompClient.deactivate();
    return super.close();
  }
}
