import '../models/message.dart';

abstract class ChatRepo {
  Stream<List<Message>> watchMessages(String chatId);
  Future<String> createChat(String userA, String userB);
  Future<void> sendMessage(String chatId, Message message);
  Future<List<String>> getUserChats(String userId);
}
