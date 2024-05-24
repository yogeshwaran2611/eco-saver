import 'package:eco_saver/reusable_widgets/reusable_widget.dart';
import 'package:eco_saver/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController _emailTextController = TextEditingController();

  void resetPassword(BuildContext context) async {
    final String email = _emailTextController.text.trim();

    try {
      // Check if the email exists in the database
      DatabaseEvent snapshot = await FirebaseDatabase.instance
          .reference()
          .child('users')
          .orderByChild('email')
          .equalTo(email)
          .once();

      if (snapshot.snapshot.value != null) {
        // Email exists in the database, send reset password link
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset link sent to $email'),
          ),
        );
      } else {
        // Email does not exist in the database
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email not registered. Please sign up.'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again later.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 85, 132, 168),
        elevation: 0,
        title: const Text(
          "Reset Password",
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
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).size.height * 0.2,
            20,
            0,
          ),
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              reusableTextField(
                'enter email',
                Icons.person_2_outlined,
                false,
                _emailTextController,
              ),
              SizedBox(height: 20.0),
              LoginSignUpButton(context, 'reset password', () {
                resetPassword(context);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
