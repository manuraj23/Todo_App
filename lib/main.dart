import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/firebase_testing.dart';
import 'package:todo_app/login.dart';
import 'package:todo_app/signup.dart';
import 'package:todo_app/home_page.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyD_gPGdop-ECO1wpp4mkdcsmf6HZ4Va8lQ",
          authDomain: "todo-with-sync.firebaseapp.com",
          projectId: "todo-with-sync",
          storageBucket: "todo-with-sync.appspot.com",
          messagingSenderId: "122887292381",
          appId: "1:122887292381:web:6bbcfe82d2982ff3c6e234",
          measurementId: "G-D9JM1M2633"
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var emailText = TextEditingController();
  var passText = TextEditingController();

  static const String KEYLOGIN = 'login';

  void whereToGo() async {
    var sharedPref = await SharedPreferences.getInstance();
    var isLoggedIn = sharedPref.getBool(KEYLOGIN);
    if (isLoggedIn != null && isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    whereToGo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(''),
        automaticallyImplyLeading: false, // Removes the back arrow
      ),
      body: Container(
        width: double.infinity,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: double.infinity,
          color: Colors.grey[900],
          child: Center(
            child: Container(
              // width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 100),
                  SvgPicture.asset(
                    'assets/images/logo_tasks_2021_64dp.svg', // Path to your SVG asset
                    width: 150, // Set the width of the SVG image
                    height: 150, // Set the height of the SVG image
                  ),
                  SizedBox(height: 300),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Google",
                        style: GoogleFonts.afacad(
                          textStyle: TextStyle(color: Colors.white,fontSize: 40.0,fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text("Workspace",
                        style: GoogleFonts.afacad(
                          textStyle: TextStyle(color: Colors.white,fontSize: 40.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}