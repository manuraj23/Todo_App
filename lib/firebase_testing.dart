import 'package:firebase_auth/firebase_auth.dart';

void checkFirebaseConnection() async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: 'test@example.com',
      password: 'testPassword123',
    );
    print('Firebase is fully connected. User created: ${userCredential.user?.uid}');
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('Password is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('Email is already in use.');
    } else {
      print('Error creating user: ${e.code}');
    }
  } catch (e) {
    print('Error: $e');
  }
}