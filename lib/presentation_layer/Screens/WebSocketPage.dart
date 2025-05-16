import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';

import '../../model/conversation.dart';
import '../../services/conversation_service.dart';

import '../../constants/BackendUrl.dart';
import '../../model/model chat.dart';
import '../bloc/websocket_bloc.dart';
import '../bloc/websocket_event.dart';
import '../bloc/websocket_state.dart';

class WebSocketPage extends StatefulWidget {
  final String contactName;
  final String idSender;
  final String idReceiver;
  final ImageProvider contactImage;
  final String chatRoomId;
  const WebSocketPage(
    this.contactName,
    this.idSender,
    this.idReceiver,
    this.contactImage,
    this.chatRoomId,
  );

  @override
  State<WebSocketPage> createState() => _WebSocketPageState();
}

class _WebSocketPageState extends State<WebSocketPage> {
  final ConversationService _conv = ConversationService();
  Conversation? conv;
  bool _isLoading = true;

  Future<void> getChat(senderId, receiverId) async {
    try {
      final chat = await _conv.getconversationBymembers(senderId, receiverId);
      debugPrint('Conversation reçue: ${chat.toJson()}');
      setState(() {
        conv = chat;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération de la conversation: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getChat(widget.idSender, widget.idReceiver);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return BlocProvider(
      create: (context) => WebSocketBloc(),
      child: _WebSocketPageContent(
        contactName: widget.contactName,
        contactImage: widget.contactImage,
        chatRoomId: widget.chatRoomId,
        conversation: conv,
        isLoading: _isLoading,
        idReceiver: widget.idReceiver,
      ),
    );
  }
}

class _WebSocketPageContent extends StatefulWidget {
  final String contactName;
  final ImageProvider contactImage;
  final String chatRoomId;
  final Conversation? conversation;
  final bool isLoading;
  final String idReceiver;
  const _WebSocketPageContent({
    required this.contactName,
    required this.contactImage,
    required this.chatRoomId,
    this.conversation,
    required this.isLoading,
    required this.idReceiver,
  });

  @override
  State<_WebSocketPageContent> createState() => __WebSocketPageContentState();
}

class __WebSocketPageContentState extends State<_WebSocketPageContent> {
  final TextEditingController _messageController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final ScrollController _scrollController = ScrollController();
  List<ModelChat> _messages = [];

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
    _initializeMessages();
  }

  void _initializeMessages() {
    if (widget.conversation?.messages == null) {
      debugPrint('Aucun message dans la conversation');
      return;
    }
    debugPrint(
        'Messages à convertir: ${widget.conversation!.messages!.length}');

    final newMessages = <ModelChat>[];
    for (final message in widget.conversation!.messages!) {
      try {
        newMessages.add(ModelChat(
          id: message.id ?? '',
          content: message.text ?? '',
          senderId: message.senderId ?? '',
          receiverId: message.receiverId ?? widget.idReceiver,
          date: message.date ?? DateTime.now(),
          chatroomId: message.chatroomId ?? widget.chatRoomId,
          type: WebsocketType.TEXT,
        ));
        debugPrint('Message converti: ${newMessages.last.toJson()}');
      } catch (e) {
        debugPrint('Erreur conversion message: $e');
      }
    }

    setState(() {
      _messages = newMessages.reversed.toList();
    });
  }

  @override
  void dispose() {
    _disconnectWebSocket();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
            receiverId: widget.idReceiver,
          ),
        );
      });

      context.read<WebSocketBloc>().add(
            SendWebSocketMessage(
              chatRoomId: widget.chatRoomId,
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
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_messages.isEmpty) {
      return const Center(child: Text("Aucun message dans cette conversation"));
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      itemCount: _messages.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isMe = message.senderId == _currentUser?.uid;

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
            child: const Text('Annuler'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            onPressed: () {},
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
              backgroundImage: widget.contactImage,
              radius: 18,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.contactName, style: const TextStyle(fontSize: 16)),
                const Text('Active 5 minutes ago',
                    style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: _showLogoutDialog,
                child: const Text('supprimer conversation'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: widget.contactImage,
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
                setState(() {
                  _messages.insert(0, state.message as ModelChat);
                });
              }

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
