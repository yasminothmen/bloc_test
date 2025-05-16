import '../../model/conversation.dart';
import '../../services/conversation_service.dart';
import '../../services/api_service.dart';
import '../../utils.dart';

import 'friends_list.dart';
import 'WebSocketPage.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class Listdiscussion extends StatefulWidget {
  const Listdiscussion({super.key});

  @override
  State<Listdiscussion> createState() => _ListdiscussionState();
}

class _ListdiscussionState extends State<Listdiscussion> {
  final ConversationService _conv = ConversationService();
  List<ConversationWithImage> _discussionsWithImages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final String? userId = Utils.getidUser();
    if (userId != null) {
      getDisscussionByUser(userId);
    }
  }

  Future<void> getDisscussionByUser(String senderId) async {
    try {
      final discussions = await _conv.getChatroomsByuserId(senderId);
      final currentUserId = Utils.getidUser();

      List<ConversationWithImage> withImages = [];

      for (final conv in discussions) {
        final receiver = conv.members!.firstWhere(
          (u) => u.firebaseUid != currentUserId,
          orElse: () => conv.members!.first,
        );

        ImageProvider imageProvider;

        try {
          final imageData = await ApiService.getProfileImage(receiver.email);
          imageProvider = imageData != null
              ? MemoryImage(imageData)
              : const AssetImage('assets/images/profile.jpg');
        } catch (_) {
          imageProvider = const AssetImage('assets/images/profile.jpg');
        }

        withImages.add(ConversationWithImage(
          conversation: conv,
          imageProvider: imageProvider,
        ));
      }

      setState(() {
        _discussionsWithImages = withImages;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération de la conversation: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Utils.getidUser();
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: const Text('Discussions',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30))),
      body: Container(
        color: Colors.black,
        child: ListView(
          children: [
            const SizedBox(height: 10),
            searchBox(),
            const SizedBox(height: 10),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: _discussionsWithImages.map((item) {
                      final conv = item.conversation;
                      final imageProvider = item.imageProvider;
                      final lastMessage = conv.messages!.isNotEmpty
                          ? conv.messages!.last
                          : null;

                      final receiver = conv.members!.firstWhere(
                        (u) => u.firebaseUid != currentUserId,
                        orElse: () => conv.members!.first,
                      );

                      return _buildChatItem(
                        context,
                        imageProvider: imageProvider,
                        name: '${receiver.firstname ?? ''} ${receiver.lastname ?? ''}'
                                .trim()
                                .isEmpty
                            ? 'Nom inconnu'
                            : '${receiver.firstname ?? ''} ${receiver.lastname ?? ''}',
                        message: lastMessage?.text ?? "Aucun message",
                        time: lastMessage?.date
                                ?.toLocal()
                                .toString()
                                .substring(11, 16) ??
                            "--:--",
                        destination: WebSocketPage(
                          receiver.firstname ?? 'Nom inconnu',
                          currentUserId ?? "", // idSender
                          receiver.firebaseUid ?? "", // idReceiver
                          imageProvider,
                          conv.id!, // ✅ chatRoomId dynamique récupéré depuis Conversation
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FriendsListPage()),
          );
        },
        backgroundColor: const Color.fromARGB(255, 94, 20, 63),
        child: const Icon(
          Icons.add_comment_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  TextField searchBox() {
    return TextField(
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        filled: true,
        border: OutlineInputBorder(
            borderSide: const BorderSide(width: 0, style: BorderStyle.none),
            borderRadius: BorderRadius.circular(27)),
        fillColor: Colors.grey[800],
        contentPadding: const EdgeInsets.all(13),
        hintText: "Recherche ",
        hintStyle:
            const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildChatItem(
    BuildContext context, {
    required ImageProvider imageProvider,
    required String name,
    required String message,
    required String time,
    required Widget destination,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => destination),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: imageProvider,
              ),
              title: Text(
                name,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                message,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                time,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ConversationWithImage {
  final Conversation conversation;
  final ImageProvider imageProvider;

  ConversationWithImage({
    required this.conversation,
    required this.imageProvider,
  });
}
