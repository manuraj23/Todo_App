
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService{
  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<User?> signUpWithEmailAndPassword(String email, String pass) async{
    try{
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(email);
      await userDoc.set({
        'tasks': ["My Tasks"]
      });
      return credential.user;
    }
    catch(e){
      print("Some error occurred");
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(String email, String pass) async{
    try{
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: pass);
      return credential.user;
    }
    catch (e){
      print("Some error occurred");
    }
    return null;
  }

}