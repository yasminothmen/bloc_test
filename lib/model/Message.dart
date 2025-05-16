enum WebsocketType { CHAT, JOIN, LEAVE }

class Message {
  String? id;
  String? text;
  String? senderId;
  WebsocketType? type;
  String? receiverId;
  DateTime? date;
  String? chatroomId;

  Message({
    this.id,
    this.text,
    this.senderId,
    this.type,
    this.receiverId,
    this.date,
    this.chatroomId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      text: json['text'],
      senderId: json['senderId'],
      type: _websocketTypeFromString(json['type']),
      receiverId: json['receiverId'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      chatroomId: json['chatroomId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'senderId': senderId,
      'type': type?.name, // converts enum to string
      'receiverId': receiverId,
      'date': date?.toIso8601String(),
      'chatroomId': chatroomId,
    };
  }

  static WebsocketType? _websocketTypeFromString(String? typeStr) {
    if (typeStr == null) return null;
    return WebsocketType.values.firstWhere(
        (e) => e.name.toLowerCase() == typeStr.toLowerCase(),
        orElse: () => WebsocketType.CHAT); // default
  }
}
