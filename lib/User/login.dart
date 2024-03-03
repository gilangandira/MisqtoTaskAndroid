import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as myAPI;
import '../Navbar/Home.dart';
import 'AuthLogin.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _name, _token, _role;

  @override
  void initState() {
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });
    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });
    _role = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("role") ?? "";
    });
    checkToken(_token, _name, _role);
  }

  checkToken(token, name, role) async {
    String tokenStr = await token;
    String nameStr = await name;
    String roleStr = await role;

    if (mounted) {
      if (tokenStr != "" && nameStr != "" && roleStr != "") {
        Future.delayed(const Duration(seconds: 0), () async {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const Home()));
        });
      }
    }
  }

  Future login(
    email,
    password,
  ) async {
    AuthLogin? authLogin;
    String fcm = "";
    await FirebaseMessaging.instance.getToken().then((value) => fcm = value!);
    Map<String, String> body = {
      "email": email,
      "password": password,
      'fcm_token': fcm
    };
    var response = await myAPI.post(Uri.parse("https://misqot.repit.tech/api/login"), body: body);
    if (mounted) {
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email atau Password Salah")));
      } else {
        authLogin = AuthLogin.fromJson(json.decode(response.body));
        saveUser(
          authLogin.data.id,
          authLogin.data.token,
          authLogin.data.name,
          authLogin.data.email,
          authLogin.data.image,
          authLogin.data.role,
          authLogin.data.kelamin,
          authLogin.data.agama,
          authLogin.data.jabatan,
          authLogin.data.alamat,
        );
      }
    }
  }

  Future saveUser(
    id,
    token,
    name,
    email,
    image,
    role,
    kelamin,
    agama,
    jabatan,
    alamat,
  ) async {
    try {
      final SharedPreferences pref = await _prefs;
      pref.setString("id", id);
      pref.setString("name", name);
      pref.setString("token", token);
      pref.setString("email", email);
      pref.setString("role", role);
      pref.setString("kelamin", kelamin);
      pref.setString("agama", agama);
      pref.setString("jabatan", jabatan);
      pref.setString("alamat", alamat);
      pref.setString("image", image);

      if (mounted) {
        Navigator.of(context)
            .pushReplacement(
                MaterialPageRoute(builder: (context) => const Home()))
            .then((value) => (value));
      }
    } catch (err) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    String colors1 = "#0062ff";
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(children: [
        Stack(
          children: [
            Positioned(
                top: -25,
                left: -30,
                child: Container(
                  height: 175,
                  width: 175,
                  decoration: BoxDecoration(
                    color: HexColor(colors1),
                    borderRadius: BorderRadius.circular(300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                )),
            Positioned(
                top: -70,
                left: 80,
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                    color: HexColor(colors1),
                    borderRadius: BorderRadius.circular(300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                )),
            Positioned(
                top: -25,
                right: -30,
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: HexColor(colors1),
                    borderRadius: BorderRadius.circular(300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                )),
            Positioned(
                bottom: -100,
                left: 80,
                child: Container(
                  height: 175,
                  width: 175,
                  decoration: BoxDecoration(
                    color: HexColor(colors1),
                    borderRadius: BorderRadius.circular(300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                )),

            ////////////////Bawah
            Positioned(
                bottom: -70,
                left: -120,
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                    color: HexColor(colors1),
                    borderRadius: BorderRadius.circular(300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                )),
          ],
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'MISQOT',
                    style: TextStyle(fontSize: 30, color: HexColor(colors1)),
                  ),
                ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 60),
                    child: Text(
                      'SEJAHTERA INDONESIA',
                      style:
                          TextStyle(fontSize: 30, color: HexColor(colors1)),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  decoration: BoxDecoration(
                      border: Border.all(color: HexColor(colors1)),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Username',
                        border: InputBorder.none,
                        suffixIcon: const Icon(Icons.email),
                        suffixIconColor: HexColor(colors1)),
                    controller: emailController,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  decoration: BoxDecoration(
                      border: Border.all(color: HexColor(colors1)),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: 'Password',
                        border: InputBorder.none,
                        suffixIcon: const Icon(Icons.lock),
                        suffixIconColor: HexColor(colors1)),
                    controller: passwordController,
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: HexColor(colors1),
                          elevation: 10,
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(fontSize: 25)),
                      onPressed: () {
                        login(
                          emailController.text,
                          passwordController.text,
                        );
                      },
                      child: const Text("Login",style: TextStyle(color: Colors.white),)),
                )
              ]),
        ),
      ]),
    );
  }
}

// Code tersebut adalah kode Flutter yang berfungsi untuk membuat halaman login pada aplikasi Flutter. Berikut adalah penjelasan rinci dari setiap baris kode:

// import statement: Pada bagian ini, diimpor beberapa package yang dibutuhkan oleh class ini, yaitu dart:convert, flutter/material.dart, shared_preferences.dart, dan http.dart.
// class LoginPage extends StatefulWidget: Mendefinisikan class LoginPage sebagai sebuah StatefulWidget, dimana State-nya dapat diubah.
// TextEditingController emailController = TextEditingController(); dan TextEditingController passwordController = TextEditingController();: Membuat instance TextEditingController untuk controller email dan password.
// final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();: Membuat instance _prefs yang bertipe Future<SharedPreferences> untuk menyimpan nilai shared preferences pada aplikasi.
// late Future<String> _name, _token;: Membuat instance _name dan _token yang bertipe Future<String>.
// void initState(): Fungsi yang dipanggil saat widget pertama kali dibuat, di mana akan diinisialisasi nilai _token dan _name dengan data dari shared preferences.
// checkToken(token, name) async: Fungsi yang digunakan untuk memeriksa apakah terdapat token dan nama pada shared preferences. Jika terdapat token dan nama, maka user akan langsung diarahkan ke halaman home setelah 1 detik. Fungsi ini merupakan fungsi asynchronous karena menggunakan await.
// Future Login(email, password) async: Fungsi untuk mengirimkan permintaan ke server untuk melakukan login. Fungsi ini menggunakan package http untuk mengirimkan permintaan POST ke server. Jika permintaan berhasil, maka token dan nama akan disimpan pada shared preferences, dan user akan diarahkan ke halaman home. Jika gagal, maka akan muncul snackbar dengan pesan "Email atau Password Salah".
// Future saveUser(token, name) async: Fungsi untuk menyimpan token dan nama pada shared preferences. Jika berhasil, maka user akan diarahkan ke halaman home. Jika gagal, maka akan muncul snackbar dengan pesan kesalahan.
// Widget build(BuildContext context): Fungsi untuk membangun tampilan halaman login. Fungsi ini mengembalikan widget Scaffold yang berisi SafeArea dan Container yang berisi Column. Pada Column, terdapat Text untuk judul halaman, TextField untuk input email dan password, dan ElevatedButton untuk melakukan login. Ketika tombol login ditekan, maka fungsi Login akan dipanggil untuk mengirimkan permintaan login ke server.
