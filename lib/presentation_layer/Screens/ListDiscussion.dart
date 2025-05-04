import 'friends_list.dart';
import 'WebSocketPage.dart';
import 'package:flutter/material.dart';

class Listdiscussion extends StatefulWidget {
  const Listdiscussion({super.key});

  @override
  State<Listdiscussion> createState() => _ListdiscussionState();
}

class _ListdiscussionState extends State<Listdiscussion> {
  @override
  Widget build(BuildContext context) {
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
            _buildChatItem(
              context,
              imageProvider: const AssetImage('assets/images/louiza jones.jpeg'),
              name: 'Selmi Meryam',
              message: 'slt',
              time: '10:40',
              destination: WebSocketPage(
                contactName: 'Selmi Meryam',
                contactImage: const AssetImage('assets/images/louiza jones.jpeg'),
              ),
            ),
            _buildChatItem(
              context,
              imageProvider: const AssetImage('assets/images/img6.jpg'),
              name: 'eya lahmer',
              message: 'cv?',
              time: '14:35',
              destination: WebSocketPage(
                contactName: 'eya lahmer',
                contactImage: const AssetImage('assets/images/img6.jpg'),
              ),
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
              const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
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