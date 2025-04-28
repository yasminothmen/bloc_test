import '../Screens/ListDiscussion.dart';
import '../Screens/profile_page.dart';
import '../Screens/EmploiStudent.dart';
import '../../services/api_service.dart';
import 'package:dio/dio.dart';
import '../../pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class Navbarstudent extends StatefulWidget {
  const Navbarstudent({super.key});

  @override
  State<Navbarstudent> createState() => _NavbarstudentState();
}

class _NavbarstudentState extends State<Navbarstudent> {
  int selectedIndex = 2;
  List<PdfInfo> pdfList = [];
  bool isLoading = false;

  Future<void> _fetchEmploiData() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiService.instance.get(
        '/api/pdf-storage',
        queryParameters: {
          'entityType': 'class', 
          'entityName': 'GLSI' 
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List ? response.data : [];
        setState(() {
          pdfList = data
              .map<PdfInfo>((item) => PdfInfo(
                    fileUrl: item['fileUrl'] ?? '',
                    fileName: item['fileName'] ?? 'Document sans nom',
                  ))
              .toList();
        });
      } else {
        throw Exception('Statut HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Erreur Dio: ${e.response?.data ?? e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Erreur: ${e.response?.data['message'] ?? e.message}')),
      );
    } catch (e) {
      print('Erreur générale: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabBarPages = [
      HomePage(),
      Listdiscussion(),
      HomePage(),
      Emploistudent(),
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

class PdfInfo {
  final String fileUrl;
  final String fileName;

  PdfInfo({required this.fileUrl, required this.fileName});
}
