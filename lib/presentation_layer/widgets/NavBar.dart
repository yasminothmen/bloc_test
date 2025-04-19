import 'package:bloc_test/pages/home_page.dart';
import 'package:bloc_test/presentation_layer/Screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class MainTabBarPage extends StatefulWidget {
  const MainTabBarPage({super.key}); // Retirez le paramètre userRole

  @override
  State<MainTabBarPage> createState() => _MainTabBarPageState();
}

class _MainTabBarPageState extends State<MainTabBarPage> {
  int selectedIndex = 2;

  final List<Widget> tabBarPages = [
    HomePage(),
    HomePage(),
    HomePage(),
    HomePage(),
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
          BottomNavigationBarItem(icon: Icon(IconlyBold.buy), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(IconlyBold.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(IconlyBold.bookmark), label: "My Courses"),
          BottomNavigationBarItem(
              icon: Icon(IconlyBold.profile), label: "Profile"),
        ],
      ),
    );
  }
}
