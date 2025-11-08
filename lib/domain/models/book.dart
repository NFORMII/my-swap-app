import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String condition; // New, Like New, Good, Used
  final String imageUrl;
  final String ownerId;
  final String status; // Available, Pending, Swapped
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    required this.imageUrl,
    required this.ownerId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Book.fromJson(Map<String, dynamic> json, String id) {
    return Book(
      id: id,
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      condition: json['condition'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      ownerId: json['ownerId'] ?? '',
      status: json['status'] ?? 'Available',
      createdAt: json['createdAt'] ?? Timestamp.now(),
      updatedAt: json['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'condition': condition,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? condition,
    String? imageUrl,
    String? ownerId,
    String? status,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      condition: condition ?? this.condition,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
