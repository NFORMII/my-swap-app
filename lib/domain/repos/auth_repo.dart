import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepo {
  Stream<User?> authStateChanges();
  Future<UserCredential> signUp(String email, String password);
  Future<UserCredential> signIn(String email, String password);
  Future<void> sendEmailVerification();
  Future<void> signOut();
}
