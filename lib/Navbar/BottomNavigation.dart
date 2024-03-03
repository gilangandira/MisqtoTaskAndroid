import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class NavigationBottom extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  NavigationBottom(this.currentIndex, this.onTabTapped);

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: Colors.white,
      animationDuration: Duration(milliseconds: 300),
      color: Colors.blue,
      onTap: onTabTapped,
      index: currentIndex, // Set currentIndex di sini
      items: [
        Icon(Icons.home, size: 30), // Ikon Beranda
        Icon(Icons.business, size: 30), // Ikon Profil
        Icon(Icons.people, size: 30), // Ikon Pengaturan
        Icon(Icons.menu, size: 30), // Ikon Pengaturan
      ],
    );
  }
}
