import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/signup.dart';
import 'auth_services.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  var emailText = TextEditingController();
  var passText = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailText.dispose();
    passText.dispose();
  }

  Future<bool> _signIn() async {
    String email = emailText.text;
    String pass = passText.text;

    var sharedPref = await SharedPreferences.getInstance();

    User? user = await _auth.signInWithEmailAndPassword(email, pass);
    if (user != null) {
      print("User is created");
      sharedPref.setBool('login', true);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
      return true;
    } else {
      print("Some error happened");
      return false;
    }
  }

  signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final AuthCredential googleAuthCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(googleAuthCredential);
      final User? user = userCredential.user;
      print("User: $user");
      var sharedPref = await SharedPreferences.getInstance();
      if (user != null) {
        DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email);
        await userDoc.set({
          'tasks': FieldValue.arrayUnion(["My Tasks"])
        }, SetOptions(merge: true));
        print("User is created");
        sharedPref.setBool('login', true);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        print("Some error happened");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text('Flutter Demo Home Page'),
      //
      // ),
      // body: Container(
      //   color: Colors.grey[900],
      //   child: Center(
      //     child: Container(
      //       width: 300,
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           TextField(
      //             controller: emailText,
      //             decoration: InputDecoration(
      //               border: OutlineInputBorder(
      //                 borderRadius: BorderRadius.circular(12),
      //                 borderSide: const BorderSide(
      //                   color: Colors.red,
      //                   width: 2,
      //                 ),
      //               ),
      //               labelText: 'Enter your username',
      //             ),
      //           ),
      //           SizedBox(height: 20),
      //           TextField(
      //             controller: passText,
      //             decoration: InputDecoration(
      //               border: OutlineInputBorder(
      //                 borderRadius: BorderRadius.circular(12),
      //                 borderSide: const BorderSide(
      //                   color: Colors.red,
      //                   width: 2,
      //                 ),
      //               ),
      //               labelText: 'Enter your password',
      //             ),
      //           ),
      //           SizedBox(height: 20),
      //           ElevatedButton(
      //             onPressed: () async {
      //               print('Email: ${emailText.text}');
      //               print('Password: ${passText.text}');
      //               if(await _signIn() == false){
      //                 ScaffoldMessenger.of(context).showSnackBar(
      //                   SnackBar(content: Text("Either email or password is incorrect")),
      //                   );
      //               }
      //               else{
      //                 ScaffoldMessenger.of(context).showSnackBar(
      //                   SnackBar(content: Text("Login Successful")),
      //                   );
      //               }
      //             },
      //             child: const Text('Login'),
      //           ),
      //           ElevatedButton(
      //             onPressed: () {
      //               print("Google SignIn");
      //               signInWithGoogle();
      //             },
      //             child: Text("Google SignIn"),
      //           ),
      //           ElevatedButton(
      //             onPressed: () {
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(builder: (context) => Signup_page()),
      //               );
      //             },
      //             child: Text("SignUp"),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(''),
        // backgroundColor: Colors.white,
        automaticallyImplyLeading: false, // Removes the back arrow
      ),
      body: Center(
        child: Container(
          color: Colors.grey[900],
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width*0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/login_page_icon.png',
                    // width: MediaQuery.of(context).size.width * 0.6,
                  ),
                  SizedBox(height: 20),
                  Text("Welcome to Tasks",
                  style: TextStyle(
                    fontSize: 23,
                    color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("Keep track of important things that you need to get done in one place",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      // print("login button is pressed");
                      print("Google SignIn");
                      signInWithGoogle();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withAlpha(100),
                    ),
                    child: Text('Get Started',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                    ),
                  ),
                  SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}