import 'package:flutter/material.dart';
import 'package:hadil_project/Screens/ContactScreen.dart';
import 'package:hadil_project/Screens/homepage.dart';
import 'package:hadil_project/Screens/position.dart';
import 'package:hadil_project/components/container.dart';
import 'package:hadil_project/Screens/health.dart';

class first_screen extends StatefulWidget {
  const first_screen({Key? key}) : super(key: key);

  @override
  State<first_screen> createState() => _first_screenState();
}

class _first_screenState extends State<first_screen> {
  int _selectedScreenIndex = 0;
  final List _screens = [
    {"screen": const homepage(), "title": "Home Screen"},
    {"screen": const ContactScreen(), "title": "Emergency Call"}
  ];

  void _selectScreen(int index) {
    setState(() {
      _selectedScreenIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size size = mediaQuery.size;


    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.grey,
        title: Text(_screens[_selectedScreenIndex]["title"],style: TextStyle(color: Colors.black),),
        titleSpacing: 00.0,
        centerTitle: true,
        toolbarHeight: 60.2,
        toolbarOpacity: 0.8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(25),
              bottomLeft: Radius.circular(25)),
        ),
        elevation: 0.00,
        leading: IconButton(color: Colors.black,
          icon: const Icon(Icons.settings_rounded),
          tooltip: 'Menu Icon',
          onPressed: () {},
        ),
      ),
      body:_screens[_selectedScreenIndex]["screen"],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedScreenIndex,
        onTap: _selectScreen,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: "Call")
        ],
      ),

    );
  }
}
