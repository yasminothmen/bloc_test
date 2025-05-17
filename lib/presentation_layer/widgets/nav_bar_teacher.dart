import '../Screens/cours_of_teacher.dart';
import '../Screens/HomeTeacher.dart';
import '../Screens/ListDiscussion.dart';
import '../Screens/profile_page.dart';
import '../Screens/EmploiTeacher.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class Navbarteacher extends StatefulWidget {
  const Navbarteacher({super.key});

  @override
  State<Navbarteacher> createState() => _NavbarteacherState();
}

class _NavbarteacherState extends State<Navbarteacher> {
  int selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    final tabBarPages = [
      CoursOfTeacher(),
      Listdiscussion(),
      Hometeacher(),
      EmploiTeacher(),
      ProfilePage(),
    ];

    return Scaffold(
      body: tabBarPages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.white,
        currentIndex: selectedIndex,
        onTap: (index) {
          if (index == 1) {
            
          }
          setState(() => selectedIndex = index);
        },
        
        items: const [
          BottomNavigationBarItem(
              icon: Icon(IconlyBold.play), label: "Cours"),
          BottomNavigationBarItem(icon: Icon(IconlyBold.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(IconlyBold.home), label: "Acceuil"),
          BottomNavigationBarItem(
              icon: Icon(IconlyBold.calendar), label: "Emploi"),
          BottomNavigationBarItem(
              icon: Icon(IconlyBold.profile), label: "Profile"),
        ],
      ),
    );
  }
}
