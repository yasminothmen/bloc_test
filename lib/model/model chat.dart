import 'package:intl/intl.dart'; // Pour le formatage des dates

enum WebsocketType {
  TEXT, // Ajoutez d'autres types si nécessaire
  IMAGE,
  FILE,
  // etc.
}

class ModelChat {
  String? id;
  String content;
  String senderId;
  WebsocketType type;
  String? receiverId;
  DateTime date;
  String chatroomId;
  String? senderName; // Optionnel - peut être récupéré séparément

  ModelChat({
    this.id,
    required this.content,
    required this.senderId,
    this.type = WebsocketType.TEXT,
    this.receiverId,
    required this.date,
    required this.chatroomId,
    this.senderName,
  });

  // Factory constructor pour créer un ModelChat à partir d'un JSON
  factory ModelChat.fromJson(Map<String, dynamic> json) {
    return ModelChat(
      id: json['id'] ?? '', // ou une autre valeur par défaut
      content: json['content'] ?? '', // champ obligatoire
      senderId: json['senderId'] ?? '', // champ obligatoire
      type: json['type'] != null
          ? WebsocketType.values.firstWhere(
              (e) => e.toString() == 'WebsocketType.${json['type']}',
              orElse: () => WebsocketType.TEXT,
            )
          : WebsocketType.TEXT,
      receiverId: json['recieverId'] ?? '', // notez l'orthographe différente
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      chatroomId: json['chatroomId'] ?? '',
    );
  }

  // Méthode pour convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'type': type.toString().split('.').last,
      'receiverId': receiverId,
      'date': date.toIso8601String(),
      'chatroomId': chatroomId,
      if (senderName != null) 'senderName': senderName,
    };
  }

  // Helper pour parser le type WebSocket
  static WebsocketType _parseWebsocketType(String type) {
    switch (type) {
      case 'TEXT':
        return WebsocketType.TEXT;
      case 'IMAGE':
        return WebsocketType.IMAGE;
      case 'FILE':
        return WebsocketType.FILE;
      default:
        return WebsocketType.TEXT;
    }
  }

  // Formatage de la date pour l'affichage
  String get formattedDate {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
