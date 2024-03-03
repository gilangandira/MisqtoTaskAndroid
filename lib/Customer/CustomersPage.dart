import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/Customer/AdminSite/AddDataCustomer.dart';
import 'package:task_management/Customer/CustomersList.dart';

import 'CustomerRepository.dart';


class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();

  static addCustomer(Map<String, String> customerData) {}
}

class _CustomerPageState extends State<CustomerPage> {
  final CustomerRepository customerRepository = CustomerRepository();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _role;
  String keyword = '';
  void initState() {
    super.initState();
    _role = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("role") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        floatingActionButton: FutureBuilder<String>(
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
                  return DraggableFab(
                    child: FloatingActionButton(
                      backgroundColor: Colors.blueAccent,
                      splashColor: Colors.blue[100],
                      child: const Icon(Icons.add,color: Colors.white,size: 50,),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddDataCustomer(),
                          ),
                        );
                      },
                    ),
                  ); // Tampilkan drawer admin jika peran adalah admin
                } else {
                  // Tambahkan pengembalian nilai widget di sini untuk menangani kasus lainnya
                  return const SizedBox(
                    height: 0,
                    width: 0,
                  ); // Atau widget sesuai dengan kondisi yang diinginkan
                }
              }
            }
          },
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ////////Welcome Name//////////
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 6,
                          ),
                        ],
                      ),
                    ],
                  ),
                  /////////Search Bar/////////
                  const SizedBox(
                    height: 20,
                  ),

                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                keyword = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: "Search",
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.blue[600],
                              contentPadding:
                              const EdgeInsets.symmetric(vertical: 5),
                              hintStyle: const TextStyle(color: Colors.white),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25)),
              child: Container(
                  color: Colors.white,
                  child: CustomersList(keyword: keyword,)),
            )),
          ],
        ));
  }
}
