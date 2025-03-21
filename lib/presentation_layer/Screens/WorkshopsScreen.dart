import 'package:bloc_test/presentation_layer/bloc/workshop_bloc.dart';
import 'package:bloc_test/presentation_layer/widgets/AllWorkshopsTab.dart';
import 'package:bloc_test/presentation_layer/widgets/CreateWorkshopTab.dart';
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
          appBar: AppBar(
            title: const Text('Workshops'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Create workshop'),
                Tab(text: 'All workshops'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              CreateWorkshopTab(),
              AllWorkshopsTab(),
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
                "assets/images/commentaire-alt.png",
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
            color: Color(0xff246BFD),
            height: 55,
            buttonBackgroundColor:Color(0xff246BFD),
            backgroundColor: Colors.white,
            animationCurve: Curves.easeInBack,
            animationDuration: const Duration(milliseconds: 400),
            onTap: (index) {
              setState(() {
                _page = index;
              });
            },
            letIndexChange: (index) => true,
          ),
        ),
      ),
    );
  }
}
