import '../../constants/BackendUrl.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:iconly/iconly.dart';
import '../../model/model chat.dart';
import '../../services/message_service.dart';
import '../bloc/websocket_bloc.dart';
import '../bloc/websocket_event.dart';
import '../bloc/websocket_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WebSocketPage extends StatelessWidget {
  final String contactName;
  final ImageProvider contactImage;
  final String chatRoomId;
  const WebSocketPage({
    super.key,
    required this.contactName,
    required this.contactImage,
    required this.chatRoomId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WebSocketBloc(),
      child: _WebSocketPageContent(
        contactName: contactName,
        contactImage: contactImage,
        chatRoomId: chatRoomId,
      ),
    );
  }
}

class _WebSocketPageContent extends StatefulWidget {
  final String contactName;
  final ImageProvider contactImage;
  final String chatRoomId;
  const _WebSocketPageContent({
    required this.contactName,
    required this.contactImage,
    required this.chatRoomId,
  });

  @override
  State<_WebSocketPageContent> createState() => __WebSocketPageContentState();
}

class __WebSocketPageContentState extends State<_WebSocketPageContent> {
  final TextEditingController _messageController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final ScrollController _scrollController = ScrollController();
  List<ModelChat> _messages = [];

  ImageProvider _getImageProvider() {
    return widget.contactImage;
  }

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
    _loadMessages(); // Ajoutez ceci pour charger les messages

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getImageProvider();
    });
  }

  @override
  void dispose() {
    _disconnectWebSocket();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final messages =
          await MessageService.getMessagesByChatRoomId(widget.chatRoomId);
      setState(() {
        _messages = messages.reversed
            .toList(); // Inversez pour afficher les plus récents en bas
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des messages: $e')),
      );
    }
  }

  Future<void> _connectWebSocket() async {
    if (_currentUser != null) {
      final token = await _currentUser.getIdToken();
      if (token != null) {
        context.read<WebSocketBloc>().add(
              ConnectWebSocket(
                '$wsUrl/ws',
                userId: _currentUser.uid,
                token: token,
              ),
            );
      }
    }
  }

  void _disconnectWebSocket() {
    context.read<WebSocketBloc>().add(DisconnectWebSocket());
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty && _currentUser != null) {
      setState(() {
        _messages.insert(
            0,
            ModelChat(
              content: _messageController.text,
              senderId: _currentUser.uid,
              date: DateTime.now(),
              chatroomId: widget.chatRoomId,
              type: WebsocketType.TEXT,
              receiverId: '', // Ajoutez si nécessaire
              // autres champs requis par ModelChat
            ));
      });
      context.read<WebSocketBloc>().add(
            SendWebSocketMessage(
              chatRoomId: '6818fd4cb345d7256c777e61',
              sender: _currentUser.uid,
              content: _messageController.text,
              type: 'CHAT',
            ),
          );
      _messageController.clear();
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
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      itemCount: _messages.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isMe = message.senderId ==
            _currentUser
                ?.uid; // Vérifiez si l'expéditeur est l'utilisateur actuel
        return BubbleSpecialThree(
          text: message.content,
          color: isMe ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD),
          tail: true,
          isSender: isMe,
          textStyle: TextStyle(
            fontSize: 16,
            color: isMe ? Colors.black87 : Colors.black87,
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Supprimer cette conversation ?'),
        content: const Text(
            'Êtes-vous sûr de vouloir supprimer cette conversation ?'),
        actions: [
          TextButton(
            child: const Text(
              'Annuler',
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            onPressed: () {}, //houni call api :delete conversation
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: _getImageProvider(),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.contactName, style: TextStyle(fontSize: 16)),
                Text('Active 5 minutes ago', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                  onTap: _showLogoutDialog,
                  child: const Text('supprimer conversation')),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: _getImageProvider(),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.09),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: BlocConsumer<WebSocketBloc, WebSocketState>(
          listener: (context, state) {
            if (state is WebSocketError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
            if (state is NewMessageReceived) {
              if (state.message is ModelChat) {
                _messages.add(state.message as ModelChat);
              } 
              //else {
              //   _messages.add(ModelChat(
              //     content: state.message.toString(),
              //     senderId: state.senderId ?? _currentUser?.uid ?? '',
              //     date: DateTime.now(),
              //     chatroomId: widget.chatRoomId,
              //     type: WebsocketType.TEXT,
              //     // autres champs
              //   ));
              // }
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
            return Column(
              children: [
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
                        icon: const Icon(
                          IconlyLight.send,
                          size: 30,
                        ),
                        color: Colors.black,
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
