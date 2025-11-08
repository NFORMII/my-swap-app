import '../models/swap.dart';

abstract class SwapRepo {
  Stream<List<Swap>> watchOutgoing(String senderId);
  Stream<List<Swap>> watchIncoming(String receiverId);
  Future<void> requestSwap(Swap swap);
  Future<void> updateSwapStatus(String swapId, String status);
}
