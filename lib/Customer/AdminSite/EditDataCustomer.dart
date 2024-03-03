import 'package:flutter/material.dart';
import 'package:http/http.dart' as myAPI;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/Navbar/Home.dart';
import 'dart:convert';

import '../../Model/AssetsModel.dart';

class EditDataCustomers extends StatefulWidget {
  final Customer customer;

  EditDataCustomers({super.key, required this.customer});

  @override
  State<EditDataCustomers> createState() => _EditDataCustomersState();
}

class _EditDataCustomersState extends State<EditDataCustomers> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCustomer = TextEditingController();

  final TextEditingController _ppoeUsername = TextEditingController();

  final TextEditingController _ppoePassword = TextEditingController();

  final TextEditingController _ipClient = TextEditingController();

  final TextEditingController _apSSID = TextEditingController();

  final TextEditingController _channelFrequensy = TextEditingController();

  final TextEditingController _bandwith = TextEditingController();

  final TextEditingController _subscriptionFee = TextEditingController();

  final TextEditingController _location = TextEditingController();

  final TextEditingController _startDates = TextEditingController();

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
    final response = await myAPI.post(
        Uri.parse(
            "https://misqot.repit.tech/api/customers/update/${widget.customer.id}"),
        body: {
          'customers_name': _nameCustomer.text,
          'ppoe_username': _ppoeUsername.text,
          'ppoe_password': _ppoePassword.text,
          'ip_client': _ipClient.text,
          'ap_ssid': _apSSID.text,
          'channel_frequensy': _channelFrequensy.text,
          'bandwith': _bandwith.text,
          'subscription_fee': _subscriptionFee.text,
          'location': _location.text,
          'start_dates': _startDates.text,
        },
        headers: headers);
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: const Text("Edit Customers",style: TextStyle(fontSize: 18,color: Colors.white),)),
      ),
      body: Form(
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
                      "Name",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      controller: _nameCustomer..text = widget.customer.customersName,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Name",
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
                          return "Insert Name";
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: TextFormField(
                      controller: _location..text = widget.customer.location,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Customers Location",
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
                          return "Insert Customers Location";
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
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30)),
                child: Container(
                  color: Colors.white,
                  child: ListView(
                    children: [
                      Container(
                          margin: const EdgeInsets.only(left: 20, top: 20),
                          child: const Text(
                            "Detail",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 20,
                            ),
                          )),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: _ppoeUsername..text = widget.customer.ppoeUsername,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: const InputDecoration(
                              labelText: "PPOE Username",
                              icon: Icon(Icons.email)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Insert PPOE Username";
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: _ppoePassword..text = widget.customer.ppoePassword,
                          decoration: const InputDecoration(
                              labelText: "PPOE Password", icon: Icon(Icons.key)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Insert PPOE Password";
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: _ipClient..text = widget.customer.ipClient, // Convert int to String
                          decoration: const InputDecoration(
                              labelText: "IP CLient",
                              icon: Icon(Icons.wifi_tethering)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Insert IP Client";
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: _apSSID..text = widget.customer.apSsid,
                          decoration: const InputDecoration(
                              labelText: "AP SSID",
                              icon: Icon(Icons.wifi)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Insert AP SSID";
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: _channelFrequensy..text = widget.customer.channelFrequensy.toString(),
                          decoration: const InputDecoration(
                              labelText: "Channel Frequensy",
                              icon: Icon(Icons.list)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Insert Channel Frequensy";
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: _bandwith..text = widget.customer.bandwith.toString(),
                          decoration: const InputDecoration(
                              labelText: "Bandwith",
                              icon: Icon(Icons.speed)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Insert Bandwith";
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: _subscriptionFee..text = widget.customer.subscriptionFee.toString(),
                          decoration: const InputDecoration(
                              labelText: "Subscription Fee",
                              icon: Icon(Icons.wallet)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Insert Subscription Fee";
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: _startDates..text = widget.customer.startDates,
                          decoration: const InputDecoration(
                              labelText: "Date of Start",
                              icon: Icon(Icons.date_range)),
                          onTap: () async {
                            DateTime? pickeddate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2025));

                            if (pickeddate != null) {
                              setState(() {
                                _startDates.text =
                                    DateFormat('yyyy-MM-dd').format(pickeddate);
                              });
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 70),
                        child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // Tunggu hingga permintaan selesai
                                await updateData();
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Success to add data")),
                                );
                              }
                            },
                            child: const Text('Save')),
                      ),
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
