import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_book_swap_app/state/auth_providers.dart';
import '../../domain/models/book.dart';
import '../../state/book_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookFormScreen extends ConsumerStatefulWidget {
  final Book? existingBook;
  const BookFormScreen({super.key, this.existingBook});

  @override
  ConsumerState<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends ConsumerState<BookFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  String title = '';
  String author = '';
  String condition = 'Good';
  XFile? imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.existingBook != null) {
      title = widget.existingBook!.title;
      author = widget.existingBook!.author;
      condition = widget.existingBook!.condition;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(bookControllerProvider.notifier);
    final state = ref.watch(bookControllerProvider);
    final isEditing = widget.existingBook != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Book' : 'Add Book')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: () async {
                  final picked = await picker.pickImage(source: ImageSource.gallery);
                  setState(() => imageFile = picked);
                },
                child: imageFile != null
                    ? Image.file(
                        File(imageFile!.path),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 180,
                        color: Colors.grey[200],
                        alignment: Alignment.center,
                        child: const Text('Tap to select image'),
                      ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Book Title'),
                onChanged: (v) => title = v,
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: author,
                decoration: const InputDecoration(labelText: 'Author'),
                onChanged: (v) => author = v,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: condition,
                decoration: const InputDecoration(labelText: 'Condition'),
                items: ['New', 'Like New', 'Good', 'Used']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => condition = v!),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final repo = ref.read(bookRepoProvider);
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;
                  final book = Book(
                    title: title.trim(),
                    author: author.trim(),
                    condition: condition,
                    ownerId: user.uid,
                    status: 'Available', id: '', imageUrl: '', createdAt: Timestamp.now(), updatedAt: Timestamp.now(),
                  );

                  await repo.createBook(book, imageFile);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Book added successfully!')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Add Book'),
              ),

              if (state is AsyncError)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    state.error.toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
