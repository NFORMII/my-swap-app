import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/swap_providers.dart';
import '../../domain/models/swap.dart';

class MyOffersScreen extends ConsumerWidget {
  const MyOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final swaps = ref.watch(outgoingSwapsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Offers')),
      body: swaps.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No outgoing swap offers yet.'));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final s = list[i];
              return ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: Text('Book ID: ${s.bookId}'),
                subtitle: Text('Status: ${s.status}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
