import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/home_page.dart';
import 'package:todo_app/login.dart';
import 'auth_services.dart';

class Signup_page extends StatefulWidget {
  const Signup_page({super.key});

  @override
  State<Signup_page> createState() => _SignupState();
}

class _SignupState extends State<Signup_page> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  var nameText = TextEditingController();
  var emailText = TextEditingController();
  var passText = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameText.dispose();
    emailText.dispose();
    passText.dispose();
  }

  Future<bool> _signup() async {
    String name = nameText.text;
    String email = emailText.text;
    String pass = passText.text;

    User? user = await _auth.signUpWithEmailAndPassword(email, pass);
    if (user != null) {
      print("User is created");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Flutter Demo Home Page'),
      ),
      body: Center(
        child: Container(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: nameText,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                  labelText: 'Enter your Name',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailText,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                  labelText: 'Enter your username',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passText,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                  labelText: 'Enter your password',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if(await _signup() == false){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Enter valid email and password min 6 characters")),
                    );
                  }
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Signup Successful")),
                    );
                  }
                },
                child: const Text('SignUp'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}