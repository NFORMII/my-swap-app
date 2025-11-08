import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/book.dart';
import '../domain/repos/book_repo.dart';

class BookRepoFirebase implements BookRepo {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  /// 🔹 Fetch all available books (for the Browse tab)
  @override
  Stream<List<Book>> watchAllBooks() {
    return _db
        .collection('books')
        .where('status', isEqualTo: 'Available') // ✅ Only show available books
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((e) {
        })
        .map((snap) =>
            snap.docs.map((doc) => Book.fromJson(doc.data(), doc.id)).toList());
  }

  /// 🔹 Fetch only books owned by the current user (for My Listings)
  @override
  Stream<List<Book>> watchMyBooks(String ownerId) {
    return _db
        .collection('books')
        .where('status', isEqualTo: 'Available')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((e) {
        })
        .map((snap) =>
            snap.docs.map((doc) => Book.fromJson(doc.data(), doc.id)).toList());
  }

  /// 🔹 Create a new book listing with optional image upload
  @override
  Future<String> createBook(Book book, XFile? imageFile) async {
    final id = const Uuid().v4();
    String? imageUrl;

    if (imageFile != null) {
      final ref = _storage.ref('book_covers/${book.ownerId}/$id.jpg');
      await ref.putData(await imageFile.readAsBytes());
      imageUrl = await ref.getDownloadURL();
    }

    final newBook = book.copyWith(
      id: id,
      imageUrl: imageUrl ?? '',
      status: 'Available', // ✅ Set default status
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    await _db.collection('books').doc(id).set(newBook.toJson());
    return id;
  }

  /// 🔹 Update an existing book (with optional image replacement)
  @override
  Future<void> updateBook(Book book, XFile? newImageFile) async {
    String imageUrl = book.imageUrl;

    if (newImageFile != null) {
      final ref = _storage.ref('book_covers/${book.ownerId}/${book.id}.jpg');
      await ref.putData(await newImageFile.readAsBytes());
      imageUrl = await ref.getDownloadURL();
    }

    await _db.collection('books').doc(book.id).update({
      'title': book.title,
      'author': book.author,
      'condition': book.condition,
      'imageUrl': imageUrl,
      'updatedAt': Timestamp.now(),
    });
  }

  /// 🔹 Delete a book (and its cover image if exists)
  @override
  Future<void> deleteBook(String id, String ownerId) async {
    await _db.collection('books').doc(id).delete();
    try {
      await _storage.ref('book_covers/$ownerId/$id.jpg').delete();
    // ignore: empty_catches
    } catch (e) {
    }
  }
}
