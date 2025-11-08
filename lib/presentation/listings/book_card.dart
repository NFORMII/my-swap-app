import 'package:flutter/material.dart';
import '../../domain/models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSwap;

  const BookCard({
    super.key,
    required this.book,
    this.onEdit,
    this.onDelete,
    this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          if (book.imageUrl.isNotEmpty)
            Image.network(book.imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover)
          else
            Container(
              height: 160,
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported),
            ),
          ListTile(
            title: Text(book.title),
            subtitle: Text('${book.author} • ${book.condition}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
                if (onDelete != null)
                  IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
                if (onSwap != null)
                  IconButton(icon: const Icon(Icons.swap_horiz), onPressed: onSwap),
                  if (onSwap != null)
                  IconButton(
                    icon: const Icon(Icons.swap_horiz),
                    tooltip: 'Swap',
                    onPressed: onSwap,
                  ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
