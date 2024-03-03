import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AddVendor.dart';
import 'ListVendor.dart';

class VendorPage extends StatefulWidget {
  const VendorPage({super.key});

  @override
  State<VendorPage> createState() => _VendorPageState();
}

class _VendorPageState extends State<VendorPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _role;
  @override
  void initState() {
    super.initState();
    _role = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("role") ?? "";
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              final userRole = snapshot.data ??
                  ""; // Ambil nilai peran pengguna dari snapshot
              if (userRole == 'admin') {
                return DraggableFab(
                  child: FloatingActionButton(
                      backgroundColor: Colors.blueAccent,
                      splashColor: Colors.blue[100],
                      child: const Icon(Icons.add,color: Colors.white,size: 50,),
                      onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddDataVendor()));
                  }),
                ); // Tampilkan drawer admin jika peran adalah admin
              } else {
                return Container(); // Tampilkan drawer member jika peran adalah member
              }
            }
          }
        },
      ),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.blue),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('List Data Vendor',style: TextStyle(color: Colors.blue),),
      ),
      body: const ListVendor()
    );
  }
}
