import '../../model/conversation.dart';
import '../../model/user.dart';
import '../../services/api_service.dart';
import '../../services/conversation_service.dart';
import '../../services/user_service.dart';
import '../../utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'WebSocketPage.dart';

class FriendsListPage extends StatefulWidget {
  const FriendsListPage({super.key});

  @override
  State<FriendsListPage> createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  final UserService _userService = UserService();
  final ConversationService _conv = ConversationService();
  List<AppUser> _users = [];
  Conversation? conv;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadUsers();
  }

  Future<void> getChat(senderId, receiverId) async {
    try {
      final chat = await _conv.getconversationBymembers(senderId, receiverId);
      setState(() {
        conv = chat;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération de la conversation: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _userService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Erreur lors de la récupération des utilisateurs: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Sélectionner un ami',
            style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final fullName = '${user.firstname} ${user.lastname}';
                final idreceiver = user.firebaseUid ?? "";

                return FutureBuilder<Uint8List?>(
                  future: ApiService.getProfileImage(user.email),
                  builder: (context, snapshot) {
                    // Gérer les différents états du FutureBuilder
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildFriendItem(
                        context,
                        imageProvider:
                            const AssetImage('assets/images/profile.jpg'),
                        name: fullName,
                        onTap: () => _navigateToChat(context, fullName,
                            Utils.getidUser() ?? "", idreceiver),
                      );
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return _buildFriendItem(
                        context,
                        imageProvider:
                            const AssetImage('assets/images/profile.jpg'),
                        name: fullName,
                        onTap: () => _navigateToChat(
                          context,
                          fullName,
                          Utils.getidUser() ?? "",
                          idreceiver,
                        ),
                      );
                    }

                    final imageProvider = MemoryImage(snapshot.data!);

                    return _buildFriendItem(
                      context,
                      imageProvider: imageProvider,
                      name: fullName,
                      onTap: () => _navigateToChat(context, fullName,
                          Utils.getidUser() ?? "", idreceiver, imageProvider),
                    );
                  },
                );
              },
            ),
    );
  }

  void _navigateToChat(BuildContext context, String contactName,
      String idSender, String idReceiver,
      [ImageProvider? contactImage]) async {
    final chat = await _conv.getconversationBymembers(idSender, idReceiver);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebSocketPage(
          contactName,
          idSender,
          idReceiver,
          contactImage ?? const AssetImage('assets/images/profile.jpg'),
          chat.id ?? '',
        ),
      ),
    );
  }

  Widget _buildFriendItem(
    BuildContext context, {
    required ImageProvider imageProvider,
    required String name,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
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
            ),
          ),
        ),
      ],
    );
  }
}
