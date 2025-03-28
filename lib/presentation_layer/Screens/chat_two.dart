import 'package:bloc_test/data/models/ChatModel.dart';
import 'package:bloc_test/presentation_layer/Screens/constChat.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:flutter/material.dart';

class ChatTwo extends StatefulWidget {
  const ChatTwo({super.key});

  @override
  State<ChatTwo> createState() => _ChatTwoState();
}

class _ChatTwoState extends State<ChatTwo> {
  TextEditingController text = TextEditingController();
  String myname = 'chattwo';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        title: Text('chat two'),
      ),
      body: Container(
          color: Colors.grey,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: Chat.length,
                  itemBuilder: (_, index) => BubbleSpecialThree(
                    isSender: Chat[index].sender_name == myname ? true : false,
                    // isSender => si false ma3neha msg tib3athli si true => msg ena be3thou

                    text: Chat[index].text.toString(),
                    color: Chat[index].sender_name == myname
                        ? Colors.green
                        : Colors.blue,
                    tail: true,
                    textStyle: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(15),
                color: Colors.black87,
                height: 100,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: text,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // donc houni ey msg bich yiktbou luser bich yitzed fi liste w ba3ed automatiquement yitzed fil bd
                        setState(() {
                          Chat.add(ModelChat(text.text, myname));
                          text.text = '';
                        });
                      },
                      icon: Icon(Icons.send, color: Colors.blue),
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }
}