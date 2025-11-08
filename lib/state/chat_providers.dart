import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/models/message.dart';
import '../data/chat_repo_firebase.dart';
import '../domain/repos/chat_repo.dart';

final chatRepoProvider = Provider<ChatRepo>((_) => ChatRepoFirebase());

final chatMessagesProvider =
    StreamProvider.family<List<Message>, String>((ref, chatId) {
  return ref.watch(chatRepoProvider).watchMessages(chatId);
});

final chatControllerProvider =
    StateNotifierProvider<ChatController, AsyncValue<void>>(
        (ref) => ChatController(ref));

class ChatController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  ChatController(this._ref) : super(const AsyncData(null));

  Future<String> startChat(String userB) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not logged in');
    return _ref.read(chatRepoProvider).createChat(user.uid, userB);
  }

  Future<void> sendMessage(String chatId, String text) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || text.trim().isEmpty) return;
    final msg = Message(
      id: '',
      chatId: chatId,
      senderId: user.uid,
      text: text,
      sentAt: Timestamp.now(),
    );
    await _ref.read(chatRepoProvider).sendMessage(chatId, msg);
  }
}
