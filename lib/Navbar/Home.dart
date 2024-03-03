
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/Customer/CustomersPage.dart';
import '../Assets/AssetsPage.dart';
import '../Task/TaskPage.dart';
import 'AdminMenu.dart';
import 'BottomNavigation.dart';
import 'MemberSideMenu.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TaskPage(),
    const AssetsPage(),
    const CustomerPage(),
    Settings()
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBottom(_currentIndex, _onTabTapped),
      body: _screens[_currentIndex],
    );
  }
}



class Settings extends StatefulWidget {
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
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
    return FutureBuilder<String>(
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
            final userRole = snapshot.data ?? ""; // Ambil nilai peran pengguna dari snapshot
            if (userRole == 'admin') {
              return const AdminSideMenu(); // Tampilkan drawer admin jika peran adalah admin
            } else {
              return const SideMenu(); // Tampilkan drawer member jika peran adalah member
            }
          }
        }
      },
    );
  }
}
