import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizduel/core/utils/logger.dart';
import 'package:quizduel/features/auth/data/model/user_model.dart';

import '../../../../core/error/app_failure.dart';

class FirebaseUserService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 🔹 Connexion Firebase (sign in)
  Future<UserModel?> signInWithEmailAndPassword(
      String email,
      String password,
      ) async {
    try {
      final deviceId = await _getDeviceId();

      // 🔹 Connexion via Firebase Auth
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) return null;

      final userDoc = firestore.collection("users").doc(user.uid);
      final docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        final isOnline = data["isOnline"] ?? false;
        final lastDeviceId = data["deviceId"] ?? "";


        if (isOnline && lastDeviceId != deviceId) {
          await auth.signOut();
          throw AppFailure(message: "User already logged in on another device.", code: "user-already-logged-in");
        }

        // Met à jour l'état connecté
        await userDoc.update({
          "isOnline": true,
          "deviceId": deviceId,
        });

        return UserModel.fromJson(data);
      } else {
        final newUser = UserModel(
          id: user.uid,
          email: user.email ?? '',
          username: user.displayName ?? '',
          isReady: false,
          score: 0,
          isOnline: true,
          deviceId: deviceId,
        );

        await userDoc.set(newUser.toJson());
        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      throw AppFailure(message: _mapFirebaseError(e), code: e.code);
    }
  }


  // 🔹 Inscription
  Future<UserModel?> registerWithEmailAndPassword(
      String email,
      String username,
      String password,
      ) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) return null;

      await user.updateDisplayName(username);


      if(user.email != null){
        throw AppFailure(message: "this email is already in use", code: "email-already-in-use");
      }

      // 🔸 Envoi de l’email de vérification
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        logger.d("Verification email sent to $email");
      }

      // 🔸 Pas encore en ligne à l’inscription

      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        username: username,
        isReady: false,
        score: 0,
        isOnline: false, // ✅ reste false
        deviceId: "", // ✅ vide au départ
      );

      await firestore.collection("users").doc(user.uid).set(userModel.toJson());
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AppFailure(message: _mapFirebaseError(e), code: e.code);
    }
  }

  // 🔹 Déconnexion
  Future<void> signOut() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        // 🔸 On marque l'utilisateur comme hors ligne
        await firestore.collection("users").doc(user.uid).update({
          "isOnline": false,
          "deviceId": "",
        });
      }
      await auth.signOut();
    } catch (e) {
      logger.e("Error during sign out: $e");
      throw Exception("Error during sign out: $e");
    }
  }

  // 🔹 Récupération de l’utilisateur courant
  Future<UserModel?> getCurrentUser() async {
    final user = auth.currentUser;
    if (user == null) return null;

    final doc = await firestore.collection("users").doc(user.uid).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // 🔹 Obtenir un username via ID
  Future<String> getUsernameById(String userId) async {
    final doc = await firestore.collection("users").doc(userId).get();
    if (!doc.exists) throw Exception("User not found");
    return doc.data()?["username"] ?? "";
  }

  // 🔹 Récupérer tous les utilisateurs
  Future<List<UserModel>> getAllUsers() async {
    final querySnapshot = await firestore.collection("users").get();
    return querySnapshot.docs.map((d) => UserModel.fromJson(d.data())).toList();
  }

  // 🔹 Mettre à jour le score
  Future<void> updateScore(String userId, int newScore) async {
    await firestore.collection("users").doc(userId).update({
      "score": newScore,
    });
  }

  // 🔹 Vérifier si email est validé
  Future<bool> checkEmailVerified() async {
    final user = auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return user.emailVerified;
  }

  // 🔹 Renvoyer un mail de vérification
  Future<void> resentEmailVerification() async {
    final user = auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // 🔹 Supprimer un compte
  Future<void> deleteAccount() async {
    final user = auth.currentUser;
    if (user == null) return;

    await firestore.collection("users").doc(user.uid).delete();
    await user.delete();
  }

  // 🔹 Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  // 🔹 Récupération du deviceId
  Future<String> _getDeviceId() async {
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final android = await info.androidInfo;
      return android.id ?? 'unknown_android';
    } else if (Platform.isIOS) {
      final ios = await info.iosInfo;
      return ios.identifierForVendor ?? 'unknown_ios';
    }
    return 'unknown_device';
  }

  // 🔹 Gestion des erreurs Firebase
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return "No user found for that email.";
      case 'wrong-password':
        return "Wrong password provided.";
      case 'weak-password':
        return "Password is too weak.";
      case 'email-already-in-use':
        return "Account already exists for that email.";
      default:
        return "Authentication failed: ${e.message}";
    }
  }
}
