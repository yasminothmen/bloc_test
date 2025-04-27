import 'package:bloc_test/constants/BackendUrl.dart';
import '../bloc/websocket_bloc.dart';
import '../bloc/websocket_event.dart';
import '../bloc/websocket_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WebSocketPage extends StatelessWidget {
  const WebSocketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WebSocketBloc(),
      child: const _WebSocketPageContent(),
    );
  }
}

class _WebSocketPageContent extends StatefulWidget {
  const _WebSocketPageContent({super.key});

  @override
  State<_WebSocketPageContent> createState() => __WebSocketPageContentState();
}

class __WebSocketPageContentState extends State<_WebSocketPageContent> {
  final TextEditingController _messageController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final ScrollController _scrollController = ScrollController();
  final List<String> _messages = [];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty && _currentUser != null) {
      context.read<WebSocketBloc>().add(
            SendWebSocketMessage(
              chatRoomId: '680757903d1cbe079e26aaaf',
              sender: _currentUser.uid,
              content: _messageController.text,
              type: 'CHAT',
            ),
          );
      _messageController.clear();
    }
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return const Center(child: Text('Aucun message reçu'));
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(_messages[index]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectionStatus(WebSocketState state) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[200],
      child: Row(
        children: [
          if (state is WebSocketConnecting)
            const CircularProgressIndicator(),
          if (state is WebSocketConnected)
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
          if (state is WebSocketDisconnected)
            const Icon(Icons.wifi_off, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          if (state is WebSocketConnecting)
            const Text('Connexion en cours...'),
          if (state is WebSocketConnected)
            const Text('Connecté', style: TextStyle(color: Colors.green)),
          if (state is WebSocketDisconnected)
            const Text('Déconnecté', style: TextStyle(color: Colors.red)),
          const Spacer(),
          if (_currentUser != null)
            Text(
              'User: ${_currentUser!.email ?? _currentUser!.uid.substring(0, 8)}',
              style: const TextStyle(fontSize: 12),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebSocket Chat')),
      body: BlocConsumer<WebSocketBloc, WebSocketState>(
        listener: (context, state) {
          if (state is WebSocketError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is NewMessageReceived) {
            _messages.add(state.message.toString());
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          }
        },
        builder: (context, state) {
          return FutureBuilder<String?>(
            future: _currentUser?.getIdToken(),
            builder: (context, snapshot) {
              final token = snapshot.data;

              return Column(
                children: [
                  _buildConnectionStatus(state),
                  
                  Expanded(
                    child: _buildMessageList(),
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
                            onSubmitted: (_) => _sendMessage(),
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
                          onPressed: () async {
                            if (_currentUser != null && token != null) {
                              context.read<WebSocketBloc>().add(
                                    ConnectWebSocket(
                                      '$wsUrl/ws',
                                      userId: _currentUser.uid,
                                      token: token,
                                    ),
                                  );
                            }
                          },
                          child: const Text('Connect'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<WebSocketBloc>()
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
          );
        },
      ),
    );
  }
}