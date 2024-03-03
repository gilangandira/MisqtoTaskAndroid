import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/AssetsModel.dart';
import 'DetailTask.dart';
import 'Resource/TaskRepository.dart';

class TaskList extends StatefulWidget {
  final String? keyword;
  const TaskList({super.key, this.keyword});


  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  TaskRepository taskRepository = TaskRepository();
  List<Tasks> itemList = [];
  bool isLoading = false;
  int page = 1;
  int limit = 10; // Jumlah data per halaman
  bool isAllDataLoaded = false; // Menandakan jika semua data sudah diambil
  final ScrollController _scrollController = ScrollController();

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
    fetchData();
    // Tambahkan listener untuk memantau scroll controller
    _scrollController.addListener(_scrollListener);
  }


  @override
  void didUpdateWidget(covariant TaskList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.keyword != oldWidget.keyword) {
      // Keyword berubah, reset data dan ambil data baru
      setState(() {
        isAllDataLoaded = false;
        page = 1;
        itemList.clear();
      });
      _fetchDataWithKeyword(widget.keyword);
    }
  }

  void _fetchDataWithKeyword(String? keyword) async {
    // Hapus data lama sebelum mengambil data baru
    setState(() {
      itemList.clear();
    });
    fetchData(); // Ambil data dengan keyword
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // Pengguna telah mencapai bagian bawah daftar
      if (!isLoading && !isAllDataLoaded) {
        fetchData();
      }
    }
  }
  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void fetchData() async {
    if (isLoading || isAllDataLoaded) return;
    setState(() {
      isLoading = true;
    });
    final headers = await getHeaders();
    final url =
    Uri.parse("https://misqot.repit.tech/api/task?page=$page&limit=$limit&keyword=${widget.keyword}");
    final result = await http.get(url,headers: headers);
    if (result.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(result.body);
      final List items = data['data'];
      final taskList = items
          .map((e) => Tasks(
        id: e["id"],
        name: e["name"],
        statusId: e["status_id"],
        assetsId: e["assets_id"],
        slaId: e["assets_id"],
        timeTrackId: e["timetracker_id"],
        description: e["description"],
        dates: DateTime.parse(e["dates"]),
        location: e["location"],
        updatedAt: DateTime.parse(e["updated_at"]),
        createdAt: DateTime.parse(e["created_at"]),
        assetsTasks: AssetsTasks.fromJson(e['assets']),
        status: Status.fromJson(e['status']),
        sla: SLA.fromJson(e['sla']),
        timeTrack: TimeTrack.fromJson(e['timetracker']),
        users: (e['users'] as List)
            .map((userData) => User.fromJson(userData))
            .toList(),
      ))
          .toList();

      setState(() {
        isLoading = false;
        itemList.addAll(taskList);
        // Periksa apakah data sudah habis
        if (taskList.length < limit) {
          // Semua data sudah diambil
          isAllDataLoaded = true;
        }
        page++;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> refreshData() async {
    // Fetch data or perform any necessary operations
    // setState to trigger a rebuild
    setState(() {
      fetchData();
    });
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width;
    var heigth = size.height;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      controller: _scrollController,
      itemCount: itemList.length,
      itemBuilder: (BuildContext context, int index) {
        final tasks = itemList[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailTask(tasks: tasks),
                ),
              );
            },
            child: Card(
              elevation: 3,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (tasks.sla.id == 1)
                        Column(
                          children: [
                            Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                color: Colors.orangeAccent,
                                borderRadius: BorderRadius.circular(10)
                            ),

                            child: const Icon(Icons.handyman,color: Colors.white,),),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text("Repair",style: TextStyle(color: Colors.black38,fontSize: 12),)
                          ],
                        )
                      else if (tasks.sla.id == 2)
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: const Icon(Icons.change_circle,color: Colors.white,),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text("Changeover",style: TextStyle(color: Colors.black38,fontSize: 12),)
                          ],
                        )
                      else
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: const Icon(Icons.settings_input_antenna_sharp,color: Colors.white,),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text("Installation",style: TextStyle(color: Colors.black38,fontSize: 12),)
                          ],
                        ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tasks.name,style: const TextStyle(fontSize: 18),),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(DateFormat('d MMMM').format(tasks.timeTrack.dueDates))
                            ],
                          ),
                        ),
                      ),
                      if (tasks.status.id == 1)
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: const Icon(Icons.warning,color: Colors.white,),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text("Ready",style: TextStyle(color: Colors.black38,fontSize: 12),)
                          ],
                        )
                      else if (tasks.status.id == 2)
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  color: Colors.orangeAccent,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: const Icon(Icons.circle_outlined,color: Colors.white,),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text("Progress",style: TextStyle(color: Colors.black38,fontSize: 12),)
                          ],
                        )
                        else if (tasks.status.id == 4)
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: const Icon(Icons.circle_outlined,color: Colors.white,),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text("Hold",style: TextStyle(color: Colors.black38,fontSize: 12),)
                            ],
                          )
                      else if (tasks.status.id == 3)
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: const Icon(Icons.check,color: Colors.white,),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text("Finish",style: TextStyle(color: Colors.black38,fontSize: 12),)
                          ],
                        )
                      else
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: const Icon(Icons.check,color: Colors.white,),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text("Expired",style: TextStyle(color: Colors.black38,fontSize: 12),)
                          ],
                        ),
                    ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
