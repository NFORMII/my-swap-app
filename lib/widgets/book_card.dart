import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../services/firestore_service.dart';
import '../providers/books_provider.dart';
import '../providers/swap_provider.dart';
import '../providers/auth_provider.dart';
import '../screens/chats/conversation_screen.dart';
import '../screens/profile/owner_profile_screen.dart';

class BookCard extends StatelessWidget {
  final Book book;
  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final swapProvider = context.read<SwapProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showDetailsSheet(context, swapProvider),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBookImage(context),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title.isNotEmpty ? book.title : 'Untitled',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // 👤 Owner Info
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirestoreService().getUserStream(book.ownerId),
                      builder: (context, snap) {
                        String displayName = book.ownerName.isNotEmpty
                            ? book.ownerName
                            : 'Anonymous';
                        String? photoUrl;

                        if (snap.hasData) {
                          final data = snap.data!.data() as Map<String, dynamic>?;
                          if (data != null) {
                            displayName = (data['displayName'] as String?) ??
                                displayName;
                            photoUrl = data['photoUrl'] as String?;
                          }
                        }

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    OwnerProfileScreen(userId: book.ownerId),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.grey[400],
                                backgroundImage: (photoUrl != null &&
                                        photoUrl.startsWith('http'))
                                    ? NetworkImage(photoUrl)
                                    : null,
                                child: (photoUrl == null)
                                    ? Text(
                                        _initials(displayName),
                                        style: const TextStyle(
                                            fontSize: 10, color: Colors.white),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '$displayName • ${book.condition.label}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),

                    Text(
                      _timeAgo(book.createdAt),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSwapButton(context, swapProvider),
                  const SizedBox(height: 8),
                  _buildChatButton(context),
                  const SizedBox(height: 8),
                  _buildDeleteButton(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ UI HELPERS ------------------

  Widget _buildBookImage(BuildContext context) {
    Widget imageWidget;

    if (book.imageUrl != null && book.imageUrl!.isNotEmpty) {
      final url = book.imageUrl!;
      if (url.startsWith('data:')) {
        try {
          final base64Data = url.split(',').last;
          final bytes = base64Decode(base64Data);
          imageWidget = Image.memory(
            bytes,
            width: 68,
            height: 96,
            fit: BoxFit.cover,
          );
        } catch (_) {
          imageWidget = const Icon(Icons.broken_image, size: 48);
        }
      } else {
        imageWidget = Image.network(
          url,
          width: 68,
          height: 96,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 48),
        );
      }
    } else {
      imageWidget = const Icon(Icons.menu_book, size: 48);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: imageWidget,
    );
  }

  Widget _buildSwapButton(BuildContext context, SwapProvider swapProvider) {
    return SizedBox(
      width: 90,
      child: ElevatedButton(
        onPressed: book.status == SwapStatus.available
            ? () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Swap'),
                    content:
                        Text('Send a swap request to ${book.ownerName}?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Send'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
                  final currentUserId = authProvider.currentUser?.uid;

                  if (currentUserId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('You must be signed in to swap')),
                    );
                    return;
                  }

                  final success = await swapProvider.initiateSwap(
                    bookId: book.id ?? '',
                    offeredBy: currentUserId,
                    offeredTo: book.ownerId,
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            success ? 'Swap request sent!' : 'Failed to send'),
                      ),
                    );
                  }
                }
              }
            : null,
        child: Text(
          book.status == SwapStatus.available
              ? 'Swap'
              : book.status.label.toUpperCase(),
        ),
      ),
    );
  }

  Widget _buildChatButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.chat_bubble_outline),
      onPressed: () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final currentUserId = authProvider.currentUser?.uid;

        if (currentUserId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign in to chat')),
          );
          return;
        }

        final peerId = book.ownerId;
        final chatId = FirestoreService().chatIdFor(currentUserId, peerId);
        final navigator = Navigator.of(context);

        await FirestoreService().ensureChatExists(chatId, [
          currentUserId,
          peerId,
        ]);

        navigator.push(
          MaterialPageRoute(
            builder: (_) => ConversationScreen(
              chatId: chatId,
              peerId: peerId,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.uid;

    if (currentUserId != book.ownerId) {
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
      onPressed: () async {
        final booksProv = Provider.of<BooksProvider>(context, listen: false);
        final messenger = ScaffoldMessenger.of(context);

        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete listing'),
            content: const Text(
                'Are you sure you want to delete this listing? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (confirmed != true) return;

        final success =
            await booksProv.deleteBook(book.id ?? '', book.imageUrl);
        if (context.mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(success
                  ? 'Listing deleted'
                  : (booksProv.error ?? 'Failed to delete')),
            ),
          );
        }
      },
    );
  }

  // ------------------ UTILS ------------------

  void _showDetailsSheet(BuildContext context, SwapProvider swapProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.title,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Author: ${book.author}'),
            Text('Condition: ${book.condition.label}'),
            Text('Owner: ${book.ownerName.isNotEmpty ? book.ownerName : "Anonymous"}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: book.status == SwapStatus.available
                  ? () async {
                      Navigator.pop(context);
                      await _buildSwapButton(context, swapProvider)
                          .onPressed
                          ?.call();
                    }
                  : null,
              child: const Text('Swap Now'),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}

extension on Widget {
  get onPressed => null;
}
