import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/Navbar/Home.dart';
import 'dart:convert';
import '../Customer/CustomerRepository.dart';
import '../Model/AssetsModel.dart';

class ChangeCustomers extends StatefulWidget {
  final Assets assets;
  const ChangeCustomers({Key? key, required this.assets})
      : super(key: key);
  @override
  _ChangeCustomersState createState() => _ChangeCustomersState();
}

class _ChangeCustomersState extends State<ChangeCustomers> {
  final CustomerRepository customerRepository = CustomerRepository();
  Customer? selectedCustomers;
  List<Customer> itemList = [];
  bool isLoading = false;
  int page = 1;
  int limit = 10; // Jumlah data per halaman
  bool isAllDataLoaded = false; // Menandakan jika semua data sudah diambil
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _currentKeyword = '';


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

    // Add a listener to the search bar
    _searchController.addListener(() {
      setState(() {
        _currentKeyword = _searchController.text;
        // Reset the page when the search keyword changes
        page = 1;
        isAllDataLoaded = false;
        itemList.clear();
        fetchData();
      });
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
        Uri.parse("https://misqot.repit.tech/api/paginate?page=$page&limit=$limit&keyword=$_currentKeyword");
    final result = await http.get(url,headers: headers);

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
      print("Error ${result.statusCode}");
    }
  }

  Future updateData() async {
    final headers = await getHeaders();
    final response = await http.post(
        Uri.parse(
            "https://misqot.repit.tech/api/assets/update/${widget.assets.id}"),
        body: {
          'newCustomer' : "3",
          'customer_id': selectedCustomers!.id.toString(),
        },
        headers: headers);
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Customers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ////////Search bar////////////
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {},
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
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                controller: _scrollController,
                itemCount: itemList.length,
                itemBuilder: (BuildContext context, int index) {
                  final customer = itemList[index];
                  return Card(
                    elevation: 5,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                            "https://misqot.repit.tech/storage/${customer.image}"),
                        radius: 30,
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(customer.customersName),
                          Text("${customer.bandwith.toString()}MB"),
                        ],
                      ),
                      subtitle: Text("Location: ${customer.location}"),
                      onTap: () {
                        setState(() {
                          selectedCustomers = itemList[index];
                        });
                        updateData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Data Has Been Change")),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const Home()
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
