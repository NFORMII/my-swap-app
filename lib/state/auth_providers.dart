import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/auth_repo_firebase.dart';
import '../domain/repos/auth_repo.dart';

final authRepoProvider = Provider<AuthRepo>((_) => AuthRepoFirebase());

final authStateChangesProvider =
    StreamProvider<User?>((ref) => ref.read(authRepoProvider).authStateChanges());

final isVerifiedProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  return user != null && user.emailVerified;
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>(
        (ref) => AuthController(ref));

class AuthController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  AuthController(this._ref) : super(const AsyncData(null));

  Future<void> signUp(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _ref.read(authRepoProvider).signUp(email, password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _ref.read(authRepoProvider).signIn(email, password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signOut() async {
    await _ref.read(authRepoProvider).signOut();
  }
}
