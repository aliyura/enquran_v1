import 'package:flutter/material.dart';
import 'package:enquran/screens/main_drawer.dart';
import 'package:enquran/screens/quran_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: MainDrawer(),
      ),
      body: QuranScreen(),
    );
  }
}
