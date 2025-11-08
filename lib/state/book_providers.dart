import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/models/book.dart';
import '../data/book_repo_firebase.dart';
import '../domain/repos/book_repo.dart';
import 'package:image_picker/image_picker.dart';

final bookRepoProvider = Provider<BookRepo>((ref) {
  return BookRepoFirebase();
});


// final bookRepoProvider = Provider<BookRepo>((_) => BookRepoFirebase());

final allBooksProvider = StreamProvider<List<Book>>(
  (ref) => ref.watch(bookRepoProvider).watchAllBooks(),
);

final myBooksProvider = StreamProvider<List<Book>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();
  return ref.watch(bookRepoProvider).watchMyBooks(user.uid);
});

final bookControllerProvider =
    StateNotifierProvider<BookController, AsyncValue<void>>(
        (ref) => BookController(ref));

class BookController extends StateNotifier<AsyncValue<void>> {
  final Ref _read;
  BookController(this._read) : super(const AsyncData(null));

  Future<void> addBook(Book book, XFile? file) async {
    state = const AsyncLoading();
    try {
      await _read.createBook(book, file);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateBook(Book book, XFile? file) async {
    state = const AsyncLoading();
    try {
      await _read.updateBook(book, file);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteBook(String id, String ownerId) async {
    await _read.deleteBook(id, ownerId);
  }
}

extension on Ref<Object?> {
  Future<void> createBook(Book book, XFile? file) async {}
  
  Future<void> deleteBook(String id, String ownerId) async {}
  
  Future<void> updateBook(Book book, XFile? file) async {}
}




// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../domain/models/book.dart';
// import '../data/book_repo_firebase.dart';
// import '../domain/repos/book_repo.dart';
// import 'package:image_picker/image_picker.dart';

// final bookRepoProvider = Provider<BookRepo>((_) => BookRepoFirebase());

// final allBooksProvider = StreamProvider<List<Book>>(
//   (ref) => ref.watch(bookRepoProvider).watchAllBooks(),
// );

// final myBooksProvider = StreamProvider<List<Book>>((ref) {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) return const Stream.empty();
//   return ref.watch(bookRepoProvider).watchMyBooks(user.uid);
// });

// final bookControllerProvider =
//     StateNotifierProvider<BookController, AsyncValue<void>>(
//         (ref) => BookController(ref)
//         );

// class BookController extends StateNotifier<AsyncValue<void>> {
//   final Ref _ref;
//   BookController(this._ref) : super(const AsyncData(null));

//   Future<void> addBook(Book book, XFile? file) async {
//     state = const AsyncLoading();
//     try {
//       await _ref.read(bookRepoProvider).createBook(book, file);
//       state = const AsyncData(null);
//     } catch (e, st) {
//       state = AsyncError(e, st);
//     }
//   }

//   Future<void> updateBook(Book book, XFile? file) async {
//     state = const AsyncLoading();
//     try {
//       await _ref.read(bookRepoProvider).updateBook(book, file);
//       state = const AsyncData(null);
//     } catch (e, st) {
//       state = AsyncError(e, st);
//     }
//   }

//   Future<void> deleteBook(String id, String ownerId) async {
//     await _ref.read(bookRepoProvider).deleteBook(id, ownerId);
//   }
// }
