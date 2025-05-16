import 'Message.dart';
import 'user.dart';

class Conversation {
  String? id;
  String? nom;
   String? senderId;
  String? receiverId;
  List<AppUser>? members;
  List<Message>? messages;

  Conversation({
    this.id,
    this.nom,
    required this.senderId,
    required this.receiverId,
    this.members,
    this.messages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['_id'] ?? json['id'],
      nom: json['nom'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      
      members: json['members'] != null
          ? List<AppUser>.from(
              json['members'].map((u) => AppUser.fromJson(u)))
          : [],
      messages: json['messages'] != null
          ? List<Message>.from(
              json['messages'].map((m) => Message.fromJson(m)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'senderId': senderId,
      'receiverId': receiverId,
      'members': members?.map((u) => u.toJson()).toList(),
      'messages': messages?.map((m) => m.toJson()).toList(),
    };
  }
}
