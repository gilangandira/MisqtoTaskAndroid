import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/User/ProfileEdit.dart';
import 'package:http/http.dart' as http;
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String>
  _name,
      _email,
      _role,
      _kelamin,
      _agama,
      _jabatan,
      _alamat,
      _image;

  @override
  void initState() {
    super.initState();
    updateDataShared();
    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });
    _email = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("email") ?? "";
    });
    _role = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("role") ?? "";
    });
    _kelamin = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("kelamin") ?? "";
    });
    _agama = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("agama") ?? "";
    });
    _jabatan = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("jabatan") ?? "";
    });
    _alamat = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("alamat") ?? "";
    });
    _image = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("image") ?? "";
    });

  }
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
  Future<void> updateDataShared() async {
    final headers = await getHeaders();
    try {
      var response = await http.get(
        Uri.parse("https://misqot.repit.tech/api/users/me"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData != null) {
          // Periksa apakah properti yang diperlukan ada dalam responseData
          if (responseData.containsKey('message') && responseData.containsKey('data')) {
            final data = responseData['data']; // Ambil objek data dari responseData

            // Periksa apakah properti yang diperlukan ada dalam objek data
            if (data.containsKey('name') &&
                data.containsKey('email') &&
                data.containsKey('kelamin') &&
                data.containsKey('agama') &&
                data.containsKey('jabatan') &&
                data.containsKey('alamat') &&
                data.containsKey('image')) {

              // Simpan nilai ke SharedPreferences menggunakan fungsi bantu
              final prefs = await _prefs;
              prefs.setString("name", data['name']);
              prefs.setString("email", data['email']);
              prefs.setString("kelamin", data['kelamin']);
              prefs.setString("agama", data['agama']);
              prefs.setString("jabatan", data['jabatan']);
              prefs.setString("alamat", data['alamat']);
              prefs.setString("image", data['image']);
            } else {
              // Handle jika properti yang diperlukan tidak ada dalam objek data
            }
          } else {
            // Handle jika properti yang diperlukan tidak ada dalam responseData
          }
        } else {
          // Handle jika responseData null

        }
      } else {
        // Handle non-200 status code appropriately
      }
    } catch (error) {
      // Handle error appropriately
    }
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileEdit()));
              },
              icon: const Icon(Icons.edit))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
          child:Column(
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: FutureBuilder(
                    future:_image,
                  builder: (BuildContext context,  AsyncSnapshot<String> snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else {
                      if (snapshot.hasData) {
                        return Center(
                          child: InstaImageViewer(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: CachedNetworkImage(
                                imageUrl: "https://misqot.repit.tech/storage/profile-image/${snapshot.data!}",
                                placeholder: (context,
                                    url) => const CircularProgressIndicator(),
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
                        );
                      }else {
                        return const Text("-");
                      }
                    }
                  }
                  ),
          ),
              const SizedBox(height: 10),
                FutureBuilder(
                    future: _name,
                    builder: (BuildContext context,
                        AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else {
                        if (snapshot.hasData) {
                          return  Text(snapshot.data!, style: Theme.of(context).textTheme.headlineMedium);
                        } else {
                          return const Text("-");
                        }
                      }
                    }),
                FutureBuilder(
                    future: _email,
                    builder: (BuildContext context,
                        AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else {
                        if (snapshot.hasData) {
                         return  Text(snapshot.data!);
                        } else {
                          return const Text("-");
                        }
                      }
                    }),
              const SizedBox(height: 20),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),
                Card(
                  elevation: 5,
                  child: FutureBuilder(
                      future: _jabatan,
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else {
                          if (snapshot.hasData) {
                            return ProfileCustomerWidget(
                                title: snapshot.data!, icon: Bootstrap.person_workspace);
                          } else {
                            return const Text("-");
                          }
                        }
                      }),
                ),
                Card(
                  elevation: 5,
                  child: FutureBuilder(
                      future: _kelamin,
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else {
                          if (snapshot.hasData) {
                            return ProfileCustomerWidget(
                                title: snapshot.data!, icon: Bootstrap.gender_ambiguous);
                          } else {
                            return const Text("-");
                          }
                        }
                      }),
                ),
              const Divider(),
              const SizedBox(height: 10),
                Card(
                  elevation: 5,
                  child: FutureBuilder(
                      future: _agama,
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else {
                          if (snapshot.hasData) {
                            return ProfileCustomerWidget(
                                title: snapshot.data!, icon: Bootstrap.moon_stars_fill);
                          } else {
                            return const Text("-");
                          }
                        }
                      }),
                ),
                Card(
                  elevation: 5,
                  child: FutureBuilder(
                      future: _alamat,
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else {
                          if (snapshot.hasData) {
                            return ProfileCustomerWidget(
                                title: snapshot.data!, icon: Bootstrap.house);
                          } else {
                            return const Text("-");
                          }
                        }
                      }),
                ),
              ],
          ),
        ),
      ),
    );
  }
}
class ProfileCustomerWidget extends StatelessWidget {
  const ProfileCustomerWidget({
    super.key,
    required this.title,
    required this.icon,
    this.endIcon = true,
    this.textColor,
  });

  final String title;
  final IconData icon;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
        ),
        child: Icon(icon),
      ),
      title: Text(title,
          style:
          Theme.of(context).textTheme.bodyLarge?.apply(color: textColor)),
    );
  }
}