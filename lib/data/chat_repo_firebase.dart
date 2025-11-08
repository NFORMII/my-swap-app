import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/message.dart';
import '../domain/repos/chat_repo.dart';

class ChatRepoFirebase implements ChatRepo {
  final _db = FirebaseFirestore.instance;

  @override
  Future<String> createChat(String userA, String userB) async {
    final existing = await _db
        .collection('chats')
        .where('participants', arrayContains: userA)
        .get();

    for (var doc in existing.docs) {
      final participants = List<String>.from(doc['participants']);
      if (participants.contains(userB)) {
        return doc.id; // chat already exists
      }
    }

    final id = const Uuid().v4();
    await _db.collection('chats').doc(id).set({
      'participants': [userA, userB],
      'lastMessage': '',
      'updatedAt': Timestamp.now(),
    });
    return id;
  }

  @override
  Stream<List<Message>> watchMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Message.fromJson(d.data(), d.id)).toList());
  }

  @override
  Future<void> sendMessage(String chatId, Message message) async {
    final msgRef =
        _db.collection('chats').doc(chatId).collection('messages').doc();
    await msgRef.set(message.toJson());
    await _db.collection('chats').doc(chatId).update({
      'lastMessage': message.text,
      'updatedAt': Timestamp.now(),
    });
  }

  @override
  Future<List<String>> getUserChats(String userId) async {
    final snap = await _db
        .collection('chats')
        .where('participants', arrayContains: userId)
        .get();
    return snap.docs.map((d) => d.id).toList();
  }
}
