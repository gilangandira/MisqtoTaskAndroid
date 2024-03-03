import 'package:flutter/material.dart';
import 'package:http/http.dart' as my_api;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../Navbar/Home.dart';



class AddDataVendor extends StatefulWidget {
  const AddDataVendor({super.key});
  @override
  State<AddDataVendor> createState() => _AddDataVendorState();
}

class _AddDataVendorState extends State<AddDataVendor> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _brand = TextEditingController();
  final TextEditingController _cpu = TextEditingController();
  final TextEditingController _cpuCore = TextEditingController();
  final TextEditingController _ram = TextEditingController();
  final TextEditingController _lanPorts = TextEditingController();
  final TextEditingController _lanSpeed = TextEditingController();
  final TextEditingController _wirelessStandards = TextEditingController();
  final TextEditingController _guestNetwork = TextEditingController();
  final TextEditingController _power = TextEditingController();

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

  Future updateData() async {
    final headers = await getHeaders();
    final response = await my_api.post(
        Uri.parse(
            "https://misqot.repit.tech/api/vendor/store"),
        body: {
          "name" : _name.text,
          "brand" :_brand.text ,
          "cpu" : _cpu.text,
          "cpu_core" : _cpuCore.text,
          "ram" : _ram.text,
          "lan_ports" : _lanPorts.text,
          "lan_speed" : _lanSpeed.text,
          "wireless_standards" : _wirelessStandards.text,
          "guest_network" : _guestNetwork.text,
          "power": _power.text
        },
        headers: headers);
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        resizeToAvoidBottomInset: true,
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
              child: const Text("Create New Vendor", style: TextStyle(color: Colors.white),)),
        ),
        body:
        Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 20, bottom: 20, top: 20),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Text(
                        "Title",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: _name,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Name Vendor",
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
                            return "Insert Name Vendor";
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: TextFormField(
                        controller: _brand,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Brand",
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
                            return "Insert Brand";
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
                            child: const Text("Detail",style: TextStyle(color: Colors.blue,fontSize: 20,),)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            controller: _cpu,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: const InputDecoration(
                                labelText: "CPU",
                                icon: Icon(Icons.description)
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Insert CPU";
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            controller: _cpuCore,
                            decoration: const InputDecoration(
                                labelText: "CPU CORE",
                                icon: Icon(Icons.web)
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Insert CPU CORE";
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            controller: _ram,
                            decoration: const InputDecoration(
                                labelText: "Ram",
                                icon: Icon(Icons.wifi_tethering)
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Insert Ram";
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            controller: _guestNetwork,
                            decoration: const InputDecoration(
                                labelText: "Guest Network ",
                                icon: Icon(Icons.wallet)
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Insert Guest Network";
                              }
                              return null;
                            },
                          ),
                        ), Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            controller: _lanPorts,
                            decoration: const InputDecoration(
                                labelText: "Lan Ports",
                                icon: Icon(Icons.wallet)
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Insert Lan Ports";
                              }
                              return null;
                            },
                          ),
                        ),Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            controller: _lanSpeed,
                            decoration: const InputDecoration(
                                labelText: "Lan Speed",
                                icon: Icon(Icons.wallet)
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Insert Lan Speed";
                              }
                              return null;
                            },
                          ),
                        ),Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            controller: _wirelessStandards,
                            decoration: const InputDecoration(
                                labelText: "Wireless Standards",
                                icon: Icon(Icons.wallet)
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Insert Wireless Standards";
                              }
                              return null;
                            },
                          ),
                        ),Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: TextFormField(
                            controller: _power,
                            decoration: const InputDecoration(
                                labelText: "Power",
                                icon: Icon(Icons.wallet)
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Insert Power";
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 70),
                          child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  updateData();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Data Has Been Added")),
                                    );
                                    Navigator.pop(context);
                                }
                              },
                              child: const Text('Save'),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
