import 'package:flutter/material.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:hidden_drawer_menu/model/item_hidden_menu.dart';
import 'package:hidden_drawer_menu/model/screen_hidden_drawer.dart';

import '../Task/TaskPage.dart';

class HiddenDrawer extends StatefulWidget {
  const HiddenDrawer({super.key});

  @override
  State<HiddenDrawer> createState() => _HiddenDrawerState();
}

class _HiddenDrawerState extends State<HiddenDrawer> {
  List<ScreenHiddenDrawer> _pages = [];

  void initState(){
    super.initState();

    _pages = [
      ScreenHiddenDrawer(ItemHiddenMenu(
        name: "HomePage",
        baseStyle: TextStyle(),
        selectedStyle: TextStyle(),
      ), TaskPage())
    ];

  }

  @override
  Widget build(BuildContext context) {
    return HiddenDrawerMenu(
      backgroundColorMenu: Colors.blue,
      screens: _pages,
      initPositionSelected: 0,
    );
  }
}
