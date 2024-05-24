import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:eco_saver/reusable_widgets/reusable_widget.dart';
import 'package:eco_saver/screens/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();
  TextEditingController _mobilenumberTextController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 85, 132, 168),
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        constraints: BoxConstraints.expand(), // Ensure the container fills the screen
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.1, 0.4, 0.7, 0.8],
            colors: [
              Color(0xFF71ADDC),
              Color.fromARGB(255, 182, 215, 243),
              Color.fromARGB(255, 136, 179, 213),
              Color.fromRGBO(114, 179, 229, 1.0),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                  "Enter UserName",
                  Icons.person_outline,
                  false,
                  _userNameTextController,
                ),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                  "Mobile number",
                  Icons.phone,
                  false,
                  _mobilenumberTextController,
                ),

                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                  "Enter Email Id",
                  Icons.person_outline,
                  false,
                  _emailTextController,
                ),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField(
                  "Enter Password",
                  Icons.lock_outlined,
                  true,
                  _passwordTextController,
                ),
                const SizedBox(
                  height: 20,
                ),
                LoginSignUpButton(context, 'Sign Up', () async {
                  try {
                    // Create a new user with email and password
                    UserCredential userCredential =
                    await _auth.createUserWithEmailAndPassword(
                      email: _emailTextController.text,
                      password: _passwordTextController.text,
                    );

                    // Upload user information to Firebase Realtime Database
                    await _database
                        .child("users")
                        .child(userCredential.user!.uid)
                        .set({
                      "username": _userNameTextController.text,
                      "email": _emailTextController.text,
                      "mobilenumber": _mobilenumberTextController
                          .text, // Fixed here
                    });

                    // Send email verification
                    await userCredential.user!.sendEmailVerification();

                    // Navigate to home screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  } catch (error) {
                    print("Error: $error");
                    if (error is FirebaseAuthException &&
                        error.code == 'email-already-in-use') {
                      // Handle the specific error when email is already in use
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "The email address is already in use by another account."),
                        ),
                      );
                    } else {
                      // Handle other errors
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                          Text("An error occurred. Please try again later."),
                        ),
                      );
                    }
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
