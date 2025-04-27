import 'package:bloc_test/presentation_layer/Screens/HomeTeacher.dart';
import 'package:bloc_test/presentation_layer/Screens/ListDiscussion.dart';
import 'package:bloc_test/presentation_layer/widgets/CreateWorkshopTab.dart';
import 'package:bloc_test/services/api_service.dart';

import '../../pages/home_page.dart';
import '../Screens/WebSocketPage.dart';
import '../Screens/profile_page.dart';
import '../Screens/schedulescreen.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class Navbarteacher extends StatefulWidget {
  const Navbarteacher({super.key});

  @override
  State<Navbarteacher> createState() => _NavbarteacherState();
}

class _NavbarteacherState extends State<Navbarteacher> {
  int selectedIndex = 2;
  String? fileUrl;
  String? fileName;
  bool isLoading = false;

  Future<void> _fetchEmploiData() async {
    setState(() => isLoading = true);
    try {
      // Remplacer par votre appel API réel
      final response = await ApiService.instance.get('/api/pdf-storage');
      setState(() {
        fileUrl = response.data['fileUrl'];
        fileName = response.data['fileName'];
      });
    } catch (e) {
      // Gérer l'erreur
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabBarPages = [
      CreateWorkshopTab(),
      Listdiscussion(),
      Hometeacher(),
      isLoading
          ? const Center(child: CircularProgressIndicator())
          : (fileUrl != null && fileName != null)
              ? EmploiScreen(
                  fileUrl: fileUrl!,
                  fileName: fileName!,
                )
              : const Center(child: Text('Aucun emploi du temps disponible')),
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
          if (index == 3) {
            // Index de l'onglet Schedule
            _fetchEmploiData();
          }
          setState(() => selectedIndex = index);
        },
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
