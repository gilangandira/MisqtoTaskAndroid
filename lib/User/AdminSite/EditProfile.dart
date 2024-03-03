import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as myAPI;
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../Navbar/Home.dart';
import 'ListProfile.dart';


class EditProfile extends StatefulWidget {
  final Map user;

  EditProfile({super.key, required this.user});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  FilePickerResult? result;
  String? _fileName;
  PlatformFile? pickedfile;
  bool changePassword = false;
  File? fileToDisplay;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _role = TextEditingController();
  final TextEditingController _kelamin = TextEditingController();
  final TextEditingController _agama = TextEditingController();
  final TextEditingController _jabatan = TextEditingController();
  final TextEditingController _alamat = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
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
    final response = await myAPI.post(
        Uri.parse("https://misqot.repit.tech/api/users/update/" + widget.user['id']),
        body: {
          'name': _name.text,
          'email': _email.text,
          'role': _role.text,
          'kelamin': _kelamin.text,
          'agama': _agama.text,
          'jabatan': _jabatan.text,
          'alamat': _alamat.text,
        },
        headers: headers);
    return json.decode(response.body);
  }

  Future<void> uploadFile(File file) async {
    final url = Uri.parse("https://misqot.repit.tech/api/users/update/" + widget.user['id']);
    final request = myAPI.MultipartRequest('POST', url);

    // Kompresi gambar sebelum mengupload
    List<int> compressedBytes = await FlutterImageCompress.compressWithList(
      file.readAsBytesSync(),
      minHeight: 1920, // Sesuaikan dengan kebutuhan
      minWidth: 1080, // Sesuaikan dengan kebutuhan
      quality: 80, // Sesuaikan dengan kebutuhan
      rotate: 0, // Rotasi gambar jika diperlukan
    );

    request.files.add(
      myAPI.MultipartFile.fromBytes(
        'image',
        compressedBytes,
        filename: file.path.split('/').last,
      ),
    );

    try {
      final response = await myAPI.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        print('File uploaded successfully');
      } else {
        print('File upload failed');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  void pickFile() async {
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
        await uploadFile(fileToDisplay!);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text("Edit Data User"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              // alignment: Alignment.center,
              children: [
                Center(
                  child: Stack(
                    children: [
                      InstaImageViewer(
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl:
                              "https://misqot.repit.tech/storage/profile-image/${widget.user['image']}",
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
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: pickFile,
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: const BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),color: Colors.blue
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
                Column(
                  children: [
                    // SizedBox(
                    //   width: width,
                    //   height: 200,
                    // ),
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      child: Container(
                        color: Colors.white,
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Card(
                                    elevation: 5,
                                    child: TextFormField(
                                      controller: _name..text = widget.user['name'],
                                      decoration: const InputDecoration(
                                          labelText: "Nama User"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Masukan Nama user";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Card(
                                    elevation: 5,
                                    child: TextFormField(
                                      controller: _email
                                        ..text = widget.user['email'],
                                      decoration:
                                      const InputDecoration(labelText: "Email"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Masukan PPOE Username";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  if (changePassword == true)
                                    _changePassword(),
                                  Card(
                                    elevation: 5,
                                    child: TextFormField(
                                      controller: _role..text = widget.user['role'],
                                      decoration:
                                      const InputDecoration(labelText: "Role"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Masukan PPOE Password";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Card(
                                    elevation: 5,
                                    child: TextFormField(
                                      controller: _kelamin
                                        ..text = widget.user['kelamin'],
                                      decoration: const InputDecoration(
                                          labelText: "Jenis Kelamin"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Masukan AP SSID";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Card(
                                    elevation: 5,
                                    child: TextFormField(
                                      controller: _agama
                                        ..text = widget.user['agama'] ?? '',
                                      decoration:
                                      const InputDecoration(labelText: "Agama"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Masukan Channel Frequensy";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Card(
                                    elevation: 5,
                                    child: TextFormField(
                                      controller: _jabatan
                                        ..text = widget.user['jabatan'] ?? '',
                                      decoration: const InputDecoration(
                                          labelText: "Jabatan"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Masukan Subscription Fee";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Card(
                                    elevation: 5,
                                    child: TextFormField(
                                      controller: _alamat
                                        ..text = widget.user['alamat'] ?? '',
                                      decoration: const InputDecoration(
                                          labelText: "Alamat"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Masukan Location";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [

                                      ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!.validate()) {
                                            if (password.text == confirmPassword.text) {
                                              updateData();
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
                                      ),

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
