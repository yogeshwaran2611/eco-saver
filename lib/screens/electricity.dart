import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(
    MaterialApp(
      home: ElectricityScreen(),
    ),
  );
}

class ElectricityScreen extends StatefulWidget {
  const ElectricityScreen({Key? key}) : super(key: key);

  @override
  _ElectricityScreenState createState() => _ElectricityScreenState();
}

class _ElectricityScreenState extends State<ElectricityScreen> {
  List<Map<String, dynamic>> readings = [];
  bool applianceOn = false; // State variable to track appliance state

  @override
  void initState() {
    super.initState();
    _fetchCurrentAndVoltageReadings();
  }

  Future<void> _fetchCurrentAndVoltageReadings() async {
    final String channelID = '2410378';
    final String apiKey = '94AJYYEK5SZKNOY5';

    final url = 'https://api.thingspeak.com/channels/$channelID/feeds.json?api_key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      if (response.body != null) {
        final data = json.decode(response.body);
        final feeds = data['feeds'] as List<dynamic>;

        List<Map<String, dynamic>> allReadings = [];

        for (var feed in feeds) {
          final current = double.tryParse(feed['field6'] ?? '0.0');
          final voltage = double.tryParse(feed['field3'] ?? '0.0');

          if (current != null && voltage != null) {
            allReadings.add({
              'current': current,
              'voltage': voltage,
              'created_at': feed['created_at'] ?? '',
            });
          } else {
            print('Error parsing current or voltage data');
          }
        }

        setState(() {
          readings = allReadings;
        });
      } else {
        print('Response body is null or empty');
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }

  void _toggleApplianceState() {
    setState(() {
      applianceOn = !applianceOn;
    });
    // Perform action to control the appliance (e.g., send command to IoT device)
    if (applianceOn) {
      // If appliance is turned on, do something
      print('Appliance turned ON');
    } else {
      // If appliance is turned off, do something
      print('Appliance turned OFF');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 150, 196, 231),
      appBar: AppBar(
        title: Text('Electricity monitoring'),
        backgroundColor: Color.fromARGB(255, 105, 178, 236),
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildLatestReading(),
          ElevatedButton(
            onPressed: () {
              _fetchCurrentAndVoltageReadings(); // Call method to refresh data
            },
            child: Text('Refresh data'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GraphPage(readings: readings),
                ),
              );
            },
            child: Text('View data'),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CombinedGraphPage(readings: readings),
                ),
              );
            },
            child: Text('View Graph'),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestReading() {
    if (readings.isEmpty) {
      return Text('No data available');
    } else {
      return Column(
        children: [
          Image.asset(
            'assets/current.png',
            height: 200,
            width: 400,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 10),
          Text('Latest Reading:'),
          Text('Current: ${readings.first['current']}'),
          Text('Voltage: ${readings.first['voltage']}'),
          Text('Timestamp: ${readings.first['created_at']}'),
        ],
      );
    }
  }
}

class GraphPage extends StatelessWidget {
  final List<Map<String, dynamic>> readings;

  GraphPage({required this.readings});

  @override
  Widget build(BuildContext context) {
    // Sort the readings in descending order based on timestamp
    readings.sort((a, b) => b['created_at'].compareTo(a['created_at']));

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 150, 196, 231),
      appBar: AppBar(
        title: Text('Data Page'),
        backgroundColor: Color.fromARGB(255, 105, 178, 236),
      ),
      body: ListView.builder(
        itemCount: readings.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Voltage: ${readings[index]['voltage']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current: ${readings[index]['current']}'),
                Text('Timestamp: ${readings[index]['created_at']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class CombinedGraphPage extends StatelessWidget {
  final List<Map<String, dynamic>> readings;

  CombinedGraphPage({required this.readings});

  @override
  Widget build(BuildContext context) {
    // Sort the readings in descending order based on timestamp
    readings.sort((a, b) => b['created_at'].compareTo(a['created_at']));

    // Extract the latest 15 data points
    final List<Map<String, dynamic>> latestReadings =
    readings.length > 15 ? readings.sublist(0, 15) : readings;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 150, 196, 231),
      appBar: AppBar(
        title: Text('Graphical view'),
        backgroundColor: Color.fromARGB(255, 105, 178, 236),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: SideTitles(
                      showTitles: true,
                      interval: 50, // Y-axis interval of 50 units
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: latestReadings.length.toDouble() - 1,
                  minY: 0,
                  maxY: _calculateMaxY(latestReadings), // Calculate maxY dynamically
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (int i = 0; i < latestReadings.length; i++)
                          FlSpot(i.toDouble(), latestReadings[i]['current'].toDouble()),
                      ],
                      isCurved: true,
                      colors: [Colors.red],
                      barWidth: 2,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: [
                        for (int i = 0; i < latestReadings.length; i++)
                          FlSpot(i.toDouble(), latestReadings[i]['voltage'].toDouble()),
                      ],
                      isCurved: true,
                      colors: [Colors.blue],
                      barWidth: 2,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Latest Data ',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: latestReadings.length,
                itemBuilder: (context, index) {
                  final reading = latestReadings[index];
                  return ListTile(
                    title: Text('Voltage: ${reading['voltage']}'),
                    subtitle: Text(
                        'Current: ${reading['current']}\nTimestamp: ${reading['created_at']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMaxY(List<Map<String, dynamic>> readings) {
    double maxY = 0;
    for (var reading in readings) {
      if (reading['current'] > maxY) {
        maxY = reading['current'];
      }
      if (reading['voltage'] > maxY) {
        maxY = reading['voltage'];
      }
    }
    return maxY * 1.2; // Add some padding to maxY
  }
}
