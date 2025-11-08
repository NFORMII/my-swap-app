import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/book.dart';
import '../../state/book_providers.dart';

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

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    setState(() => imageFile = picked);
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
                onTap: _pickImage,
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
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter a book title'
                    : null,
                onChanged: (v) => title = v,
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: author,
                decoration: const InputDecoration(labelText: 'Author'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter the author name'
                    : null,
                onChanged: (v) => author = v,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: condition,
                decoration: const InputDecoration(labelText: 'Condition'),
                items: ['New', 'Like New', 'Good', 'Used']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => condition = v!),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final repo = ref.read(bookRepoProvider);
                  final user = FirebaseAuth.instance.currentUser;

                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User not logged in')),
                    );
                    return;
                  }

                  try {
                    final book = Book(
                      id: '',
                      title: title.trim(),
                      author: author.trim(),
                      condition: condition,
                      ownerId: user.uid,
                      status: 'Available',
                      imageUrl: '',
                      createdAt: Timestamp.now(),
                      updatedAt: Timestamp.now(),
                    );

                    print('📘 Uploading book data: ${book.toJson()}');
                    await repo.createBook(book, imageFile);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('✅ Book added successfully!')),
                    );

                    if (context.mounted) Navigator.pop(context);
                  } catch (e, st) {
                    print('❌ Error adding book: $e');
                    print(st);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: Text(isEditing ? 'Update Book' : 'Add Book'),
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
