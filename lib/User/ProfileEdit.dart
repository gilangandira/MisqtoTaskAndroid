import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:task_management/Navbar/Home.dart';
import 'package:task_management/User/profile.dart';
import 'login.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  FilePickerResult? result;
  String? _fileName;
  PlatformFile? pickedfile;
  bool isLoading = false;
  File? fileToDisplay;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String>
  _id,
  _name,
      _email,
      _role,
      _kelamin,
      _agama,
      _jabatan,
      _alamat,
      _image;
  String image = "";
  bool changePassword = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController role = TextEditingController();
  TextEditingController kelamin = TextEditingController();
  TextEditingController agama = TextEditingController();
  TextEditingController jabatan = TextEditingController();
  TextEditingController alamat = TextEditingController();
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

    _id = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("id") ?? "";
    });_name = _prefs.then((SharedPreferences prefs) {
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
  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    prefs.remove("name");
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const LoginPage()),
        ModalRoute.withName('/'));
  }

  Future<void> updateData(String userId) async {
    final headers = await getHeaders();
    // Create a map for the request body
    Map<String, String> requestBody = {
      'name': name.text,
      'email': email.text,
      'kelamin': kelamin.text,
      'agama': agama.text,
      'alamat': alamat.text,
    };
    if (password.text.isNotEmpty) {
      requestBody['password'] = password.text;
    }
    final response = await http.post(
      Uri.parse("https://misqot.repit.tech/api/users/update/$userId"),
      body: requestBody,
      headers: headers,
    );
    if (response.statusCode == 200) {
      if (password.text.isNotEmpty) {
        // Password is updated, log the user out
        _logout(context);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data Berhasil Diubah")),
      );
    } else {
      // Pembaruan gagal
      // ...
    }
  }


  Future<void> uploadFile(File file, String userId) async {
    final url = Uri.parse("https://misqot.repit.tech/api/users/update/$userId");
    final request = http.MultipartRequest('POST', url);

    // Kompresi gambar sebelum mengupload
    List<int> compressedBytes = await FlutterImageCompress.compressWithList(
      file.readAsBytesSync(),
      minHeight: 1920, // Sesuaikan dengan kebutuhan
      minWidth: 1080, // Sesuaikan dengan kebutuhan
      quality: 80, // Sesuaikan dengan kebutuhan
      rotate: 0, // Rotasi gambar jika diperlukan
    );

    String getUniqueFileName(File file) {
      // Mendapatkan timestamp saat ini
      DateTime now = DateTime.now();
      // Format timestamp sebagai string dan gabungkan dengan ekstensi file asli
      String timestamp = now.toIso8601String();
      String originalFileName = file.path.split('/').last;
      String uniqueFileName = '$timestamp-$originalFileName';
      return uniqueFileName;
    }

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        compressedBytes,
          filename: getUniqueFileName(file)
      ),
    );
     await http.Response.fromStream(await request.send());
  }

  void pickFile(String userId) async {
    try {
      setState(() {
        isLoading = true;
      });
      result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null) {
        _fileName = result!.files.first.name;
        pickedfile = result!.files.first;
        fileToDisplay = File(pickedfile!.path.toString());

        // Periksa ukuran file sebelum kompresi
        if (fileToDisplay!.lengthSync() > 500 * 1024) {
          // Ukuran file di atas 500KB, tampilkan pesan kesalahan
          setState(() {
            isLoading = false;
          });
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Error"),
                content: const Text("Ukuran file melebihi batas 500KB."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
          return;
        }
        // Upload file ke API Laravel
        await uploadFile(fileToDisplay!, userId);
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
    }
  }




  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var width = size.width;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text("Edit Data User"),
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Center(
                child: Stack(
                  children: [
                    InstaImageViewer(
                      child: SizedBox(
                        height: 200,
                        width: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: FutureBuilder(
                              future: _image,
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else {
                                  if (snapshot.hasData) {
                                    return CachedNetworkImage(
                                      imageUrl:
                                      "https://misqot.repit.tech/storage/profile-image/${snapshot.data!}",
                                      placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                      imageBuilder: (context, imageProvider) => Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const Text("-");
                                  }
                                }
                              }),
                        ),
                      ),
                    ),
                    FutureBuilder(
                        future: _id,
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else {
                            if (snapshot.hasData) {
                              return Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => pickFile(snapshot.data!),
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),color: Colors.blue),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return const Text("-");
                            }
                          }
                        }),

                  ],
                ),
              ),

              Column(
                children: [
                  SizedBox(
                    width: width,
                    height: 200,
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25)),
                    child: Container(
                      color: Colors.white,
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                FutureBuilder(
                                  future: _name,
                                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else {
                                      if (snapshot.hasData) {
                                        // Update the controller's text only when needed (e.g., when form is submitted)
                                        if (name.text.isEmpty) {
                                          name.text = snapshot.data!;
                                        }

                                        return Card(
                                          elevation: 5,
                                          child: TextFormField(
                                            controller: name,
                                            decoration: const InputDecoration(labelText: "Nama User"),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return "Masukan Nama user";
                                              }
                                              return null;
                                            },
                                          ),
                                        );
                                      } else {
                                        return const Text("-");
                                      }
                                    }
                                  },
                                ), FutureBuilder(
                                  future: _email,
                                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else {
                                      if (snapshot.hasData) {
                                        // Update the controller's text only when needed (e.g., when form is submitted)
                                        if (email.text.isEmpty) {
                                          email.text = snapshot.data!;
                                        }

                                        return Card(
                                          elevation: 5,
                                          child: TextFormField(
                                            controller: email,
                                            decoration: const InputDecoration(labelText: "Nama User"),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return "Masukan Nama user";
                                              }
                                              return null;
                                            },
                                          ),
                                        );
                                      } else {
                                        return const Text("-");
                                      }
                                    }
                                  },
                                ),
                                if (changePassword == true)
                                  _changePassword(),
                                FutureBuilder(
                                  future: _kelamin,
                                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else {
                                      if (snapshot.hasData) {
                                        // Update the controller's text only when needed (e.g., when form is submitted)
                                        if (kelamin.text.isEmpty) {
                                          kelamin.text = snapshot.data!;
                                        }

                                        return Card(
                                          elevation: 5,
                                          child: TextFormField(
                                            controller: kelamin,
                                            decoration: const InputDecoration(labelText: "Sex"),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return "Insert Sex";
                                              }
                                              return null;
                                            },
                                          ),
                                        );
                                      } else {
                                        return const Text("-");
                                      }
                                    }
                                  },
                                ), FutureBuilder(
                                  future: _agama,
                                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else {
                                      if (snapshot.hasData) {
                                        // Update the controller's text only when needed (e.g., when form is submitted)
                                        if (agama.text.isEmpty) {
                                          agama.text = snapshot.data!;
                                        }

                                        return Card(
                                          elevation: 5,
                                          child: TextFormField(
                                            controller: agama,
                                            decoration: const InputDecoration(labelText: "Religion"),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return "Insert Religion";
                                              }
                                              return null;
                                            },
                                          ),
                                        );
                                      } else {
                                        return const Text("-");
                                      }
                                    }
                                  },
                                ), FutureBuilder(
                                  future: _alamat,
                                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else {
                                      if (snapshot.hasData) {
                                        // Update the controller's text only when needed (e.g., when form is submitted)
                                        if (alamat.text.isEmpty) {
                                          alamat.text = snapshot.data!;
                                        }

                                        return Card(
                                          elevation: 5,
                                          child: TextFormField(
                                            keyboardType: TextInputType.multiline,
                                            maxLines: null,
                                            controller: alamat,
                                            decoration: const InputDecoration(labelText: "Address"),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return "Insert Address";
                                              }
                                              return null;
                                            },
                                          ),
                                        );
                                      } else {
                                        return const Text("-");
                                      }
                                    }
                                  },
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FutureBuilder(
                                        future: _id,
                                        builder: (BuildContext context,
                                            AsyncSnapshot<String> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
                                          } else {
                                            if (snapshot.hasData) {
                                              return ElevatedButton(
                                                onPressed: () {
                                                  if (_formKey.currentState!.validate()) {
                                                    if (password.text == confirmPassword.text) {
                                                      updateData(snapshot.data!);
                                                      Navigator.pop(context);
                                                            ScaffoldMessenger.of(context)
                                                                .showSnackBar(const SnackBar(
                                                                content: Text(
                                                                    "Data Berhasil Dibuah")));
                                                    } else {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(content: Text("Passwords do not match")),
                                                      );
                                                    }
                                                  } else {}
                                                  // saveData();
                                                },
                                                child: const Text('Save'),
                                              );
                                            } else {
                                              return const Text("-");
                                            }
                                          }
                                        }),

                                    IconButton(onPressed: () {
                                      if (changePassword == false){
                                        setState(() {
                                          changePassword = true;
                                        });
                                      }else{
                                        setState(() {
                                          changePassword = false;
                                        });
                                      }
                                    }, icon: const Icon(Icons.key))
                                  ],
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
  Widget _changePassword(){
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            obscureText: true,
            controller: password,
            decoration: const InputDecoration(
                labelText: "Password", icon: Icon(Icons.password)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Enter Password";
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            controller: confirmPassword,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Confirm Password",
              icon: Icon(Icons.password_sharp),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter Confirm Password";
              } else if (value != password.text) {
                return "Passwords do not match";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
