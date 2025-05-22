import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Color.fromARGB(255, 22, 25, 22),
        title: Text('Profile Page',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Image.asset('assets/images/app_logo.png'),
              Center(
                child: Text("This is Home Page", style: TextStyle(fontSize: 20)),
              ),
              Center(
                //   show the current logged in user email
                child: Text("Current User: ${FirebaseAuth.instance.currentUser!.email}", style: TextStyle(fontSize: 20)),
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: () async {
                print("Button is pressed");
                FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
                var sharedPref = await SharedPreferences.getInstance();
                sharedPref.setBool('login', false);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              }, child: Text("LogOut"))
            ],
          ),
        ],
      ),
    );
  }
}