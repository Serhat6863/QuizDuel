import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizduel/features/auth/data/model/user_model.dart';

class FirebaseUserService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // login with email and password
  Future<UserModel?> signInWithEmailAndPassword(
      String email,
      String password,
      ) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Récupère les infos Firestore pour avoir username, score, etc
        final doc = await firestore.collection("users").doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromJson(doc.data() as Map<String, dynamic>);
        }

        // fallback
        return UserModel(
          id: user.uid,
          email: user.email ?? '',
          username: user.displayName ?? '',
          isReady: false,
          score: 0,
        );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    }
  }

  // register
  Future<UserModel?> registerWithEmailAndPassword(
      String email,
      String username,
      String password,
      ) async {
    try {
      UserCredential userCredential =
      await auth.createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.updateDisplayName(username);

      final user = userCredential.user;
      if (user == null) return null;

      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        username: username,
        isReady: false,
        score: 0,
      );

      await firestore.collection('users').doc(user.uid).set(userModel.toJson());
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    }
  }

  // sign out
  Future<void> signOut() async {
    await auth.signOut();
  }

  // get current user
  Future<UserModel?> getCurrentUser() async {
    final user = auth.currentUser;
    if (user != null) {
      final doc = await firestore.collection("users").doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        username: user.displayName ?? '',
        isReady: false,
        score: 0,
      );
    }
    return null;
  }

  // get username by id
  Future<String> getUsernameById(String userId) async {
    try {
      final doc = await firestore.collection("users").doc(userId).get();
      if (doc.exists) {
        return doc.data()?["username"] ?? "";
      } else {
        throw Exception("User not found");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return "No user found for that email.";
      case 'wrong-password':
        return "Wrong password provided for that user.";
      case 'weak-password':
        return "The password provided is too weak.";
      case 'email-already-in-use':
        return "The account already exists for that email.";
      default:
        return "Authentication failed. Please try again. ${e.message}";
    }
  }
}
