import 'package:flutter/material.dart';
import 'package:http/http.dart' as my_api;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../Model/AssetsModel.dart';
import '../Navbar/Home.dart';
import 'Resource/AssetsRepository.dart';

class AddDataAssets extends StatefulWidget {
  const AddDataAssets({super.key});
  @override
  State<AddDataAssets> createState() => _AddDataAssetsState();
}

class _AddDataAssetsState extends State<AddDataAssets> {
  AssetRepository assetRepository = AssetRepository();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaAssets = TextEditingController();
  final TextEditingController _customer = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final TextEditingController _serialNumber = TextEditingController();
  final TextEditingController _serialAssets = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _dateBuyed = TextEditingController();
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

  Vendor? selectedVendor;
  List<Vendor> vendorList = [];
  bool isLoading = false;
  int page = 1;
  int limit = 10;
  bool isVendorExpanded = false;
  bool isAllDataLoaded = false; // Menandakan jika semua data sudah diambil
  final ScrollController _scrollController = ScrollController();

  Customer? selectedCustomers;
  List<Customer> customerList = [];

  Condition? selectedConditon;
  List<Condition> conditionList = [];

  AssetsCategory? selectedCategory;
  List<AssetsCategory> categoryList = [];

  int selectedCategoryId = 0;
  bool newCustomers = false;
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
      final response =
      await my_api.post(Uri.parse("https://misqot.repit.tech/api/assets/store"),
          body: {
            'category_id': selectedCategory!.id.toString(),
            'condition_id': selectedConditon!.id.toString(),
            'customer_id': _customer.text,
            'vendor_id': selectedVendor!.id.toString(),
            'nama_aset': _namaAssets.text,
            'description': _description.text,
            'serial_number': _serialNumber.text,
            'serial_assets': _serialAssets.text,
            'price': _price.text,
            'location': _location.text,
            'date_buyed': _dateBuyed.text,
            //////////////////Customers
            'newCustomer' : newCustomers.toString(),
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


  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mengambil data dari API
    getDataVendor();
    getDataCondition();
    getDataCategory();
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
    final response = await my_api.get(
        Uri.parse('https://misqot.repit.tech/api/listvendor?page=$page&limit=$limit'),
        headers: headers);
    if (response.statusCode == 200) {
      // final data = jsonDecode(response.body) as List;
      // vendorList = data.map((item) => Vendor.fromJson(item)).toList();
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List items = data['data'];
      final listItem = items.map((e) => Vendor(
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
      )).toList();
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
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getDataCondition() async {
    final headers = await getHeaders();
    final response = await my_api.get(
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
    final response = await my_api.get(
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
            child: const Text("Create New Assets",style: TextStyle(fontSize: 18,color: Colors.white),)),
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
                          controller: _namaAssets,
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
                              return "Insert Asset Name";
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
                              return "Insert Asset Location";
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
                              child: const Text("Vendor Assets",style: TextStyle(color: Colors.blue,fontSize: 20,),)),
                          Container(
                            margin: const EdgeInsets.only(left: 20,top: 20,right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(selectedVendor?.name ?? "Vendor not yet selected"),
                                IconButton(onPressed: () {
                                  _dataVendor(context);
                                }, icon: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.blue
                                    ),
                                    child: const Icon(Icons.add,color: Colors.white,)))
                              ],
                            ),
                          ),
                          Container(
                              margin: const EdgeInsets.only(left: 20,top: 20),
                              child: const Text("Condition",style: TextStyle(color: Colors.blue,fontSize: 20,),)),
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
                                      margin: const EdgeInsets.symmetric(horizontal: 5),
                                      decoration: BoxDecoration(
                                          color: selectedConditon == conditionList[index] ? Colors.blue : Colors.grey,
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      child: Text(
                                          conditionList[index].name
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                              margin: const EdgeInsets.only(left: 20,top: 20),
                              child: const Text("Category",style: TextStyle(color: Colors.blue,fontSize: 20,),)),
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
                                  borderSide: BorderSide(width: 2, color: Colors.blue),
                                ),
                              ),
                            ),
                          ),
                          Container(
                              margin: const EdgeInsets.only(left: 20,top: 20),
                              child: const Text("Detail",style: TextStyle(color: Colors.blue,fontSize: 20,),)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              controller: _description,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: const InputDecoration(
                                labelText: "Description",
                                  icon: Icon(Icons.description)
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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              controller: _serialAssets,
                              decoration: const InputDecoration(
                                labelText: "Serial Asset",
                                  icon: Icon(Icons.web)
                              ),
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
                              controller: _serialNumber, // Convert int to String
                              decoration: const InputDecoration(
                                labelText: "Serial Number",
                                  icon: Icon(Icons.wifi_tethering)
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Insert Channel frequency";
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              controller: _price,
                              decoration: const InputDecoration(
                                labelText: "Price Asset ",
                                icon: Icon(Icons.wallet)
                              ),
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
                              controller: _dateBuyed,
                              decoration: const InputDecoration(
                                  labelText: "Date of purchase", icon: Icon(Icons.date_range)),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  margin: const EdgeInsets.only(left: 20,top: 20),
                                  child: const Text("New Customers?",style: TextStyle(color: Colors.blue,fontSize: 20,),)),
                              Container(
                                margin: const EdgeInsets.only(right: 20,top: 20),
                                child: Transform.scale(
                                  scale: 1.2,
                                  child: Switch(
                                    activeTrackColor: Colors.blueAccent,
                                    activeColor: Colors.blue,
                                      splashRadius: 5,
                                      value: newCustomers, onChanged: (bool value) {
                                    setState(() {
                                      newCustomers = value;
                                    });
                                  }),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (newCustomers == true)
                            _addCustomers()
                          else
                            Container(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 70),
                            child: ElevatedButton(
                              onPressed: () async {
                                  var result = await updateData();
                                    Navigator.pop(context);
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

  Future _dataVendor(BuildContext context){
    return showModalBottomSheet(
      barrierColor: Colors.black87,
      elevation: 5,
      context: context,
      builder: (context) => Container(
        margin: const EdgeInsets.all(20),
        child: ListView.builder(
            controller: _scrollController,
            itemCount: vendorList.length,
            itemBuilder: (BuildContext context, int index ) {
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
                labelText: "Customers Name", icon: Icon(Icons.person)),
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
                labelText: "Channel Frequensy",
                icon: Icon(Icons.show_chart)),
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





