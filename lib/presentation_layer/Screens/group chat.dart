import 'package:bloc_test/data/models/ChatModel.dart';
import 'package:bloc_test/data/models/MessageModel.dart';
import 'package:bloc_test/data/models/user.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Group_chat extends StatefulWidget {
  group_model chat_data;

  Group_chat(this.chat_data);

  @override
  State<Group_chat> createState() => _Group_chatState(chat_data);
}

class _Group_chatState extends State<Group_chat> {
  TextEditingController text = TextEditingController();

  String auth = FirebaseAuth.instance.currentUser!
      .uid; // njib id mte3i mil firebase bich nist7a9ha fil get_x_user()

  group_model chat_data;

  _Group_chatState(this.chat_data);
  List chat = [];
  List unread = [];
  late User x;
  String image = 'image';
  String url = '';

  @override
  void initState() {
    // TODO: implement initState
    get_x_user();
    Stream_chat();
    firebase_seen();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          fit: BoxFit.fill,
          colorFilter: ColorFilter.mode(Colors.black87, BlendMode.overlay),
          image: NetworkImage(
              // background image mte3 page discussion
              'https://images.unsplash.com/photo-1554151228-14d9def656e4?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=333&q=80'),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          elevation: 0,
          title: Row(
            children: [
              chat_data.image == ''
                  ? CircleAvatar(
                      backgroundColor: Colors.white,
                    )
                  : CircleAvatar(
                      backgroundImage: NetworkImage(chat_data.image),
                    ),
              SizedBox(width: 15),
              Text(chat_data.group_name),
            ],
          ),
          //  action pour supprimer une discussion entre moi et un autre personne:
          actions: [
            PopupMenuButton(
                onSelected: (e) async {
                  if (e == 'quitter le group') {
                    CollectionReference ref =
                        await FirebaseFirestore.instance.collection('chats');
                    ref
                        .doc(chat_data.id)
                        .delete()
                        .then((value) => Navigator.pop(context));
                  }
                },
                itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text('quitter le group'),
                        value: 'quitter le group',
                      )
                    ])
          ],
        ),
        body: Container(
          color: Colors.grey,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: chat.length,
                    reverse:
                        true, // ni3ksou list mte3 msget bech doub metod5ol lil discussion

                    itemBuilder: (_, index) => message_item(
                        Messagemodel.fromJson(
                            chat[chat.length - (index + 1)]))),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                color: Colors.black,
                height: 100,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.add, color: Colors.green, size: 30)),
                    Expanded(
                      child: TextField(
                        onTapOutside: (event) {
                          FocusScope.of(context).requestFocus(new FocusNode());
                        },
                        cursorColor: Colors.white,
                        controller: text,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(color: Colors.green),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        await add_message('text');

                        text.text = '';
                        setState(() {
                          // my state change code goes here
                        });
                      },
                      icon: const Icon(Icons.send, color: Colors.green),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

// methode bech njib Current user illi 9a3da ni7ki m3ah
  get_x_user() {
    setState(() {
      x = chat_data
          .users[chat_data.users.indexWhere((element) => element.id != auth)];
    });
  }

  Stream_chat() async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chat_data.id)
        .snapshots()
        .listen((event) {
      chat = ModelChat.fromJson(event.data()).chat.toList();
      setState(() {
        chat = ModelChat.fromJson(event.data()).chat.toList();
        unread = ModelChat.fromJson(event.data()).unread.toList();
      });
    });
  }

  add_message(kind) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('chats');
    await ref.doc(chat_data.id).update({
      'chat': FieldValue.arrayUnion([
        Messagemodel(
                show_time: false,
                id: 'id',
                kind: kind,
                image: image,
                audio: url,
                text: text.text,
                sender_id: auth,
                time: Timestamp.now())
            .to_json()
      ])
    });
    await ref.doc(chat_data.id).update({
      'unread': FieldValue.arrayUnion([
        Messagemodel(
                show_time: false,
                id: 'id',
                text: text.text,
                kind: kind,
                image: image,
                audio: url,
                sender_id: auth,
                time: Timestamp.now())
            .to_json()
      ])
    });
  }

// methode bech ndhahrou lwa9t ta7t lmessage:
  Widget message_item(Messagemodel message) {
    int index = chat.indexWhere((element) => element['time'] == message.time);
    return InkWell(
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        setState(() {
          chat[index]['show_time'] = !chat[index]['show_time'];
        });
      },
      child: Column(
        children: [
          BubbleSpecialThree(
            isSender: message.sender_id == auth,
            text: message.text,
            color: message.sender_id == auth ? Colors.green : Colors.blue,
            tail: true,
            seen: seen(message),
            textStyle: const TextStyle(color: Colors.white, fontSize: 16),
          ),

          message.show_time
              ? Text(
                  message.time.toDate().toString(),
                  style: TextStyle(color: Colors.white),
                )
              : SizedBox() // pour afficher le temps dans chaque bulle de msg
        ],
      ),
    );
  }

// methode pour controler seen or unseen msg:
  bool seen(Messagemodel message) {
    bool seen = true;
    for (var i in unread) {
      if (i['text'] == message.text) {
        seen = false;
      }
    }
    return seen;
  }

// methode pour vider le box de unread
  firebase_seen() async {
    var value =
        await FirebaseFirestore.instance.collection('chats').doc(chat_data.id);
    value.snapshots().listen((event) {
      List seen = event['unread'];
      seen.removeWhere((element) => ['sender_id'] != auth);
      value.update({'unread': seen});
    });
  }
}
