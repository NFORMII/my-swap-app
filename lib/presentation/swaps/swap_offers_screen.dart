import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/book.dart';
import '../../../state/book_providers.dart';

class SwapOffersScreen extends ConsumerWidget {
  const SwapOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to view swap offers.'));
    }

    final mySwapsStream = FirebaseFirestore.instance
        .collection('swaps')
        .where('senderId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();

    final incomingSwapsStream = FirebaseFirestore.instance
        .collection('swaps')
        .where('receiverId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Swap Offers'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Offers'),
              Tab(text: 'Incoming Offers'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SwapList(stream: mySwapsStream, isSender: true),
            _SwapList(stream: incomingSwapsStream, isSender: false),
          ],
        ),
      ),
    );
  }
}

class _SwapList extends ConsumerWidget {
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final bool isSender;

  const _SwapList({required this.stream, required this.isSender});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              isSender
                  ? 'You have not made any swap offers.'
                  : 'No incoming swap offers.',
            ),
          );
        }

        final swaps = snapshot.data!.docs;

        return ListView.builder(
          itemCount: swaps.length,
          itemBuilder: (context, index) {
            final swap = swaps[index].data();
            final status = (swap['status'] as String?) ?? 'Pending';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.compare_arrows, color: Colors.deepPurple),
                title: Text('Book ID: ${swap['bookId']}'),
                subtitle: Text(
                  'Status: $status\nFrom: ${swap['senderId']}\nTo: ${swap['receiverId']}',
                ),
                trailing: isSender
                    ? Text(
                        status,
                        style: TextStyle(
                          color: status == 'Pending'
                              ? Colors.orange
                              : (status == 'Accepted'
                                  ? Colors.green
                                  : Colors.red),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (status == 'Pending') ...[
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              tooltip: 'Accept',
                              onPressed: () async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('swaps')
                                      .doc(swaps[index].id)
                                      .update({'status': 'Accepted'});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Swap accepted')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to accept swap: $e')),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              tooltip: 'Reject',
                              onPressed: () async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('swaps')
                                      .doc(swaps[index].id)
                                      .update({'status': 'Rejected'});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Swap rejected')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to reject swap: $e')),
                                  );
                                }
                              },
                            ),
                          ] else
                            Text(
                              status,
                              style: TextStyle(
                                color: status == 'Accepted'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
