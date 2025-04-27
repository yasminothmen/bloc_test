import 'package:bloc_test/presentation_layer/Screens/WebSocketPage.dart';
import 'package:bloc_test/presentation_layer/Screens/chattwo.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

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
            const SizedBox(
              height: 10,
            ),
            searchBox(),
            const SizedBox(
              height: 10,
            ),
            _buildChatItem(
              context,
              imagePath: 'assets/images/louiza jones.jpeg',
              name: 'selmi meryam',
              message: 'slt',
              destination: const WebSocketPage(),
            ),
            _buildChatItem(
              context,
              imagePath: 'assets/images/img6.jpg',
              name: 'eya lahmer',
              message: 'cv?',
              destination: const WebSocketPage(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Nouvelle conversation');
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
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
          filled: true,
          border: OutlineInputBorder(
              borderSide: const BorderSide(width: 0, style: BorderStyle.none),
              borderRadius: BorderRadius.circular(27)),
          fillColor: Colors.grey[800],
          contentPadding: EdgeInsets.all(13),
          hintText: "Recherche ",
          hintStyle:
              TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildChatItem(
    BuildContext context, {
    required String imagePath,
    required String name,
    required String message,
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
                backgroundImage: _loadImage(imagePath),
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
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider _loadImage(String path) {
    try {
      return AssetImage(path);
    } catch (e) {
      debugPrint('Error loading image: $e');
      return const AssetImage('assets/images/default_avatar.png');
    }
  }
}
