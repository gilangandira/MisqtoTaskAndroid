import 'package:cached_network_image/cached_network_image.dart';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Performance.dart';
import '../ViewProfile.dart';
import 'AddUsers.dart';
import 'EditProfile.dart';
import 'UserRepository.dart';
class ListProfile extends StatefulWidget {
  const ListProfile({Key? key}) : super(key: key);

  @override
  State<ListProfile> createState() => _ListProfileState();
}

class _ListProfileState extends State<ListProfile> {
  final ApiService apiService = ApiService();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String>_role;

  @override
  void initState() {
    super.initState();
    _role = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("role") ?? "";
    });
  }
  Future getDataProfiles() async {
    try {
      final data = await apiService.getDataProfiles();
      return data;
    } catch (e) {
      print("Error in getDataProfiles: $e");
      // Lakukan sesuatu jika terjadi kesalahan, seperti menampilkan pesan kesalahan ke pengguna.
      return null; // Atau return data default jika perlu.
    }
  }

  Future deleteData(String userId) async {
    try {
      final data = await apiService.deleteData(userId);
      return data;
    } catch (e) {
      print("Error in deleteData: $e");
      // Lakukan sesuatu jika terjadi kesalahan, seperti menampilkan pesan kesalahan ke pengguna.
      return null; // Atau return data default jika perlu.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: DraggableFab(
        child: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddUsers()),
            );
          },
        ),
      ),
      appBar: AppBar(
        title: const Text('Data Profile'),
      ),
      body: FutureBuilder(
        future: getDataProfiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.data == null) {
            // Periksa apakah data null
            return const Text('Data is null'); // Tampilkan pesan jika data null
          } else {
            return ListView.builder(
              itemCount: snapshot.data['data']?.length ?? 0,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewProfile(
                                  user: snapshot.data['data'][index],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: Row(
                              children: [
                                Container(
                                  height: 100,
                                  width: 100,
                                  child: CircleAvatar(
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: "https://misqot.repit.tech/public/storage/profile-image/" +
                                            snapshot.data['data'][index]['image'],
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                        imageBuilder: (context, imageProvider) =>
                                            Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // child: Image.network(
                                  //   "http://10.0.2.2:8000/storage/" +
                                  //       snapshot.data['data'][index]['image'],
                                  //   fit: BoxFit.cover,
                                  // ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Text(
                                        (snapshot.data['data'][index]['name'] ??
                                            'Data Tidak ada'),
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      Text((snapshot.data['data'][index]
                                              ['jabatan'] ??
                                          'Data Tidak ada')),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.menu_rounded,
                      ),
                      onSelected: (String choice) {
                        if (choice == 'Edit') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditProfile(
                                      user: snapshot.data['data']
                                      [index])));
                        }else if (choice == 'Performance') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Performance(
                                      user: snapshot.data['data']
                                      [index])));
                        } else if (choice == 'Delete') {
                          deleteData(snapshot.data['data'][index]
                          ['id']
                              .toString())
                              .then((value) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                content: Text(
                                    "Data Berhasil DiHapus")));
                          });
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'Edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'Performance',
                          child: Text('Performance'),
                        ),
                        const PopupMenuItem(
                          value: 'Delete',
                          child: Text("Delete"),
                        ),
                      ],
                    ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
