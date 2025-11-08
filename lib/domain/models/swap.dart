import 'package:cloud_firestore/cloud_firestore.dart';

class Swap {
  final String id;
  final String bookId;
  final String senderId;
  final String receiverId;
  final String status; // Pending | Accepted | Rejected
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Swap({
    required this.id,
    required this.bookId,
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Swap.fromJson(Map<String, dynamic> json, String id) {
    return Swap(
      id: id,
      bookId: json['bookId'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      status: json['status'] ?? 'Pending',
      createdAt: json['createdAt'] ?? Timestamp.now(),
      updatedAt: json['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'bookId': bookId,
        'senderId': senderId,
        'receiverId': receiverId,
        'status': status,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  Swap copyWith({
    String? id,
    String? status,
    Timestamp? updatedAt,
  }) {
    return Swap(
      id: id ?? this.id,
      bookId: bookId,
      senderId: senderId,
      receiverId: receiverId,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
