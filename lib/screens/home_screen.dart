import 'package:eco_saver/screens/setting.dart';
import 'package:flutter/material.dart';
import 'package:eco_saver/screens/electricity.dart';
import 'package:eco_saver/screens/login_screen.dart';
import 'package:eco_saver/screens/water.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Future<Map<String, String>> _getUserDataFromPrefs() async {
    // Implement your logic to get user data from preferences
    // For now, returning an empty map
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 150, 196, 231),
      drawer: FutureBuilder<Map<String, String>>(
        future: _getUserDataFromPrefs(),
        builder: (context, AsyncSnapshot<Map<String, String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Drawer(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return Drawer(
              backgroundColor: Colors.white, // Set drawer background color to purple
              child: ListView(
                children: [
                  DrawerHeader(
                    child: Text(
                      'DASHBOARD',
                      style: TextStyle(
                        color: Colors.black, // Set text color to white
                        fontSize: 40,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[300], // Set header background color to purple
                    ),
                  ),
                /*  UserAccountsDrawerHeader(
                    accountName: Text(snapshot.data?['accountName'] ?? ''),
                    accountEmail: Text(snapshot.data?['accountEmail'] ?? ''),
                    decoration: BoxDecoration(
                      color: Colors.purple, // Set header background color to purple
                    ),
                  ),*/
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('Home'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Logout'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
      appBar: AppBar(
        title: Text('HOME'),
        backgroundColor: Color.fromARGB(255, 105, 178, 236),
        elevation: 0,
        actions: [
          PopupMenuButton<int>(
            onSelected: (item) => onSelected(context, item),
            icon: const Icon(Icons.person),
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 20),
                    const Text('Logout'),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildImageButton(
              'Water Monitoring',
              'assets/img_1.png',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WaterScreen(),
                  ),
                );
              },
            ),
            SizedBox(height: 80),
            _buildImageButton(
              'Electricity Monitoring',
              'assets/img.png',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ElectricityScreen(),
                  ),
                );
              },
            ),
          ],
        ),
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
            height: 200,
            width: 300,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: const Color.fromARGB(255, 8, 92, 157),
              fontSize: 25,
              fontWeight: FontWeight.bold, // Added fontWeight property
            ),
          ),
        ],
      ),
    );
  }

  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        break;
    }
  }
}
