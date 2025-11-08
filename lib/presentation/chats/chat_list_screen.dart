import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../state/chat_providers.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(chatRepoProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: FutureBuilder<List<String>>(
        future: repo.getUserChats(user!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final chatIds = snapshot.data!;
          if (chatIds.isEmpty) {
            return const Center(child: Text('No active chats.'));
          }
          return ListView.builder(
            itemCount: chatIds.length,
            itemBuilder: (_, i) {
              final id = chatIds[i];
              return ListTile(
                leading: const Icon(Icons.chat),
                title: Text('Chat ID: $id'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(chatId: id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
