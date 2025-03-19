import 'package:bloc_test/presentation_layer/bloc/workshop_bloc.dart';
import 'package:bloc_test/presentation_layer/widgets/AllWorkshopsTab.dart';
import 'package:bloc_test/presentation_layer/widgets/CreateWorkshopTab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class WorkshopsScreen extends StatelessWidget {
  const WorkshopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkshopBloc(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Workshops'),
            // tabBar hedha pour switcher entre les deux
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
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
              BottomNavigationBarItem(icon: Icon(Icons.workspaces), label: 'Workshops'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}
