// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc_test/data/models/user.dart';

class ModelChat {
  String id;
  List<User> users = [];
  List users_id = [];
  List chat = [];
  List unread = [];

  ModelChat({
    required this.id,
    required this.users,
    required this.chat,
    required this.users_id,
    required this.unread,
  });

  ModelChat.fromJson(map)
      : this(
            id: map['id'],
            users: map['users'].map<User>((e) => User.fromJson(e)).toList(),
            chat: map['chat'],
            users_id: map['users_id'],
            unread: map['unread']);

  toJson() {
    return {
      'id': id,
      'users': users.map((e) => e.toJson()).toList(),
      'users_id': users_id,
      'chat': chat,
      'unread': unread
    };
  }
}

class group_model {
  String id;
  String group_name;
  String image;
  List<User> users = [];
  List users_id = [];
  List chat = [];
  List unread = [];

  group_model({
    required this.id,
    required this.group_name,
    required this.image,
    required this.users,
    required this.users_id,
    required this.chat,
    required this.unread,
  });

  group_model.fromJson(map)
      : this(
            id: map['id'],
            group_name: map['group_name'],
            image: map['image'],
            users: map['users'].map<User>((e) => User.fromJson(e)).toList(),
            chat: map['chat'],
            users_id: map['users_id'],
            unread: map['unread']);

  toJson() {
    return {
      'id': id,
      'users': users.map((e) => e.toJson()).toList(),
      'users_id': users_id,
      'chat': chat,
      'unread': unread
    };
  }
}
