import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:http/http.dart' as http;
import '../Model/AssetsModel.dart';
import '../Navbar/Home.dart';
import 'EditTask.dart';

class DetailTask extends StatefulWidget {
  final Tasks tasks;

  const DetailTask({super.key,required this.tasks});
  @override
  State<DetailTask> createState() => _DetailTaskState();
}

class _DetailTaskState extends State<DetailTask> {
  List<User> listJob = [];
  late final StopWatchTimer _stopWatchTimer;
  late int _duration = 0;
  late int _status;
  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }
  @override
  void initState() {
    super.initState();

    getDataJob(roleId: widget.tasks.id);
    startTimer(taskId: widget.tasks.timeTrack.id);
    _stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
    );
    _status = widget.tasks.statusId;
    if (widget.tasks.statusId == 2 ){
      _duration = widget.tasks.timeTrack.timer;
    }else{
      _duration = 0;
    }
    _stopWatchTimer.onStartTimer();

  }

  Future<void> getDataJob({required int roleId}) async {
    final headers = await getHeaders();
    final response = await http.get(Uri.parse('https://misqot.repit.tech/api/task/jobuser/$roleId'), headers: headers);
    if (response.statusCode == 200) {
      final List<dynamic> userJson = json.decode(response.body);
      final List<User> users = userJson.map((json) => User.fromJson(json)).toList();
      setState(() {
        listJob = users;
      });
    } else {
      throw Exception('Failed to load users by role');
    }
  }

  String _getFormattedDate(DateTime dueDate) {
    final List<String> monthNames = [
      'January', 'February', 'Maret', 'April', 'Mei', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    String day = dueDate.day.toString().padLeft(2, '0');
    String month = monthNames[dueDate.month - 1];
    return '$day $month';
  }

  ///////////////Tracking Time/////////////
  void startTimer({required int taskId}) async {
    // Panggil API Laravel untuk memulai pelacakan waktu
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('https://misqot.repit.tech/api/task/start/$taskId'),headers: headers
    );
    if (response.statusCode == 200) {
    } else {
    }
  }

  void statusTask({required int statusId}) async {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('https://misqot.repit.tech/api/task/do/$statusId'),
        headers: headers,
        body: {
          'status_id': _status.toString(), // Pastikan untuk mengonversi ke string
        },
      );
      if (response.statusCode == 200) {
      } else {
      }
  }


  void endStopwatch() async {
    // Panggil API Laravel untuk mengakhiri pelacakan waktu
    final response = await http.post(
      Uri.parse('https://misqot.repit.tech/api/task/end/${widget.tasks.id}'),
    );
    if (response.statusCode == 200) {
    } else {
    }
  }
  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();  // Need to call dispose function.
    // await _timerStopWatch.dispose();
  }



  @override
  Widget build(BuildContext context) {
    _stopWatchTimer.setPresetSecondTime(_duration,add: false);
    var size = MediaQuery.of(context).size;
    var width = size.width;
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 30),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          borderRadius: BorderRadius.circular(14)
                        ),
                        child: const Icon(Icons.arrow_back_rounded,size: 35,color: Colors.white,),
                      ),
                    ),
                    Column(
                      children: [
                        if (_status != 5 && _status != 3)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditTask(tasks: widget.tasks)));
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 30),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue[600],
                              borderRadius: BorderRadius.circular(14)
                            ),
                            child: const Icon(Icons.edit,size: 35,color: Colors.white,),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                    margin: const EdgeInsets.only(left: 20,bottom: 30),
                    child: const Text("Task Detail",style: TextStyle(color: Colors.white,fontSize: 28),)),
                Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(30),topLeft: Radius.circular(30)),
                  child: Container(
                  color: Colors.white,
                    child: ListView(
                      children: [
                        Container(
                            margin: const EdgeInsets.all(20),
                            child: Text(widget.tasks.name,style: const TextStyle(color: Colors.blue,fontSize: 28,),)),
                        Container(
                          margin: const EdgeInsets.all(20),
                          child: Text(widget.tasks.description,style: const TextStyle(color: Colors.black45,height: 1.5),textAlign: TextAlign.justify,)
                        ),
                        Container(
                            margin: const EdgeInsets.only(left: 20,top: 20),
                            child: const Text("Members",style: TextStyle(color: Colors.blue,fontSize: 20,),)),

                        Container(
                          height: 100,
                          width: 100,
                          padding: const EdgeInsets.all(20),
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: listJob.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(right: 20),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.person,size: 40,),
                                      Text(listJob[index].name)
                                    ],
                                  ));
                            },
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.all(20),
                            child: const Text("Detail",style: TextStyle(color: Colors.blue,fontSize: 20,),)),
                        Container(
                          height: 100,
                          width: width,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Flexible(flex: 10, child: Container(
                                decoration: BoxDecoration(color: Colors.white,
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20),bottomLeft: Radius.circular(20)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                        margin: const EdgeInsets.all(20),
                                        child: Text(widget.tasks.location,style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(left: 20),
                                            child: Text(widget.tasks.sla.name,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.bold),)),
                                        Container(
                                          margin: const EdgeInsets.only(right: 20),
                                            child: Text(_getFormattedDate(widget.tasks.dates),style: const TextStyle(fontSize: 12,fontWeight: FontWeight.bold),)),
                                      ],
                                    ),
                                  ],
                                ),
                                )
                              ),
                              Flexible(flex: 1,child: Container(
                                decoration: BoxDecoration(color: Colors.green,
                                borderRadius: const BorderRadius.only(topRight: Radius.circular(20),bottomRight: Radius.circular(20)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      // ignore: prefer_const_constructors
                                      offset: Offset(0, 3), // changes position of shadow),
                                    )],
                                ),
                                )),
                            ],
                          ),
                        ),Container(
                            margin: const EdgeInsets.all(20),
                            child: const Text("Assets",style: TextStyle(color: Colors.blue,fontSize: 20,),)),
                        Container(
                          height: 100,
                          width: width,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Flexible(flex: 10, child: Container(
                                decoration: BoxDecoration(color: Colors.white,
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20),bottomLeft: Radius.circular(20)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                        margin: const EdgeInsets.all(20),
                                        child: Text(widget.tasks.assetsTasks.namaAset,style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(left: 20),
                                            child: Text(widget.tasks.assetsTasks.serialAssets,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.bold),)),
                                        Container(
                                          margin: const EdgeInsets.only(right: 20),
                                            child: Text(widget.tasks.assetsTasks.dateBuyed,style: const TextStyle(fontSize: 12,fontWeight: FontWeight.bold),)),
                                      ],
                                    ),
                                  ],
                                ),
                                )
                              ),
                              Flexible(flex: 1,child: Container(
                                decoration: BoxDecoration(color: Colors.deepOrange,
                                borderRadius: const BorderRadius.only(topRight: Radius.circular(20),bottomRight: Radius.circular(20)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                )),

                            ],
                          ),
                        ),Container(
                            margin: const EdgeInsets.all(20),
                            child: const Text("Progress",style: TextStyle(color: Colors.blue,fontSize: 20,),)),
                        Container(
                          height: 150,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Flexible(flex: 10, child: Container(
                                decoration: BoxDecoration(color: Colors.white,
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20),bottomLeft: Radius.circular(20)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(20),
                                  width: width,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                              padding: const EdgeInsets.all(5),
                                              child: const Text("Remaining Time",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)),
                                          /////////////////////Timer/////////////
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                            child: SlideCountdownSeparated(
                                              duration: Duration(seconds: _duration),
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius: BorderRadius.circular(5)
                                              ),
                                            ),

                                          ),
                                        ]
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                              padding: const EdgeInsets.all(5),
                                              child: const Text("Due Dates",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)),
                                          Container(
                                            padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius: BorderRadius.circular(10)
                                              ),
                                              child: Text(_getFormattedDate(widget.tasks.timeTrack.dueDates),style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                )
                              ),
                              Flexible(flex: 1,child: Container(
                                decoration: BoxDecoration(color: Colors.blue,
                                borderRadius: const BorderRadius.only(topRight: Radius.circular(20),bottomRight: Radius.circular(20)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                )),
                            ],
                          ),
                        ),

                        Column(
                          children: [
                            if (_status != 5 && _status != 3)
                            Container(
                              padding: const EdgeInsets.all(20.0),
                              width: width,
                              child: FloatingActionButton(
                                onPressed: () {
                                  if (_status != 2) {
                                    setState(() {
                                      _status = 2;
                                    });
                                    statusTask(statusId: widget.tasks.id);
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const Home()));
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        content: Text("Success To Get Task")));
                                  }else{
                                    setState(() {
                                      _status = 3;
                                    });
                                    statusTask(statusId: widget.tasks.id);
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const Home()));
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        content: Text("Success To Finish Task")));
                                  }
                                },
                                backgroundColor: Colors.blue,
                                splashColor: Colors.greenAccent,
                                elevation: 5,
                                child : Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: <Widget>[
                                      if (_status != 2)
                                        const Text("Accept",
                                        style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                        ),
                                        )

                                      else
                                        const Text("Finish",
                                          style: TextStyle(
                                              fontSize: 24,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold
                                          ),)
                                    ],
                                  ),
                                )
                                ),
                              ),
                          ],
                        ),
                        Column(
                          children: [
                            if (_status != 5 && _status != 3)
                            Column(
                              children: [
                                if (_status != 4)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    width: width,
                                    child: FloatingActionButton(onPressed: (){
                                      setState(() {
                                        _status = 4;
                                        statusTask(statusId: widget.tasks.id);
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => const Home()));
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                            content: Text("Hold The Task")));
                                      });
                                    },
                                      backgroundColor: Colors.blue,
                                      splashColor: Colors.greenAccent,
                                      elevation: 5,
                                      child: const Text("Hold",
                                        style: TextStyle(
                                            fontSize: 24,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        ),),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    width: width,
                                    child: FloatingActionButton(onPressed: (){
                                      setState(() {
                                        _status = 3;
                                        statusTask(statusId: widget.tasks.id);
                                      });
                                    },
                                      backgroundColor: Colors.blue,
                                      splashColor: Colors.greenAccent,
                                      elevation: 5,
                                      child: const Text("Finish",
                                        style: TextStyle(
                                            fontSize: 24,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold
                                        ),),
                                    ),
                                  ),

                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 70,
                        ),
                        
                      ],
                    ),
                  ),
                ),)
        ],
      ),
    );
  }
}


