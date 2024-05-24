import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WaterDataScreen(),
    );
  }
}

class WaterDataScreen extends StatefulWidget {
  @override
  _WaterDataScreenState createState() => _WaterDataScreenState();
}

class _WaterDataScreenState extends State<WaterDataScreen> {
  Map<String, double> dailyWaterUsageGoals = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 150, 196, 231),
      appBar: AppBar(
        title: Text('Set Goal'),
        backgroundColor: Color.fromARGB(255, 105, 178, 236),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _showGoalSettingDialog();
              },
              child: Text('Set Goal'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _fetchGoalData();
              },
              child: Text('Retrieve Goal'),
            ),
            SizedBox(height: 20),
            Text('Current Goal: ${dailyWaterUsageGoals.values.join(", ")}'),
          ],
        ),
      ),
    );
  }

  Future<void> _showGoalSettingDialog() async {
    double enteredGoal = 0.0;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Goal'),
          content: TextFormField(
            keyboardType: TextInputType.number,
            onChanged: (String value) {
              setState(() {
                enteredGoal = double.tryParse(value) ?? 0.0;
              });
            },
            decoration: InputDecoration(labelText: 'Enter Goal (Liters)'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Save the entered goal value for the current day using SharedPreferences
                await _saveGoalData(DateTime.now(), enteredGoal);

                Navigator.of(context).pop();
              },
              child: Text('Set'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchGoalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, double> goals = {};

    // Retrieve and update the daily water usage goals
    prefs.getKeys().forEach((key) {
      if (key.startsWith('waterUsageGoal_')) {
        String day = key.substring('waterUsageGoal_'.length);
        double goal = prefs.getDouble(key) ?? 0.0;
        goals[day] = goal;
      }
    });

    setState(() {
      dailyWaterUsageGoals = goals;
    });
  }

  Future<void> _saveGoalData(DateTime day, double goal) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key = 'waterUsageGoal_${_formatDate(day)}';
    prefs.setDouble(key, goal);
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }
}
