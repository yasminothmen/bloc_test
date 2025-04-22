import 'package:bloc_test/presentation_layer/Screens/Home.dart';

import '../../pages/home_page.dart';
import '../Screens/WebSocketPage.dart';
import '../Screens/profile_page.dart';
import '../Screens/schedulescreen.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class Navbarstudent extends StatefulWidget {
  const Navbarstudent({super.key});

  @override
  State<Navbarstudent> createState() => _NavbarstudentState();
}

class _NavbarstudentState extends State<Navbarstudent> {
  int selectedIndex = 2;

  final List<Widget> tabBarPages = [
    HomePage(),
    WebSocketPage(),
    HomePage(),
    EmploiDuTempsScreen(),
    ProfilePage(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabBarPages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.white,
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(IconlyBold.play), label: "Courses"),
          BottomNavigationBarItem(icon: Icon(IconlyBold.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(IconlyBold.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(IconlyBold.calendar), label: "Schedule"),
          BottomNavigationBarItem(
              icon: Icon(IconlyBold.profile), label: "Profile"),
        ],
      ),
    );
  }
}
