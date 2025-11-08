import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_book_swap_app/domain/models/swap_repo.dart';
import '../domain/models/swap.dart';

class SwapRepoFirebase implements SwapRepo {
  final _db = FirebaseFirestore.instance;

  @override
  Stream<List<Swap>> watchOutgoing(String senderId) {
    return _db
        .collection('swaps')
        .where('senderId', isEqualTo: senderId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Swap.fromJson(d.data(), d.id)).toList());
  }

  @override
  Stream<List<Swap>> watchIncoming(String receiverId) {
    return _db
        .collection('swaps')
        .where('receiverId', isEqualTo: receiverId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Swap.fromJson(d.data(), d.id)).toList());
  }

  @override
  Future<void> requestSwap(Swap swap) async {
    final ref = _db.collection('swaps').doc(swap.id);
    final batch = _db.batch();

    batch.set(ref, swap.toJson());
    final bookRef = _db.collection('books').doc(swap.bookId);
    batch.update(bookRef, {'status': 'Pending', 'updatedAt': Timestamp.now()});

    await batch.commit();
  }

  @override
  Future<void> updateSwapStatus(String swapId, String status) async {
    final ref = _db.collection('swaps').doc(swapId);
    final doc = await ref.get();
    if (!doc.exists) return;

    final swap = Swap.fromJson(doc.data()!, doc.id);
    final batch = _db.batch();
    batch.update(ref, {'status': status, 'updatedAt': Timestamp.now()});
    batch.update(_db.collection('books').doc(swap.bookId), {
      'status': status == 'Accepted' ? 'Swapped' : 'Available',
      'updatedAt': Timestamp.now(),
    });
    await batch.commit();
  }
}
