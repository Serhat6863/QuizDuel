import 'package:firebase_auth/firebase_auth.dart';

class FirebaseUserService {
  // Implement Firebase user service methods here
  FirebaseAuth auth = FirebaseAuth.instance;

  //login with email and password
  Future<void> signInWithEmailAndPassword(String email, String password) async{
    try{
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("User signed in: ${userCredential.user?.email}");
    }on FirebaseAuthException catch(e){
      if(e.code == 'user-not-found'){
        print("No user found for that email.");
      }else if(e.code == 'wrong-password'){
        print("Wrong password provided for that user.");
      }else{
        print("Failed with error code : ${e.code} ");
        print(e.message);
      }
    }
  }

  //register with email and password

  Future<void> registerWithEmailAndPassword(String email, String password) async{
    try{
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("User registered: ${userCredential.user?.email}");
    }on FirebaseAuthException catch(e){
      if(e.code == 'weak-password'){
        print("The password provided is too weak.");
      }else if(e.code == 'email-already-in-use'){
        print("The account already exists for that email.");
      }else{
        print("Failed with error code : ${e.code} ");
        print(e.message);
      }
    }catch(e){
      print(e);
    }
  }

  //sign out
  Future<void> signOut() async{
    await auth.signOut();
    print("User signed out");
  }





}