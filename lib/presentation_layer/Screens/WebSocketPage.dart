import '../bloc/websocket_bloc.dart';
import '../bloc/websocket_event.dart';
import '../bloc/websocket_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WebSocketPage extends StatefulWidget {
  const WebSocketPage({super.key});

  @override
  State<WebSocketPage> createState() => _WebSocketPageState();
}

class _WebSocketPageState extends State<WebSocketPage> {
  final TextEditingController _messageController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty && _currentUser != null) {
      context.read<WebSocketBloc>().add(
            SendWebSocketMessage(
              chatRoomId: '67ee6b75fac02228075638e6',
              sender: _currentUser.uid, // Utilisation de l'UID Firebase
              content: _messageController.text,
              type: 'CHAT',
            ),
          );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebSocket BLoC Example')),
      body: BlocConsumer<WebSocketBloc, WebSocketState>(
        listener: (context, state) {
          if (state is WebSocketError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (state is WebSocketConnecting)
                        const CircularProgressIndicator(),
                      if (state is WebSocketConnected)
                        const Text('Connected!',
                            style: TextStyle(color: Colors.green)),
                      if (_currentUser != null)
                        Text('User ID: ${_currentUser.uid}',
                            style: const TextStyle(fontSize: 12)),
                      if (state is WebSocketDisconnected)
                        const Text('Disconnected',
                            style: TextStyle(color: Colors.red)),
                      if (state is WebSocketMessageReceived)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Message: ${state.message}'),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (value) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: Colors.blue,
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_currentUser != null) {
                          context.read<WebSocketBloc>().add(
                                ConnectWebSocket(
                                  'ws://localhost:8080/ws',
                                  userId: _currentUser.uid, 
                                  token:
                                      'your-auth-token', 
                                ),
                              );
                        }
                      },
                      child: const Text('Connect'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<WebSocketBloc>()
                            .add(DisconnectWebSocket());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Disconnect'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
