import '../../model/model chat.dart';
import 'const.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:flutter/material.dart';

class Chattwo extends StatefulWidget {
  const Chattwo({super.key});

  @override
  State<Chattwo> createState() => _ChattwoState();
}

class _ChattwoState extends State<Chattwo> {
  TextEditingController text = TextEditingController();
  String myname = 'chat two';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        title: const Text('Chat two '),
      ),
      body: Container(
        color: Colors.grey,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: Chat.length,
                itemBuilder: (_, index) => BubbleSpecialThree(
                  isSender: Chat[index].sender_name == myname?true:false,
                  text: Chat[index].text.toString(),
                  color: Chat[index].sender_name == myname
                      ? const Color(0xFF1B97F3)
                      : Colors.green,
                  tail: true,
                  textStyle: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(15),
              color: Colors.black87,
              height: 100,
              child: Row(
                children: [
                  Expanded(
                   
                    child: TextField(
                      controller: text,
                      style: const TextStyle(color: Colors.blue),
                      decoration: const InputDecoration(
                        hintText: 'Écrire un message...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (text.text.trim().isNotEmpty) {
                        setState(() {
                          Chat.add(model_chat(text.text, myname));
                          text.clear();
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.send,
                      color: Colors.blue,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
