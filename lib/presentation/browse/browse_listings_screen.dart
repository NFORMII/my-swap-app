import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_book_swap_app/presentation/listings/book_card.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/swap.dart';
import '../../state/book_providers.dart';
import '../../state/swap_providers.dart';

class BrowseListingsScreen extends ConsumerWidget {
  const BrowseListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(allBooksProvider);
    final _ = ref.watch(swapControllerProvider.notifier);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Browse Listings')),
      body: books.when(
        data: (list) {
          // Filter out the current user’s own books
          final available = list
              .where((b) => b.ownerId != user?.uid && b.status == 'Available')
              .toList();

          if (available.isEmpty) {
            return const Center(child: Text('No available books to swap.'));
          }

          return ListView.builder(
            itemCount: available.length,
            itemBuilder: (context, i) {
              final book = available[i];
              return BookCard(
                book: book,
                onSwap: () async {
                  // 👇 THIS is exactly where your code goes
                  final controller = ref.watch(swapControllerProvider.notifier);
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;

                  final swap = Swap(
                    id: const Uuid().v4(),
                    bookId: book.id,
                    senderId: user.uid,
                    receiverId: book.ownerId,
                    status: 'Pending',
                    createdAt: Timestamp.now(),
                    updatedAt: Timestamp.now(),
                  );

                  await controller.requestSwap(swap);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Swap request sent!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
