// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class Messagemodel {
  String id;
  String text;
  String kind; // type de msg (img, vocale,location...)
  String image;
  String audio;
  String sender_id;
  Timestamp time;
  bool show_time;

  Messagemodel({
    required this.id,
    required this.text,
    required this.kind,
    required this.image,
    required this.audio,
    required this.sender_id,
    required this.time,
    required this.show_time,
  });
  Messagemodel.fromJson(map)
      : this(
            id: map['id'],
            text: map['text'],
            kind: map['kind'],
            image: map['image'],
            audio: map['audio'],
            sender_id: map['sender_id'],
            time: map['time'],
            show_time: map['show_time']);
  to_json() {
    return {
      'id': id,
      'text': text,
      'kind': kind,
      'image': image,
      'audio': audio ,
      'sender_id': sender_id,
      'time': time,
      'show_time': show_time
    };
  }
}
