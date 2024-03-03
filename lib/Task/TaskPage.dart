import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/Task/HistoryTask.dart';
import 'Resource/TaskRepository.dart';
import 'TaskList.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  String keyword= '';
  final TaskRepository taskRepository = TaskRepository();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String>_role, _name;


@override
  void initState() {
    super.initState();
    _role = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("role") ?? "";
    });
    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });
  }

  Future getDataTasks() async {
    try {
      final data = await taskRepository.getDataTask();
      return data;
    } catch (e) {
      rethrow;
    }
  }

  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ////////Welcome Name//////////
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder(
                            future: _name,
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else {
                                if (snapshot.hasData) {
                                  return Text(
                                        "Hi, ${snapshot.data!}",
                                      style: const TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.bold),
                                      )
                                  ;
                                } else {
                                  return const Text("-");
                                }
                              }
                            }),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(formattedDate,style: TextStyle(color: Colors.blue[200],fontWeight: FontWeight.bold),),

                      ],
                    ),
                    /////Notification
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                          DateTime? pickeddate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2025));

                          if (pickeddate != null) {
                            setState(() {
                              keyword =
                                  DateFormat('yyyy-MM-dd').format(pickeddate);
                            });
                          }},
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.blue[600],
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              padding: const EdgeInsets.all(12),
                              child: const Icon(Icons.date_range,color: Colors.white,)),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryTask()));
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.blue[600],
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              padding: const EdgeInsets.all(12),
                              child: const Icon(Icons.history,color: Colors.white,)),
                        ),
                      ],
                    )
                  ],
                ),
                /////////Search Bar/////////
                const SizedBox(
                  height: 20,
                ),
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        keyword = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      filled: true,
                      fillColor: Colors.blue[600],
                      contentPadding: const EdgeInsets.symmetric(vertical: 5),
                      hintStyle: const TextStyle(color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),
                const Row(
                  children: [
                    Text("What are you working on today?",style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),
                    Icon(Icons.more_horiz,color: Colors.white,),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                ///////////////Sort///////////
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              keyword = "";
                            });
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.blue[600],
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              padding: const EdgeInsets.all(10),
                              child: const Icon(IonIcons.reader,color: Colors.white,size: 60)),

                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text("All",style: TextStyle(color: Colors.blue[200],fontWeight: FontWeight.bold),),
                      ],
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              keyword = "Not yet done";
                            });
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.blue[600],
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              padding: const EdgeInsets.all(10),
                              child: const Icon(FontAwesome.hourglass,color: Colors.white,size: 60)),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text("Ready",style: TextStyle(color: Colors.blue[200],fontWeight: FontWeight.bold),),
                      ],
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              keyword = "Ongoing";
                            });
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.blue[600],
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              padding: const EdgeInsets.all(10),
                              child: const Icon(HeroIcons.arrow_path_rounded_square,color: Colors.white,size: 60)),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text("Progress",style: TextStyle(color: Colors.blue[200],fontWeight: FontWeight.bold),),
                      ],
                    ),const SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              keyword = "Postponed";
                            });
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.blue[600],
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              padding: const EdgeInsets.all(10),
                              child: const Icon(IonIcons.warning,color: Colors.white,size: 60,)),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text("Hold",style: TextStyle(color: Colors.blue[200],fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          Expanded(
            child:
                ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                  child: Container(
                    color: Colors.white,
                    child: TaskList(keyword: keyword,),
                  ),
                ),
          ),
        ],
      ));
  }
}
