import 'dart:developer';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

final GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
  'email',
]);

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;
  Stream<User?> userStream = FirebaseAuth.instance.authStateChanges();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      final GoogleSignInAuthentication googleAuth =
          await googleSignInAccount!.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      await firebaseAuth.signInWithCredential(credential);
      user = firebaseAuth.currentUser;
      return user;
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  Future<void> signInAnonymous() async {
    try {
      await firebaseAuth.signInAnonymously();
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } on Exception catch (e) {
      log(e.toString());
    }
  }

}
