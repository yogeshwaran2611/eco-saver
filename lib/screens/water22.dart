import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class WaterLevelScreen extends StatefulWidget {
  const WaterLevelScreen({Key? key}) : super(key: key);

  @override
  _WaterLevelScreenState createState() => _WaterLevelScreenState();
}

class _WaterLevelScreenState extends State<WaterLevelScreen> {
  late Future<List<Map<String, dynamic>>> futureData = Future.value([]);
  bool showGraph = true;

  @override
  void initState() {
    super.initState();
    fetchData(10); // Load last 10 data points on initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 150, 196, 231),
      appBar: AppBar(
        title: Text('Water Level'),
        backgroundColor: Color.fromARGB(255, 105, 178, 236),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showGraph = !showGraph;
              });
            },
            icon: Icon(showGraph ? Icons.view_list : Icons.show_chart),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<Map<String, dynamic>> dataList = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                WaterTank(waterLevel: calculateWaterLevel(dataList)),
                Expanded(
                  child: Center(
                    child: showGraph ? buildGraphView(dataList) : buildDataView(dataList),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildGraphView(List<Map<String, dynamic>> dataList) {
    return Column(
      children: [
        buildDashboardHeader(),
        Expanded(child: buildChart(dataList)),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DataPage(dataList),
              ),
            );
          },
          child: Text('View Data'),
        ),
      ],
    );
  }

  Widget buildDataView(List<Map<String, dynamic>> dataList) {
    // Sort the dataList in descending order based on the 'created_at' timestamp
    dataList.sort((a, b) => b['created_at'].compareTo(a['created_at']));

    return ListView.builder(
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Water Level: ${dataList[index]['field1']}'),
          subtitle: Text('Timestamp: ${dataList[index]['created_at']}'),
        );
      },
    );
  }

  Widget buildDashboardHeader() {
    return Container(
      padding: EdgeInsets.all(30.0),
      child: Text(
        'Water level',
        style: TextStyle(
          color: Color.fromARGB(255, 10, 8, 8),
          fontSize: 33,
        ),
      ),
    );
  }

  Widget buildChart(List<Map<String, dynamic>> dataList) {
    List<FlSpot> spots = [];

    for (int i = 0; i < dataList.length; i++) {
      final dynamic value = dataList[i]['field1'];
      if (value != null) {
        spots.add(FlSpot(i.toDouble(), double.parse('$value')));
      }
    }

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(20.0),
      height: 250,
      width: 350,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true, // Show grid lines
            drawVerticalLine: true, // Draw vertical grid lines
            drawHorizontalLine: true, // Draw horizontal grid lines
            horizontalInterval: 10, // Set interval for horizontal grid lines
            verticalInterval: 1, // Set interval for vertical grid lines
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.deepPurpleAccent, // Customize the color of horizontal grid lines
                strokeWidth: 1, // Customize the width of horizontal grid lines
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.deepPurpleAccent, // Customize the color of vertical grid lines
                strokeWidth: 1, // Customize the width of vertical grid lines
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              margin: 12,
              interval: 10,
              getTextStyles: (value) => const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              getTitles: (value) {
                return value.toInt().toString();
              },
              rotateAngle: 0,
            ),
            bottomTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              margin: 12,
              interval: 1,
              getTextStyles: (value) => const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              getTitles: (value) {
                return value.toInt().toString();
              },
              rotateAngle: 0,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.black),
          ),
          minX: 0,
          maxX: spots.length.toDouble() - 1,
          minY: 0,
          maxY: 100, // Adjusted maxY based on actual data
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchData(int numberOfEntries) async {
    final String apiKey = '49G91KDXNAURA5NV';
    final String channelId = '2466820';
    final String apiUrl = 'https://api.thingspeak.com/channels/$channelId/feeds.json?api_key=$apiKey&results=$numberOfEntries';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> feeds = data['feeds'];

      setState(() {
        futureData = Future.value(feeds.map((entry) => entry as Map<String, dynamic>).toList());
      });

      return feeds.map((entry) => entry as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load data. Status code: ${response.statusCode}');
    }
  }

  double calculateWaterLevel(List<Map<String, dynamic>> dataList) {
    // Here, you can implement your logic to calculate the water level
    // For demonstration, let's assume the water level is based on the last data point
    if (dataList.isNotEmpty) {
      final lastDataPoint = dataList.last;
      final double fieldValue = double.parse('${lastDataPoint['field1']}');
      // Adjust this value based on your requirement
      return fieldValue / 100; // Assuming field1 represents percentage (0 to 100)
    } else {
      return 0.0; // Default to 0 if no data is available
    }
  }
}

class DataPage extends StatelessWidget {
  final List<Map<String, dynamic>> dataList;

  DataPage(this.dataList);

  @override
  Widget build(BuildContext context) {
    // Sort the dataList in descending order based on the 'created_at' timestamp
    dataList.sort((a, b) => b['created_at'].compareTo(a['created_at']));

    return Scaffold(
      appBar: AppBar(
        title: Text('Data Page'),
        backgroundColor: Color.fromARGB(255, 85, 132, 168),
      ),
      body: ListView.builder(
        itemCount: dataList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Water Level: ${dataList[index]['field1']}'),
            subtitle: Text('Timestamp: ${dataList[index]['created_at']}'),
          );
        },
      ),
    );
  }
}

class WaterTank extends StatefulWidget {
  final double waterLevel; // Value between 0 to 1 indicating the water level
  final Duration animationDuration;

  WaterTank({
    required this.waterLevel,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  _WaterTankState createState() => _WaterTankState();
}

class _WaterTankState extends State<WaterTank> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.waterLevel,
    ).animate(_controller);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant WaterTank oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.waterLevel != widget.waterLevel) {
      _controller.reset();
      _controller.forward();
      _animation = Tween<double>(
        begin: 0.0,
        end: widget.waterLevel,
      ).animate(_controller);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: WaterTankPainter(_animation.value),
              child: Container(
                width: 200, // Adjust as per your requirement
                height: 250, // Adjust as per your requirement
              ),
            );
          },
        ),
        Text(
          '${(widget.waterLevel * 100).toInt()}%',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class WaterTankPainter extends CustomPainter {
  final double waterLevel;

  WaterTankPainter(this.waterLevel);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw tank
    final tankPaint = Paint()..color = Colors.grey;
    canvas.drawRect(Offset.zero & size, tankPaint);

    // Draw water
    final waterPaint = Paint()..color = Colors.blue;
    final waterHeight = size.height * waterLevel;
    canvas.drawRect(Rect.fromLTRB(0, size.height - waterHeight, size.width, size.height), waterPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

void main() {
  runApp(MaterialApp(
    home: WaterLevelScreen(),
  ));
}
