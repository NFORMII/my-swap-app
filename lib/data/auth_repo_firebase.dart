import 'package:firebase_auth/firebase_auth.dart';
import '../domain/repos/auth_repo.dart';

class AuthRepoFirebase implements AuthRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  @override
  Future<UserCredential> signUp(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.sendEmailVerification();
    return credential;
  }

  @override
  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
