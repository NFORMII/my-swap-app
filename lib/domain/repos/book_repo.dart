import '../models/book.dart';
import 'package:image_picker/image_picker.dart';

abstract class BookRepo {
  Stream<List<Book>> watchAllBooks();
  Stream<List<Book>> watchMyBooks(String ownerId);
  Future<String> createBook(Book book, XFile? imageFile);
  Future<void> updateBook(Book book, XFile? newImageFile);
  Future<void> deleteBook(String id, String ownerId);
}
