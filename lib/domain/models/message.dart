import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final Timestamp sentAt;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });

  factory Message.fromJson(Map<String, dynamic> json, String id) {
    return Message(
      id: id,
      chatId: json['chatId'] ?? '',
      senderId: json['senderId'] ?? '',
      text: json['text'] ?? '',
      sentAt: json['sentAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'chatId': chatId,
        'senderId': senderId,
        'text': text,
        'sentAt': sentAt,
      };
}
