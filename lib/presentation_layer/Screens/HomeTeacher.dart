import '../../model/user.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/header_text_field.dart';
import 'package:iconly/iconly.dart';
import '../bloc/workshop_bloc.dart';
import '../widgets/CreateWorkshopTab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Hometeacher extends StatefulWidget {
  const Hometeacher({super.key});

  @override
  _HometeacherState createState() => _HometeacherState();
}

class _HometeacherState extends State<Hometeacher> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WorkshopBloc(),
      child: DefaultTabController(
        length: 2,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            AppUser? user;
            if (state is Authenticated) {
              user = state.user;
            }
            return Scaffold(
              backgroundColor: Colors.black,
              appBar: appBar(user),
              body: ListView(children: [
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(children: [
                          HeaderTextField(title: "Veuillez creer votre cour"),
                          CreateWorkshopTab(),
                        ]),
                      ),
                    ),
                  ],
                ),
              ]),
            );
          },
        ),
      ),
    );
  }

  AppBar appBar(AppUser? user) {
    return AppBar(
      backgroundColor: Colors.black,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user != null
                          ? "Bienvenue ${user.firstname},"
                          : "Bienvenue,",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 22),
                    ),
                    const Text(
                      "Aidez vos élèves à apprendre",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 14),
                    ),
                  ],
                ),
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey,
                                spreadRadius: 2,
                                blurStyle: BlurStyle.outer)
                          ]),
                      child: const Icon(
                        IconlyLight.notification,
                        size: 26,
                      ),
                    ),
                    Positioned(
                        top: 0,
                        right: 8,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
