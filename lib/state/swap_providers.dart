import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_book_swap_app/domain/models/swap_repo.dart';
import '../domain/models/swap.dart';
import '../data/swap_repo_firebase.dart';


final swapRepoProvider = Provider<SwapRepo>((_) => SwapRepoFirebase());

final outgoingSwapsProvider = StreamProvider<List<Swap>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();
  return ref.watch(swapRepoProvider).watchOutgoing(user.uid);
});

final incomingSwapsProvider = StreamProvider<List<Swap>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();
  return ref.watch(swapRepoProvider).watchIncoming(user.uid);
});

final swapControllerProvider =
    StateNotifierProvider<SwapController, AsyncValue<void>>(
        (ref) => SwapController(ref));

class SwapController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  SwapController(this._ref) : super(const AsyncData(null));

  Future<void> requestSwap(Swap swap) async {
    state = const AsyncLoading();
    try {
      await _ref.read(swapRepoProvider).requestSwap(swap);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateSwapStatus(String id, String status) async {
    await _ref.read(swapRepoProvider).updateSwapStatus(id, status);
  }
}
