import 'package:bloc_test/model/user.dart';
import 'package:bloc_test/services/api_service.dart';
import 'package:bloc_test/services/user_service.dart';
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
  List<AppUser> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
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
                        onTap: () => _navigateToChat(context, fullName),
                      );
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return _buildFriendItem(
                        context,
                        imageProvider:
                            const AssetImage('assets/images/profile.jpg'),
                        name: fullName,
                        onTap: () => _navigateToChat(context, fullName),
                      );
                    }

                    final imageProvider = MemoryImage(snapshot.data!);

                    return _buildFriendItem(
                      context,
                      imageProvider: imageProvider,
                      name: fullName,
                      onTap: () =>
                          _navigateToChat(context, fullName, imageProvider),
                    );
                  },
                );
              },
            ),
    );
  }

  void _navigateToChat(BuildContext context, String contactName,
      [ImageProvider? contactImage]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebSocketPage(
          contactName: contactName,
          contactImage:
              contactImage ?? const AssetImage('assets/images/img6.jpg'), chatRoomId: '',
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
