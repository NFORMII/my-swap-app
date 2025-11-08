import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/swap_providers.dart';

class IncomingOffersScreen extends ConsumerWidget {
  const IncomingOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final swaps = ref.watch(incomingSwapsProvider);
    final controller = ref.watch(swapControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Incoming Swap Requests')),
      body: swaps.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No incoming swap offers.'));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final s = list[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.handshake),
                  title: Text('Book ID: ${s.bookId}'),
                  subtitle: Text('Status: ${s.status}'),
                  trailing: s.status == 'Pending'
                      ? Wrap(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () async =>
                                  await controller.updateSwapStatus(
                                      s.id, 'Accepted'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () async =>
                                  await controller.updateSwapStatus(
                                      s.id, 'Rejected'),
                            ),
                          ],
                        )
                      : null,
                ),
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
