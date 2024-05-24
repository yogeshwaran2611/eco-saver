import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:eco_saver/screens/home_screen.dart';
import 'package:eco_saver/screens/reset_pass.dart';
import 'package:eco_saver/screens/signup_screen.dart';
import 'package:eco_saver/reusable_widgets/reusable_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.reference().child('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.1, 0.4, 0.7, 0.9],
            colors: [
              Color(0xFF35619B),
              Color.fromARGB(78, 85, 121, 169),
              Color.fromARGB(78, 79, 111, 152),
              Color.fromRGBO(113, 150, 193, 1.0),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "assets/logo.png",
                  height: 150.0,
                ),
                SizedBox(
                  height: 20.0,
                ),
                reusableTextField(
                  'enter email',
                  Icons.email,
                  false,
                  _emailTextController,
                ),
                SizedBox(
                  height: 20.0,
                ),
                reusableTextField(
                  'enter password',
                  Icons.lock,
                  true,
                  _passwordTextController,
                ),
                SizedBox(
                  height: 20.0,
                ),
                forgetPassword(context),
                LoginSignUpButton(context, 'login', () async {
                  // Get the entered email and password
                  String email = _emailTextController.text.trim();
                  String password = _passwordTextController.text.trim();

                  try {
                    // Check if the email exists in the database
                    var snapshot = await _databaseReference
                        .orderByChild('email')
                        .equalTo(email)
                        .once();

                    if (snapshot.snapshot.value != null) {
                      // Email found in the database
                      UserCredential userCredential =
                      await _auth.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      // Check if email is verified
                      if (userCredential.user?.emailVerified == true) {
                        // Navigate to HomeScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen()),
                        );
                      } else {
                        // Show a toast message or snackbar indicating that email is not verified
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Email not verified. Please verify your email.'),
                          ),
                        );
                      }
                    } else {
                      // Email not found in the database
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Email not registered. Sign up to login.'),
                        ),
                      );
                    }
                  } catch (error) {
                    // Handle login errors
                    print("Login Error: $error");
                    // Show a toast message or snackbar indicating login failure
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Incorrect password, try forget password.'),
                      ),
                    );
                  }
                }),
                signUpOption(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row signUpOption(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: Color.fromARGB(179, 8, 8, 8)),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignUpScreen()),
          ),
          child: const Text(
            " Sign Up",
            style: TextStyle(
              color: Color.fromARGB(255, 14, 13, 13),
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Color.fromARGB(179, 22, 19, 19)),
          textAlign: TextAlign.right,
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResetPassword()),
        ),
      ),
    );
  }
}
