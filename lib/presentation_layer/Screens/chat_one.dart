import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc_test/data/models/ChatModel.dart';
import 'package:bloc_test/data/models/MessageModel.dart';
import 'package:bloc_test/data/models/user.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_audio.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_image.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

class ChatOne extends StatefulWidget {
  ModelChat chat_data;

  ChatOne(this.chat_data);

  @override
  State<ChatOne> createState() => _ChatOneState(chat_data);
}

class _ChatOneState extends State<ChatOne> {
  TextEditingController text = TextEditingController();

  String auth = FirebaseAuth.instance.currentUser!
      .uid; // njib id mte3i mil firebase bich nist7a9ha fil get_x_user()

  ModelChat chat_data;

  _ChatOneState(this.chat_data);
  List chat = [];
  List unread = [];
  late User x;
  String image = '';
  late File Imag;
  bool louding = false;
  final record = AudioRecorder();
  bool is_record = false;
  String path = '';
  String url = '';
  late AudioPlayer audioPlayer;
  bool is_player = false;

  @override
  void initState() {
    text.addListener(
      () {
        setState(() {});
      },
    );
    get_x_user();
    Stream_chat();
    firebase_seen();
    audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    audioPlayer.dispose();
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
              x.image == ''
                  ? CircleAvatar(
                      backgroundColor: Colors.white,
                    )
                  : CircleAvatar(
                      backgroundImage: NetworkImage(x.image),
                    ),
              SizedBox(width: 15),
              Text(x.name),
            ],
          ),
          //  action pour supprimer une discussion entre moi et un autre personne:
          actions: [
            PopupMenuButton(
                onSelected: (e) async {
                  if (e == 'delete') {
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
                        child: Text('delete'),
                        value: 'delete',
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
                        onPressed: () {
                          show_bottom_sheet(context);
                        },
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
                    text.text.isEmpty
                        ? CircleAvatar(
                            backgroundColor: Colors.green,
                            child: IconButton(
                                onPressed: () {
                                  if (!is_record) {
                                    start_record();
                                  } else {
                                    stop_record();
                                  }
                                },
                                icon: is_record
                                    ? Icon(Icons.stop)
                                    : Icon(Icons.mic)),
                          )
                        : IconButton(
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

// methode pour debuter à enregistrer un vocal:
  start_record() async {
    final location = await getApplicationDocumentsDirectory();
    String name = Uuid().v1();
    if (await record.hasPermission()) {
      await record.start(RecordConfig(), path: location.path + name + '.m4a');
      setState(() {
        is_record = true;
      });
    }
    print('start record');
  }

  stop_record() async {
    String? final_path = await record.stop();
    setState(() {
      path = final_path!;
    });
    print('stop record');
    upload();
  }

// upload le record meme que upload img:
  upload() async {
    String name = basename(path);
    final ref = FirebaseStorage.instance.ref('voice/' + name);
    await ref.putFile(File(path));
    String download_url = await ref.getDownloadURL();
    setState(() {
      url = download_url;
    });
    print('uploaded with success');
    add_message('audio');
  }

// methode pour fonctionner l'audio:
  play(url) async {
    await audioPlayer.play(UrlSource(url));
    setState(() {
      is_player = true;
    });
    print('audio player');
  }

  stop() async {
    await audioPlayer.stop();
    setState(() {
      is_player = false;
    });
    print('audio stoped');
  }

// methode pour ouvrir mon galerie et envoyer une image:
  show_bottom_sheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (c) => IntrinsicHeight(
              child: Container(
                color: Colors.black,
                child: Column(
                  children: [
                    Card(
                      color: Colors.grey.shade900,
                      child: ListTile(
                        onTap: () {
                          open_image_camera();
                        },
                        leading: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                        title: Text(
                          'Camera',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Card(
                      color: Colors.grey.shade900,
                      child: ListTile(
                        onTap: () {
                          open_image_gallery();
                        },
                        leading: Icon(Icons.photo, color: Colors.white),
                        title: Text(
                          'Gallery',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    )
                  ],
                ),
              ),
            ));
  }

// methode pour extraire des images à partir du gallerie
  open_image_gallery(context) async {
    var get = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      Imag = File(get!.path);
    });
    showAndsend(context);
  }

  // ouvrir camera to take a photo
  open_image_camera(context) async {
    var get = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      Imag = File(get!.path);
    });
    showAndsend(context);
  }

// methode pour exposer l'image et l'envoyer:
  showAndsend(context) {
    showModalBottomSheet(
        context: context,
        builder: (c) => IntrinsicHeight(
              child: Container(
                color: Colors.black,
                child: Column(
                  children: [
                    Image(image: FileImage(Imag)),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: () async {
                        await upload_image();
                        await add_message('image');
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(30)),
                        child: Text(
                          'Send',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 30),
                        ),
                        alignment: Alignment.center,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ));
  }

// upload image:
  upload_image() async {
    var name_path = basename(Imag.path);
    var ref = FirebaseStorage.instance.ref('image/$name_path');
    await ref.putFile(Imag);
    image = await ref.getDownloadURL();
    print('done');
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
                text: text.text,
                kind: kind,
                image: image,
                audio: url,
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

// methode pour afficher le temps sous le message:
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
          message.kind == 'text'
              ? BubbleSpecialThree(
                  isSender: message.sender_id == auth,
                  text: message.text,
                  color: message.sender_id == auth ? Colors.green : Colors.blue,
                  tail: true,
                  seen: seen(message),
                  textStyle: const TextStyle(color: Colors.white, fontSize: 16),
                )
              : message.kind == 'image'
                  ? BubbleNormalImage(
                      id: message.image, image: Image.network(message.image))
                  : BubbleNormalAudio(
                      onSeekChanged: (e) {},
                      isLoading: false,
                      isPlaying: is_player,
                      onPlayPauseButtonClick: () {
                        if (!is_player) {
                          play(message.audio);
                        } else {
                          stop();
                        }
                      },),

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


// on a fait un box ou on met les msg que j'ai envoyer et l'autre utilisateur va vider ce box et voir les msg