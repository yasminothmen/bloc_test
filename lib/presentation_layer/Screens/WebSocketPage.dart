import '../../constants/BackendUrl.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:iconly/iconly.dart';
import '../bloc/websocket_bloc.dart';
import '../bloc/websocket_event.dart';
import '../bloc/websocket_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WebSocketPage extends StatelessWidget {
  final String contactName;
  final ImageProvider contactImage;
  const WebSocketPage({
    super.key,
    required this.contactName,
    required this.contactImage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WebSocketBloc(),
      child: _WebSocketPageContent(
        contactName: contactName,
        contactImage: contactImage,
      ),
    );
  }
}

class _WebSocketPageContent extends StatefulWidget {
  final String contactName;
  final ImageProvider contactImage;
  const _WebSocketPageContent({
    required this.contactName,
    required this.contactImage,
  });

  @override
  State<_WebSocketPageContent> createState() => __WebSocketPageContentState();
}

class __WebSocketPageContentState extends State<_WebSocketPageContent> {
  final TextEditingController _messageController = TextEditingController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final ScrollController _scrollController = ScrollController();
  final List<String> _messages = [];
  final _imageCache = <String, ImageProvider>{};
  ImageProvider _loadImage(String path) {
    if (_imageCache.containsKey(path)) {
      return _imageCache[path]!;
    }

    try {
      final ImageProvider image;
      if (path.startsWith('http://') || path.startsWith('https://')) {
        image = NetworkImage(path);
      } else {
        image = AssetImage(path);
        precacheImage(image, context);
      }
      _imageCache[path] = image;
      return image;
    } catch (e) {
      debugPrint('Error loading image: $e');
      const defaultImage = AssetImage('assets/images/default_avatar.png');
      _imageCache[path] = defaultImage;
      return defaultImage;
    }
  }

  ImageProvider _getImageProvider() {
    return widget.contactImage;
  }
  @override
  void initState() {
    super.initState();
    _connectWebSocket();
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
        _messages.insert(0, _messageController.text);
      });
      context.read<WebSocketBloc>().add(
            SendWebSocketMessage(
              chatRoomId: '680757903d1cbe079e26aaaf',
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
        final isMe = index % 2 == 0;
        return BubbleSpecialThree(
          text: _messages[index],
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
        content: const Text('Êtes-vous sûr de vouloir supprimer cette conversation ?'),
        actions: [
          TextButton(
            child: const Text(
              'Annuler',
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            onPressed: () {},//houni call api :delete conversation
            child:
                const Text('Supprimer', style: TextStyle(color: Colors.red)),
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
              backgroundImage:_getImageProvider(),
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
