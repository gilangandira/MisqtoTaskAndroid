import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../Model/AssetsModel.dart';
import '../Navbar/Home.dart';

class EditDataAssets extends StatefulWidget {
  final Assets assets;

  EditDataAssets({super.key, required this.assets});

  @override
  State<EditDataAssets> createState() => _EditDataAssetsState();
}

class _EditDataAssetsState extends State<EditDataAssets> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaAssets = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final TextEditingController _serialNumber = TextEditingController();
  final TextEditingController _serialAssets = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _dateBuyed = TextEditingController();
  ///////////Customers//////////
  final TextEditingController _nameCustomer = TextEditingController();
  final TextEditingController _ppoeUsername = TextEditingController();
  final TextEditingController _ppoePassword = TextEditingController();
  final TextEditingController _ipClient = TextEditingController();
  final TextEditingController _apSSID = TextEditingController();
  final TextEditingController _channelFrequensy = TextEditingController();
  final TextEditingController _bandwith = TextEditingController();
  final TextEditingController _subscriptionFee = TextEditingController();
  final TextEditingController _cusLocation = TextEditingController();
  final TextEditingController _startDates = TextEditingController();


  int selectedCategoryId = 0;
  bool _switchEditCustomer = false;
  bool _switchAddCustomer = false;
  late int customers;

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
    final response = await http.post(
        Uri.parse("https://misqot.repit.tech/api/assets/update/${widget.assets.id}"),
        body: {
          'category_id': selectedCategory!.id.toString(),
          'condition_id': selectedConditon!.id.toString(),
          'vendor_id': selectedVendor!.id.toString(),
          'nama_aset': _namaAssets.text,
          'description': _description.text,
          'serial_number': _serialNumber.text,
          'serial_assets': _serialAssets.text,
          'price': _price.text,
          'location': _location.text,
          'date_buyed': _dateBuyed.text,
          //////////////////Customers
          'newCustomer': customers.toString(),
          'customers_name': _nameCustomer.text,
          'ppoe_username': _ppoeUsername.text,
          'ppoe_password': _ppoePassword.text,
          'ip_client': _ipClient.text,
          'ap_ssid': _apSSID.text,
          'channel_frequensy': _channelFrequensy.text,
          'bandwith': _bandwith.text,
          'subscription_fee': _subscriptionFee.text,
          'cuslocation': _location.text,
          'start_dates': _startDates.text,
        },
        headers: headers);
    return json.decode(response.body);
  }


  ////////DropDown Condition//////
  Vendor? selectedVendor;
  List<Vendor> vendorList = [];
  Customer? selectedCustomers;
  List<Customer> customerList = [];
  Condition? selectedConditon;
  List<Condition> conditionList = [];
  AssetsCategory? selectedCategory;
  List<AssetsCategory> categoryList = [];
  bool isLoading = false;
  int page = 1;
  int limit = 10;
  bool isVendorExpanded = false;
  bool isAllDataLoaded = false; // Menandakan jika semua data sudah diambil
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getDataVendor();
    getDataCondition();
    getDataCategory();
    selectedVendor = widget.assets.vendor;
    customers = 0;
    if (widget.assets.condition != null) {
      selectedConditon = widget.assets.condition;
    } else {
      // Gunakan nilai default jika widget.tasks.sla belum diatur
      selectedConditon = conditionList.isNotEmpty ? conditionList[0] : null;
    }
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // Pengguna telah mencapai bagian bawah daftar
      if (!isLoading && !isAllDataLoaded) {
        getDataVendor();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getDataVendor() async {
    if (isLoading || isAllDataLoaded) return;
    setState(() {
      isLoading = true;
    });
    final headers = await getHeaders();
    final response = await http.get(
        Uri.parse(
            'https://misqot.repit.tech/api/listvendor?page=$page&limit=$limit'),
        headers: headers);
    if (response.statusCode == 200) {
      // final data = jsonDecode(response.body) as List;
      // vendorList = data.map((item) => Vendor.fromJson(item)).toList();
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List items = data['data'];
      final listItem = items
          .map((e) => Vendor(
                id: e['id'],
                name: e['name'],
                cpu: e['cpu'],
                cpuCore: e['cpu_core'],
                ram: e['ram'],
                lanPorts: e['lan_ports'],
                lanSpeed: e['lan_speed'],
                wirelessStandars: e['wireless_standards'],
                guestNetwork: e['guest_network'],
                power: e['power'],
                brand: e['brand'],
              ))
          .toList();
      setState(() {
        isLoading = false;
        // vendorList.addAll(vendorList);
        vendorList.addAll(listItem);

        // Periksa apakah data sudah habis
        if (vendorList.length < limit) {
          // Semua data sudah diambil
          isAllDataLoaded = true;
        }
        page++;
      });
    } else {
      print("Error ${response.statusCode}: ${response.body}");
      setState(() {
        isLoading = false;
      });
      print("Error ${response.statusCode}");
    }
  }

  Future<void> getDataCondition() async {
    final headers = await getHeaders();
    final response = await http.get(
        Uri.parse('https://misqot.repit.tech/api/assets/condition'),
        headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      conditionList = data.map((item) => Condition.fromJson(item)).toList();
      setState(() {});
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> getDataCategory() async {
    final headers = await getHeaders();
    final response = await http.get(
        Uri.parse('https://misqot.repit.tech/api/assets/category'),
        headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      categoryList = data.map((item) => AssetsCategory.fromJson(item)).toList();
      setState(() {});
    } else {
      throw Exception('Failed to load data');
    }
  }


  @override
  Widget build(BuildContext context) {
    if (customerList.isNotEmpty) {
      selectedCustomers = customerList.firstWhere(
        (customer) => customer.id == widget.assets.vendor.id,
        orElse: () => customerList[0], // Set a default value if not found
      );
    } else {
      // Handle the case when vendorList is empty, for example, by setting selectedVendor to null.
      selectedCustomers = null;
    }
    if (categoryList.isNotEmpty) {
      selectedCategory = categoryList.firstWhere(
        (category) => category.id == widget.assets.vendor.id,
        orElse: () => categoryList[0], // Set a default value if not found
      );
    } else {
      // Handle the case when vendorList is empty, for example, by setting selectedVendor to null.
      selectedCategory = null;
    }
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
            margin: const EdgeInsets.symmetric(horizontal: 50),
            child: const Text("Edit Assets",style: TextStyle(fontSize: 18,color: Colors.white),)),
      ),
      backgroundColor: Colors.blue,
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
                      "Title",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      controller: _namaAssets..text = widget.assets.namaAset,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Assets Name",
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
                      controller: _location..text = widget.assets.location,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Assets Location",
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
                            "Vendor Assets",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 20,
                            ),
                          )),
                      Container(
                        margin:
                            const EdgeInsets.only(left: 20, top: 20, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(selectedVendor?.name ?? "Vendor Blm Dipilih"),
                            IconButton(
                                onPressed: () {
                                  _dataVendor(context);
                                },
                                icon: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.blue),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    )))
                          ],
                        ),
                      ),
                      Container(
                          margin: const EdgeInsets.only(left: 20, top: 20),
                          child: const Text(
                            "Condition",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 20,
                            ),
                          )),
                      Container(
                        height: 100,
                        padding: const EdgeInsets.all(20),
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: conditionList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedConditon = conditionList[index];
                                });
                              },
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                      color: selectedConditon?.id ==
                                              conditionList[index].id
                                          ? Colors.blue
                                          : Colors.grey,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Text(conditionList[index].name),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                          margin: const EdgeInsets.only(left: 20, top: 20),
                          child: const Text(
                            "Category",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 20,
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: DropdownButtonFormField<AssetsCategory>(
                          value: selectedCategory,
                          onChanged: (AssetsCategory? newValue) {
                            setState(() {
                              selectedCategory = newValue;
                            });
                          },
                          items: categoryList.map((AssetsCategory category) {
                            return DropdownMenuItem<AssetsCategory>(
                              value: category,
                              child: Text(category.name),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: "Category",
                            prefixIcon: Icon(Icons.email),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 2, color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
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
                          controller: _description
                            ..text = widget.assets.description,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: const InputDecoration(
                              labelText: "Deskripsi",
                              icon: Icon(Icons.description)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Masukan PPOE Password";
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: _serialAssets
                            ..text = widget.assets.serialAssets,
                          decoration: const InputDecoration(
                              labelText: "Serial Asset", icon: Icon(Icons.web)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Masukan IP.Client";
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: _serialNumber
                            ..text = widget
                                .assets.serialNumber, // Convert int to String
                          decoration: const InputDecoration(
                              labelText: "Serial Number",
                              icon: Icon(Icons.wifi_tethering)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Insert Serial Number  ";
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: _price..text = widget.assets.price,
                          decoration: const InputDecoration(
                              labelText: "Price Asset ",
                              icon: Icon(Icons.wallet)),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Insert Price Asset";
                            }
                            return null;
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: _dateBuyed
                            ..text = widget.assets.dateBuyed,
                          decoration: const InputDecoration(
                              labelText: "Date Buyed",
                              icon: Icon(Icons.date_range)),
                          onTap: () async {
                            DateTime? pickeddate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2025));

                            if (pickeddate != null) {
                              setState(() {
                                _dateBuyed.text =
                                    DateFormat('yyyy-MM-dd').format(pickeddate);
                              });
                            }
                          },
                        ),
                      ),
                      if (_switchAddCustomer != true)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                margin:
                                    const EdgeInsets.only(left: 20, top: 20),
                                child: const Text(
                                  "Edit Customers?",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 20,
                                  ),
                                )),
                            Container(
                              margin: const EdgeInsets.only(right: 20, top: 20),
                              child: Transform.scale(
                                scale: 1.2,
                                child: Switch(
                                    activeTrackColor: Colors.blueAccent,
                                    activeColor: Colors.blue,
                                    splashRadius: 5,
                                    value: _switchEditCustomer,
                                    onChanged: (bool value) {
                                      setState(() {
                                        _switchEditCustomer = value;
                                        customers = 1;
                                      });
                                    }),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                              margin: const EdgeInsets.only(left: 20, top: 20),
                              child: const Text(
                                "Add Customers?",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20,
                                ),
                              )),
                          Container(
                            margin: const EdgeInsets.only(right: 20, top: 20),
                            child: Transform.scale(
                              scale: 1.2,
                              child: Switch(
                                  activeTrackColor: Colors.blueAccent,
                                  activeColor: Colors.blue,
                                  splashRadius: 5,
                                  value: _switchAddCustomer,
                                  onChanged: (bool value) {
                                    setState(() {
                                      _switchAddCustomer = value;
                                      _switchEditCustomer = false;
                                      customers = 2;
                                    });
                                  }),
                            ),
                          ),
                        ],
                      ),
                      if (_switchEditCustomer == true)
                        _EditCustomers()
                      else
                        Container(),
                      if (_switchAddCustomer == true)
                        _addCustomers()
                      else
                        Container(),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 70),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                    var result = await updateData();
                                    if (result != null &&
                                        result['success'] == true) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text("Data Has Been Added"),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text("Failed to add data"),
                                        ),
                                      );
                                    }
                                } catch (e) {
                                  print('Error updating data: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "An error occurred while updating data"),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('Save'),
                          ))
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

  Widget _EditCustomers() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: _nameCustomer
              ..text = widget.assets.customer.customersName,
            decoration: const InputDecoration(
                labelText: "Nama Customer", icon: Icon(Icons.person)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Masukan Nama Customer";
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: _ppoeUsername
              ..text = widget.assets.customer.ppoeUsername,
            decoration: const InputDecoration(
                labelText: "PPOE Username", icon: Icon(Icons.email)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Masukan PPOE Username";
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: _ppoePassword
              ..text = widget.assets.customer.ppoePassword,
            decoration: const InputDecoration(
                labelText: "PPOE Password", icon: Icon(Icons.password)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Masukan PPOE Password";
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: _ipClient..text = widget.assets.customer.ipClient,
            decoration: const InputDecoration(
                labelText: "IP Client",
                icon: Icon(Icons.install_desktop_rounded)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Masukan IP.Client";
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: _apSSID..text = widget.assets.customer.apSsid,
            decoration: const InputDecoration(
                labelText: "AP SSID", icon: Icon(Icons.call_received)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Masukan AP SSID";
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: _channelFrequensy
              ..text = widget.assets.customer.channelFrequensy.toString(),
            decoration: const InputDecoration(
                labelText: "Channel Frequensy", icon: Icon(Icons.show_chart)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Masukan Channel Frequensy";
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: _bandwith
              ..text = widget.assets.customer.bandwith.toString(),
            decoration: const InputDecoration(
                labelText: "Bandwith", icon: Icon(Icons.speed)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Masukan Bandwith";
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: _subscriptionFee
              ..text = widget.assets.customer.subscriptionFee.toString(),
            decoration: const InputDecoration(
                labelText: "Subscription Fee",
                icon: Icon(Icons.monetization_on)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Masukan Subscription Fee";
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: _cusLocation..text = widget.assets.customer.location,
            decoration: const InputDecoration(
                labelText: "Location", icon: Icon(Icons.location_on)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Masukan Location";
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _startDates..text = widget.assets.customer.startDates,
            decoration: const InputDecoration(
                labelText: "Start Dates", icon: Icon(Icons.date_range)),
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
      ],
    );
  }

  Future _dataVendor(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width;
    return showModalBottomSheet(
      barrierColor: Colors.black87,
      elevation: 5,
      context: context,
      builder: (context) => Container(
        margin: const EdgeInsets.all(20),
        child: ListView.builder(
            controller: _scrollController,
            itemCount: vendorList.length,
            itemBuilder: (BuildContext context, int index) {
              final vendor = vendorList[index];
              return Card(
                elevation: 5,
                child: ListTile(
                  title: Text(vendor.name),
                  onTap: () {
                    setState(() {
                      selectedVendor = vendor;
                    });
                  },
                ),
              );
            }),
      ),
    );
  }

  Widget _addCustomers() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: _nameCustomer,
            decoration: const InputDecoration(
                labelText: "Nama Customer", icon: Icon(Icons.person)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Masukan Nama Customer";
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: _ppoeUsername,
            decoration: const InputDecoration(
                labelText: "PPOE Username", icon: Icon(Icons.email)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Masukan PPOE Username";
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: _ppoePassword,
            decoration: const InputDecoration(
                labelText: "PPOE Password", icon: Icon(Icons.password)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Masukan PPOE Password";
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: _ipClient,
            decoration: const InputDecoration(
                labelText: "IP Client",
                icon: Icon(Icons.install_desktop_rounded)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Masukan IP.Client";
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: _apSSID,
            decoration: const InputDecoration(
                labelText: "AP SSID", icon: Icon(Icons.call_received)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Masukan AP SSID";
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: _channelFrequensy,
            decoration: const InputDecoration(
                labelText: "Channel Frequensy", icon: Icon(Icons.show_chart)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Masukan Channel Frequensy";
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: _bandwith,
            decoration: const InputDecoration(
                labelText: "Bandwith", icon: Icon(Icons.speed)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Masukan Bandwith";
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: _subscriptionFee,
            decoration: const InputDecoration(
                labelText: "Subscription Fee",
                icon: Icon(Icons.monetization_on)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Masukan Subscription Fee";
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: _cusLocation,
            decoration: const InputDecoration(
                labelText: "Location", icon: Icon(Icons.location_on)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Masukan Location";
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _startDates,
            decoration: const InputDecoration(
                labelText: "Start Dates", icon: Icon(Icons.date_range)),
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
      ],
    );
  }
}
