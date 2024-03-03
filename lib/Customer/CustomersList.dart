import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../Model/AssetsModel.dart';
import 'AdminSite/EditDataCustomer.dart';
import 'CustomerRepository.dart';
import 'DetailCustomer.dart';

class CustomersList extends StatefulWidget {
  final String? keyword;
  const CustomersList({super.key, this.keyword});
  @override
  _CustomersListState createState() => _CustomersListState();
}

class _CustomersListState extends State<CustomersList> {
  final CustomerRepository customerRepository = CustomerRepository();
  List<Customer> itemList = [];
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

  @override
  void didUpdateWidget(covariant CustomersList oldWidget) {
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

  Future deleteData(String customerId) async {
    try {
      final data = await customerRepository.deleteData(customerId);
      return data;
    } catch (e) {
      // Lakukan sesuatu jika terjadi kesalahan, seperti menampilkan pesan kesalahan ke pengguna.
      return null; // Atau return data default jika perlu.
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
        "https://misqot.repit.tech/api/paginate?page=$page&limit=$limit&keyword=${widget.keyword}");
    final result = await http.get(url, headers: headers);

    if (result.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(result.body);
      final List items = data['data'];

      final customers = items
          .map((e) => Customer(
                id: e['id'],
                customersName: e['customers_name'],
                ppoeUsername: e['ppoe_username'],
                ppoePassword: e['ppoe_password'],
                image: e['image'],
                ipClient: e['ip_client'],
                apSsid: e['ap_ssid'],
                channelFrequensy: e['channel_frequensy'],
                bandwith: e['bandwith'],
                subscriptionFee: e['subscription_fee'],
                location: e['location'],
                startDates: e['start_dates'],
              ))
          .toList();

      setState(() {
        isLoading = false;
        itemList.addAll(customers);
        // Periksa apakah data sudah habis
        if (customers.length < limit) {
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      controller: _scrollController,
      itemCount: itemList.length,
      itemBuilder: (BuildContext context, int index) {
        final customer = itemList[index];
        return Card(
          elevation: 5,
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(customer.customersName),
                Text("${customer.bandwith.toString()}MB"),
              ],
            ),
            subtitle: Text("Location: ${customer.location}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerDetail(customer: customer),
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
                                      EditDataCustomers(customer: customer),
                                ),
                              );
                            } else if (choice == 'Delete') {
                              deleteData(customer.id.toString()).then((value) {
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
