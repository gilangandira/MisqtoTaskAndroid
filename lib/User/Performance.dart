import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Performance extends StatefulWidget {
  final Map user;
  const Performance({super.key, required this.user});

  @override
  State<Performance> createState() => _PerformanceState();
}

class _PerformanceState extends State<Performance> {
  List<dynamic> dataFromApi = [];
  Future<List<dynamic>> fetchData(String userId) async {
    final response = await http.get(Uri.parse('https://misqot.repit.tech/api/performance?keyword=$userId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']; // Assuming 'data' is the key containing the array in your API response
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchData();

  }

  Future<void> _fetchData() async {
    try {
      final data = await fetchData(widget.user['id']);
      setState(() {
        dataFromApi = data;
      });
    } catch (error) {
      // Handle error
    }
  }



  final List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  final List<Color> gradientOpacity = [
    const Color(0xff23b6e6).withOpacity(0.3),
    const Color(0xff02d39a).withOpacity(0.3),
  ];

  List<FlSpot> _getChartDataFromApi(List<dynamic> dataFromApi) {
    return dataFromApi.map((entry) {
      double x = entry['month'].toDouble();
      double y = entry['total'].toDouble();
      return FlSpot(x, y);
    }).toList();
  }

  SideTitles get _bottomTitles => SideTitles(
    showTitles: true,
    getTitlesWidget: (value, meta) {
      String text = '';

      switch (value.toInt()) {
        case 1:
          text = 'Jan';
          break;
      // case 3:
      //   text = 'Mar';
      //   break;
        case 5:
          text = 'May';
          break;
      // case 7:
      //   text = 'Jul';
      //   break;
        case 9:
          text = 'Sep';
          break;
      // case 11:
      //   text = 'Dec';
      //   break;
      }
      return Text(text,style: const TextStyle(color: Colors.white),);
    },
  );
  SideTitles get _rightTitles => SideTitles(
    showTitles: true,
    getTitlesWidget: (value, meta) {
      String text = '';

      switch (value.toInt()) {
        case 10:
          text = '10';
          break;
      // case 3:
      //   text = 'Mar';
      //   break;
        case 50:
          text = '50';
          break;
      // case 7:
      //   text = 'Jul';
      //   break;
        case 80:
          text = '80';
          break;
      // case 11:
      //   text = 'Dec';
      //   break;
      }
      return Text(text,style: const TextStyle(color: Colors.white),);
    },
  );


  String getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return 'Unknown';
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Performance/Month",style: TextStyle(color: Colors.greenAccent,fontSize: 28,fontWeight: FontWeight.bold),),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.greenAccent,
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchData(widget.user['id']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  height: 400,
                  child: LineChart(
                      LineChartData(
                          minX: 0,
                          maxX: 12,
                          minY: 0,
                          maxY: 100,
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              drawBelowEverything: true,
                              sideTitles: _bottomTitles,
                            ),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Container())),
                            leftTitles: AxisTitles(
                                drawBelowEverything: true,
                                sideTitles: _rightTitles),
                          ),
                          gridData: FlGridData(
                            show: true,
                            getDrawingHorizontalLine: (value) {
                              return const FlLine(
                                  color: Colors.white10,
                                  strokeWidth: 1
                              );
                            },
                            drawVerticalLine: true,
                            getDrawingVerticalLine: (value) {
                              return const FlLine(
                                  color: Colors.white10,
                                  strokeWidth: 1
                              );
                            },
                          ),
                          borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                  color: Colors.black87
                              )
                          ),
                          lineBarsData: [
                            LineChartBarData(
                                isCurved: true,
                                gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: gradientColors
                                ),
                                barWidth: 5,
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: gradientOpacity,
                                  ),
                                ),
                                dotData: const FlDotData(
                                    show: false
                                ),
                                spots: _getChartDataFromApi(dataFromApi)
                            ),
                          ]
                      )
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var item =snapshot.data![index];
                        String monthName = getMonthName(item['month']);
                        return ListTile(
                          title: Text(monthName,style: const TextStyle(color: Colors.greenAccent,fontSize: 24,fontWeight: FontWeight.bold),),
                          subtitle: Text('${item['total']} Task',style: const TextStyle(color: Colors.white),),
                        );
                      }),
                )
              ],
            );


          }
        },
      ),
    );
  }
}
