import 'package:eco_saver/screens/data.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eco_saver/screens/home_screen.dart';
import 'package:eco_saver/screens/setting.dart';
import 'package:eco_saver/screens/water33.dart';
import 'package:eco_saver/screens/water22.dart';
import 'package:eco_saver/screens/login_screen.dart';

class WaterScreen extends StatefulWidget {
  const WaterScreen({Key? key}) : super(key: key);

  @override
  _WaterScreenState createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  double waterUsageGoal = 0.0;
  String accountName = '';
  String accountEmail = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists) {
          setState(() {
            accountName = userData['username'] as String? ?? '';
            accountEmail = userData['email'] as String? ?? '';
          });

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('accountName', accountName);
          await prefs.setString('accountEmail', accountEmail);
        } else {
          print('User data does not exist.');
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    } else {
      print('User is not signed in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 150, 196, 231),
      appBar: AppBar(
        title: Text('Water Monitoring'),
        backgroundColor: Color.fromARGB(255, 105, 178, 236),
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(left: 120.0, right: 20.0),
            child: Column(
              children: [
                _buildImageButton(
                  'Set Goal',
                  'assets/img_2.png',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WaterDataScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                _buildImageButton(
                  'Water Level',
                  'assets/water11.jpg',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WaterLevelScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                _buildImageButton(
                  'Water Usage',
                  'assets/water12.jpg',
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WaterUsageScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageButton(
      String label,
      String imagePath,
      VoidCallback onPressed,
      ) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Image.asset(
            imagePath,
            height: 150,
            width: 150,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: const Color.fromARGB(255, 8, 92, 157),
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, String>> _getUserDataFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accountName = prefs.getString('accountName');
    String? accountEmail = prefs.getString('accountEmail');
    return {'accountName': accountName ?? '', 'accountEmail': accountEmail ?? ''};
  }
}
