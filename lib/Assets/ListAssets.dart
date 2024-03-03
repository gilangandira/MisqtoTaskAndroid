import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:popover/popover.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/Assets/ChangeCustomers.dart';
import '../Model/AssetsModel.dart';
import '../Task/AddTask.dart';
import 'DetailAssets.dart';
import 'EditAssetsPage.dart';
import 'Resource/AssetsRepository.dart';

class ListAssets extends StatefulWidget {
  final String? keyword;
  const ListAssets({super.key, this.keyword});
  @override
  State<ListAssets> createState() => _ListAssetsState();
}

class _ListAssetsState extends State<ListAssets> {
  AssetRepository assetRepository = AssetRepository();
  late Future<String> _role;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<Assets> itemList = [];
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
    _fetchDataWithKeyword(widget.keyword);
    // Tambahkan listener untuk memantau scroll controller
    _scrollController.addListener(_scrollListener);
    _role = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("role") ?? "";
    });
  }

  void didUpdateWidget(covariant ListAssets oldWidget) {
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
    final url = Uri.parse(
        "https://misqot.repit.tech/api/assets?page=$page&limit=$limit&keyword=${widget.keyword}");
    final result = await http.get(url, headers: headers);

    if (result.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(result.body);
      final List items = data['data'];

      final assetsList = items
          .map((e) => Assets(
                id: e['id'],
                userId: e['user_id'],
                categoryId: e['category_id'],
                conditionId: e['condition_id'],
                vendorId: e['vendor_id'],
                image: e['image'],
                namaAset: e['nama_aset'],
                description: e['description'],
                location: e['location'],
                serialNumber: e['serial_number'],
                serialAssets: e['serial_assets'],
                price: e['price'],
                dateBuyed: e['date_buyed'],
                condition: Condition.fromJson(e['condition']),
                user: User.fromJson(e['user']),
                vendor: Vendor.fromJson(e['vendor']),
                customer: Customer.fromJson(e['customer']),
                category: AssetsCategory.fromJson(e['category']),
              ))
          .toList();

      setState(() {
        isLoading = false;
        itemList.addAll(assetsList);
        // Periksa apakah data sudah habis
        if (assetsList.length < limit) {
          // Semua data sudah diambil
          isAllDataLoaded = true;
        }
        page++;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("Error ${result.statusCode}");
    }
  }
  Future deleteData(String assetsID) async {
    try {
      final data = await assetRepository.deleteData(assetsID);
      return data;
    } catch (e) {
      print("Error in getDataProfiles: $e");
      // Lakukan sesuatu jika terjadi kesalahan, seperti menampilkan pesan kesalahan ke pengguna.
      return null; // Atau return data default jika perlu.
    }
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
        final assets = itemList[index];
        return Card(
          elevation: 5,
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(assets.namaAset),
              ],
            ),
            subtitle: Text("Location: ${assets.location}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssetsDetail(assets: assets),
                ),
              );
            },
            trailing:
            FutureBuilder<String>(
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
                        color: Colors.blue[200],
                        icon: const Icon(
                          Icons.menu_rounded,
                        ),
                        onSelected: (String choice) {
                          if (choice == 'Edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditDataAssets(assets: assets),
                              ),
                            );
                          } else if (choice == 'Delete') {
                            deleteData(assets.id.toString()).then((value) {
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
                          } else if (choice == 'Task') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddTask(assets: assets)),
                            );
                          } else if (choice == 'Change Customers') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChangeCustomers(assets: assets)),
                            );
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
                          ),
                          const PopupMenuItem(
                            value: 'Task',
                            child: Text("Task"),
                          ),
                          const PopupMenuItem(
                            value: 'Change Customers',
                            child: Text("Change Customers"),
                          ),
                        ],
                      );
                        // Tampilkan drawer admin jika peran adalah admin
                    } else {
                      // Tambahkan pengembalian nilai widget di sini untuk menangani kasus lainnya
                      return PopupMenuButton<String>(
                        color: Colors.blue[200],
                        icon: const Icon(
                          Icons.menu_rounded,
                        ),
                        onSelected: (String choice) {
                          if (choice == 'Task') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddTask(assets: assets)),
                            );
                          } else if (choice == 'Change Customers') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChangeCustomers(assets: assets)),
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem(
                            value: 'Task',
                            child: Text("Task"),
                          ),
                        ],
                      ); // Atau widget sesuai dengan kondisi yang diinginkan
                    }
                  }
                }
              },
            ),




          ),
        );
      },
    );
  }
}