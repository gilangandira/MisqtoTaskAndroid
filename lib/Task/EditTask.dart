import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Model/AssetsModel.dart';
import '../Navbar/Home.dart';

class EditTask extends StatefulWidget {
  final Tasks tasks;
  const EditTask({super.key, required this.tasks});
  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  List<User> listJob = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _location = TextEditingController();
  List<TextEditingController> listUserController = [TextEditingController()];


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

  void initState() {
    super.initState();
    // Panggil fungsi untuk mengambil data dari API
    getDataSLA();
    getDataUser();
    _name.text = widget.tasks.name;
    _description.text = widget.tasks.description;
    _location.text = widget.tasks.location;
    // Set nilai default untuk selectedTime jika belum diatur
    // Set nilai default untuk selectedTime berdasarkan widget.tasks.sla
    if (widget.tasks.sla != null) {
      selectedTime = widget.tasks.sla;
    } else {
      // Gunakan nilai default jika widget.tasks.sla belum diatur
      selectedTime = timeList.isNotEmpty ? timeList[0] : null;
    }
  }


  List<User> selectedUsers = [];
  /////////DropDown////////
  SLA? selectedTime;
  List<SLA> timeList = [];
  User? selectedUser;
  List<User> userList = [];

  Future<void> getDataSLA() async {
    final headers = await getHeaders();
    final response = await http.get(Uri.parse('https://misqot.repit.tech/api/task/sla'),headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      timeList = data.map((item) => SLA.fromJson(item)).toList();
      setState(() {});
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> getDataUser() async {
    final headers = await getHeaders();
    final response = await http.get(Uri.parse('https://misqot.repit.tech/api/users'),headers: headers);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List items = data['data'];
      userList = items.map((e) => User(
        id: e['id'],
        name: e['name'],
        email: e['email'],
        image: e['image'],
        kelamin: e['kelamin'],
        agama: e['agama'],
        jabatan: e['jabatan'],
        alamat: e['alamat'],
        role: e['role'],
      ))
          .toList();
      setState(() {});
    } else {
      throw Exception('Failed to load data');
    }
  }
  Future<void> addTask() async {
    try {
      final dio = Dio();
      final headers = await getHeaders();
      final List<String> userIds = selectedUsers.map((user) => user.id).toList();
      final response = await dio.post(
        "https://misqot.repit.tech/api/task/update/${widget.tasks.id}",
        data: {
          'name': _name.text,
          'assets_id': widget.tasks.id.toString(),
          'description': _description.text,
          'sla_id': selectedTime!.id.toString(),
          'location': _location.text,
          'user_id': userIds,
        },
        options: Options(headers: headers),
      );
      return response.data;
    } catch (error) {

    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
            margin: const EdgeInsets.symmetric(horizontal: 50),
            child: const Text("Create New Task")),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 20,bottom: 20,top: 20),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Text(
                      "Title", style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      controller: _name,
                      style: const TextStyle(color: Colors.white),
                      decoration:  const InputDecoration(
                        hintText: "Task Name",
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white38),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Insert Name Task";
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: TextFormField(
                      controller: _location,
                      style: const TextStyle(color: Colors.white),
                      decoration:  const InputDecoration(
                        hintText: "Task Location",
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Insert Name Task";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(30),topLeft: Radius.circular(30)),
                child: Container(
                  color: Colors.white,
                  child: ListView(
                    children: [
                      Container(
                          margin: const EdgeInsets.only(left: 20,top: 20),
                          child: const Text("Description",style: TextStyle(color: Colors.blue,fontSize: 20,),)),
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          maxLines: 6,
                          controller: _description,
                          decoration:  InputDecoration(
                            hintText: widget.tasks.description,
                            enabledBorder: const OutlineInputBorder(borderSide: BorderSide(width:2,color: Colors.grey),),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Insert Description";
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                          margin: const EdgeInsets.only(left: 20,top: 20),
                          child: const Text("Pengerjaan",style: TextStyle(color: Colors.blue,fontSize: 20,),)),
                      /////////////////Selected Time/////////////
                      Container(
                        height: 100,
                        padding: const EdgeInsets.all(20),
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: timeList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedTime = timeList[index];
                                });
                              },
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                      color: selectedTime?.id == timeList[index]?.id ? Colors.blue : Colors.grey,
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Text(
                                      timeList[index].name
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      ///////////////////////ListUser////////////////
                      Container(
                          margin: const EdgeInsets.only(left: 20,top: 20),
                          child: const Text("Users",style: TextStyle(color: Colors.blue,fontSize: 20,),)),
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: listUserController.asMap().entries.map((entry) {
                            int index = entry.key;
                            return Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<User>(
                                    value: selectedUsers.length > index ? selectedUsers[index] : null,
                                    onChanged: (User? newValue) {
                                      setState(() {
                                        if (selectedUsers.length > index) {
                                          selectedUsers[index] = newValue!;
                                        } else {
                                          selectedUsers.add(newValue!);
                                        }
                                      });
                                    },
                                    items: userList.map((User user) {
                                      return DropdownMenuItem<User>(
                                        value: user,
                                        child: Text(user.name),
                                      );
                                    }).toList(),
                                    decoration: const InputDecoration(
                                      labelText: "User",
                                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 2, color: Colors.blue)),
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () {
                                    if (index == 0) {
                                      setState(() {
                                        listUserController.add(TextEditingController());
                                      });
                                    } else {
                                      setState(() {
                                        listUserController[index].dispose();
                                        listUserController.removeAt(index);
                                      });
                                    }
                                  },
                                  child: Icon(index == 0 ? Icons.add : Icons.delete, size: 45,color: index == 0  ? Colors.green : Colors.red,),
                                  // child: Text(index == 0 ? 'Add' : 'Button B'),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            addTask();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Home()));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text("Data Berhasil Ditambah")));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text("Data Tidak Berhasil ditambah")));
                          }
                        },
                        child: GestureDetector(
                          onTap: (){
                            if (_formKey.currentState!.validate()) {
                              addTask(); // Tunggu hingga permintaan selesai
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Data Berhasil Diubah")));
                              Navigator.popUntil(context, (route) => route.isFirst);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home()));
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.symmetric(horizontal: 50),
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(40)
                            ),
                            child: const Text("Edit Task",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              ),)
          ],
        ),
      ),
    );
  }
}
