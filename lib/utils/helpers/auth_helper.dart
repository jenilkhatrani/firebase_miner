import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthHelper {
  AuthHelper._();
  static final AuthHelper authHelper = AuthHelper._();
  static final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static final GoogleSignIn googleSignIn = GoogleSignIn();

  // sign up user

  Future<Map<String, dynamic>> signUpUser(
      {required String email, required String password}) async {
    Map<String, dynamic> response = {};
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      response['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "admin-restricted-operation":
          response['error'] = "this service is disabled by admin right now.";
        case "email-already-in-use":
          response['error'] = "password must be minimum 6 characters";
        default:
          response['error'] = e.code;
      }
    }
    return response;
  }

// sign in user

  Future<Map<String, dynamic>> signInUser(
      {required String email, required String password}) async {
    Map<String, dynamic> response = {};
    try {
      UserCredential userCrendential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      User? user = userCrendential.user;

      response['user'] = user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "admin-restricted-operation":
          response['error'] = "this services in disabled by admin right now";
        case "invalid-credential":
          response['error'] = "Invalid email or password";
        default:
          response['error'] = e.code;
      }
    }
    return response;
  }

  Future<void> sighOutUser() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
  }

// google

  Future<Map<String, dynamic>> signInGoogle() async {
    Map<String, dynamic> response = {};
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);
      User? user = userCredential.user;
      response['user'] = user;
    } catch (e) {
      response['error'] = "$e";
    }
    return response;
  }

  Future<Map<String, dynamic>> anonymousLogin() async {
    Map<String, dynamic> response = {};

    try {
      UserCredential? userCredential = await firebaseAuth.signInAnonymously();

      User? user = userCredential.user;
      response['user'] = user;
    } on FirebaseAuthException catch (e) {
      if (e.code == "admin-restricted-operation") {
        response['error'] = "this services is disabled by admin right now";
      } else {
        response['error'] = e.code;
      }
    }
    return response;
  }
}
