import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/Vendor/VendorDetail.dart';
import '../Assets/Resource/AssetsRepository.dart';
import '../Model/AssetsModel.dart';
import 'EditVendor.dart';



class ListVendor extends StatefulWidget {
  const ListVendor({super.key});

  @override
  State<ListVendor> createState() => _ListVendorState();
}

class _ListVendorState extends State<ListVendor> {
  AssetRepository assetRepository = AssetRepository();
  List<Vendor> itemList = [];
  bool isLoading = false;
  int page = 1;
  int limit = 10; // Jumlah data per halaman
  bool isAllDataLoaded = false; // Menandakan jika semua data sudah diambil
  final ScrollController _scrollController = ScrollController();
  late Future<String> _role;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

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
    _role = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("role") ?? "";
    });
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
    Uri.parse("https://misqot.repit.tech/api/vendor?page=$page&limit=$limit");
    final result = await http.get(url,headers: headers);

    if (result.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(result.body);
      final List items = data['data'];

      final vendorList = items
          .map((e) => Vendor(
        id: e['id'],
        name: e['name'],
        brand: e['brand'],
        cpu: e['cpu'],
        cpuCore: e['cpu_core'],
        ram: e['ram'],
        lanPorts: e['lan_ports'],
        lanSpeed: e['lan_speed'],
        wirelessStandars: e['wireless_standards'],
        guestNetwork: e['guest_network'],
        power: e['power'],
      ))
          .toList();

      setState(() {
        isLoading = false;
        itemList.addAll(vendorList);
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

  Future deleteVendor(String vendorID) async {
    try {
      final data = await assetRepository.deleteVendor(vendorID);
      return data;
    } catch (e) {

      // Lakukan sesuatu jika terjadi kesalahan, seperti menampilkan pesan kesalahan ke pengguna.
      return null; // Atau return data default jika perlu.
    }
  }



  @override
  Widget build(BuildContext context) {
    return ListView.builder(
          physics: const BouncingScrollPhysics(),
          controller: _scrollController,
          itemCount: itemList.length,
          itemBuilder: (BuildContext context, int index) {
            final vendor = itemList[index];
            return Card(
              elevation: 5,
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(vendor.name),
                  ],
                ),
                subtitle: Text("Location: ${vendor.brand}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VendorDetail(vendor : vendor),
                    ),
                  );
                },
                trailing: FutureBuilder(
                    future: _role,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Menampilkan widget loading jika sedang mendapatkan data peran
                        return const CircularProgressIndicator(); // Atau tampilan loading yang sesuai
                      } else {
                        if (snapshot.hasError) {
                          // Menampilkan pesan kesalahan jika terjadi kesalahan
                          return Text('Error: ${snapshot.error}');
                        } else {
                          // Menampilkan drawer sesuai dengan peran pengguna
                          final userRole = snapshot.data ?? "";
                          if (userRole == 'admin') {
                            return PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.menu_rounded,
                              ),
                              onSelected: (String choice) {
                                if (choice == 'Edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditDataVendor(vendor: vendor)
                                    ),
                                  );
                                } else if (choice == 'Delete') {
                                  deleteVendor(vendor.id.toString()).then((value) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Data Berhasil DiHapus"),
                                      ),
                                    );
                                    // After deletion, you might want to remove the item from itemList.
                                    setState(() {
                                      itemList.removeAt(index);
                                    });
                                  });
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem(
                                  value: 'Edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'Delete',
                                  child: Text("Delete"),
                                )
                              ],
                            );
                          } else {
                            // Return a default widget for non-admin users
                            return const SizedBox(
                              height: 0,
                              width: 0,
                            ); // Replace with your desired widget
                          }
                        }
                      }
                    }
                ),

              ),
            );
          },
      );
  }
}
