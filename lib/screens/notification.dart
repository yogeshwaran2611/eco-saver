import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Timer _timer;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    // Initialize Firebase Messaging
    _initFirebaseMessaging();

    // Schedule the timer to fetch water level every 15 minutes
    _timer = Timer.periodic(Duration(minutes: 15), (timer) {
      checkWaterLevel();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the screen is disposed
    _timer.cancel();
    super.dispose();
  }

  void _initFirebaseMessaging() {
    // Request permission for receiving notifications
    FirebaseMessaging.instance.requestPermission();

    // Configure Firebase Messaging
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle incoming messages when the app is in the foreground
      print("FCM Message received: ${message.notification?.body}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification tap when the app is in the background
      print("FCM Message opened from terminated state: ${message.notification?.body}");
    });
  }

  Future<double> fetchWaterLevel() async {
    final String url =
        'https://api.thingspeak.com/channels/2466820/fields/1/last.json?api_key=49G91KDXNAURA5NV';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return double.parse(jsonData['field1']);
    } else {
      throw Exception('Failed to load water level data');
    }
  }

  void checkWaterLevel() async {
    double waterLevel = await fetchWaterLevel();
    if (waterLevel < 40) {
      // Send FCM notification
      await _sendFcmNotification();
    }
  }

  Future<void> _sendFcmNotification() async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=YOUR_SERVER_KEY',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': 'Water level is below 40%!',
              'title': 'Water Level Alert',
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
            },
            'to': '/topics/all',
          },
        ),
      );
    } catch (e) {
      print('Error sending FCM notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: Center(
        child: Text('Notification Page Content'),
      ),
    );
  }
}
