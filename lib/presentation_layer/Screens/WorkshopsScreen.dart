import 'package:bloc_test/presentation_layer/bloc/workshop_bloc.dart';
import 'package:bloc_test/presentation_layer/widgets/AllWorkshopsTab.dart';
import 'package:bloc_test/presentation_layer/widgets/CreateWorkshopTab.dart';
import 'package:bloc_test/presentation_layer/Screens/WebSocketPage.dart'; // 👈 Assure-toi que ce fichier existe
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class WorkshopsScreen extends StatefulWidget {
  const WorkshopsScreen({super.key});

  @override
  _WorkshopsScreenState createState() => _WorkshopsScreenState();
}

class _WorkshopsScreenState extends State<WorkshopsScreen> {
  int _page = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkshopBloc(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: null,
          body: Column(
            children: [
              Container(
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A3A5F),
                  borderRadius: BorderRadius.vertical(),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(15),
                      ),
                    ),
                    child: TabBar(
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 3.0,
                        ),
                        insets: EdgeInsets.only(bottom: 10),
                      ),
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                      ),
                      tabs: const [
                        Tab(text: 'Create workshop'),
                        Tab(text: 'All workshops'),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: const TabBarView(
                  children: [
                    CreateWorkshopTab(),
                    AllWorkshopsTab(),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: CurvedNavigationBar(
            key: _bottomNavigationKey,
            index: _page,
            items: <Widget>[
              Image.asset(
                "assets/images/maison.png",
                width: 25,
                height: 25,
                color: Colors.white,
              ),
              Image.asset(
                "assets/images/commentaire-alt.png", // 👈 Ce bouton déclenchera la navigation
                width: 25,
                height: 25,
                color: Colors.white,
              ),
              Image.asset(
                "assets/images/applications.png",
                width: 25,
                height: 25,
                color: Colors.white,
              ),
              Image.asset(
                "assets/images/utilisateur (2).png",
                width: 25,
                height: 25,
                color: Colors.white,
              ),
            ],
            color: const Color(0xFF1A3A5F),
            height: 55,
            buttonBackgroundColor: const Color(0xFF1A3A5F),
            backgroundColor: Colors.white,
            animationCurve: Curves.easeInOut,
            animationDuration: const Duration(milliseconds: 400),
            onTap: (index) {
              setState(() {
                _page = index;
              });

              if (index == 1) {
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebSocketPage(), 
                  ),
                );
              }

              // Tu peux ajouter d’autres actions pour les autres boutons si tu veux
            },
            letIndexChange: (index) => true,
          ),
        ),
      ),
    );
  }
}
