import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class FirebaseAuthService {
  static Future<(UserCredential?, FirebaseAuthException?)> createUser(
      {required String email, required String password}) async {
    try {
      final UserCredential credential =
          await _firebase.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return (credential, null);
    } on FirebaseAuthException catch (error) {
      // if(error.code == 'email-already-in-use'){
      //   ...
      // }

      return (null, error);
    }
  }

  static Future<(UserCredential?, FirebaseAuthException?)> loginUser(
      {required String email, required String password}) async {
    try {
      final UserCredential credential =
          await _firebase.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return (credential, null);
    } on FirebaseAuthException catch (error) {
      // if(error.code == 'email-already-in-use'){
      //   ...
      // }

      return (null, error);
    }
  }

  static Future<void> logOut() async {
    await _firebase.signOut();
  }
}
