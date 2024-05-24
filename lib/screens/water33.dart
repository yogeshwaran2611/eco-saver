import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WaterUsageScreen extends StatefulWidget {
  const WaterUsageScreen({Key? key}) : super(key: key);

  @override
  _WaterUsageScreenState createState() => _WaterUsageScreenState();
}

class _WaterUsageScreenState extends State<WaterUsageScreen> {
  late Future<List<Map<String, dynamic>>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 150, 196, 231),
      appBar: AppBar(
        title: Text('Water Usage Data'),
        backgroundColor: Color.fromARGB(255, 105, 178, 236),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> dataList = snapshot.data!;
            // Sort the dataList in descending order based on the date
            dataList.sort((a, b) => b['date']!.compareTo(a['date']!));
            return ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                final data = dataList[index];
                return ListTile(
                  title: Text('Date: ${data['date']}, Usage: ${data['usage']}'),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    final String apiUrl =
        'https://api.thingspeak.com/channels/2466820/feeds.json?api_key=49G91KDXNAURA5NV';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> feeds = data['feeds'];

      List<Map<String, dynamic>> result = [];

      for (var feed in feeds) {
        final String? timestamp =
        feed['created_at'] != null ? feed['created_at'].toString() : null;

        final double waterUsage = double.parse(feed['field2']);

        result.add({'date': timestamp, 'usage': waterUsage});
      }

      return result;
    } else {
      throw Exception(
          'Failed to load data. Status code: ${response.statusCode}');
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: WaterUsageScreen(),
  ));
}
