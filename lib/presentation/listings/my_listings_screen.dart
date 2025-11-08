import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/book_providers.dart';
import '../../domain/models/book.dart';
import 'book_card.dart';
import 'book_form_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(myBooksProvider);
    final controller = ref.watch(bookControllerProvider.notifier);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Listings')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: books.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No listings yet.'));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final b = list[i];
              return BookCard(
                book: b,
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookFormScreen(existingBook: b),
                  ),
                ),
                onDelete: () async {
                  await controller.deleteBook(b.id, user!.uid);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
