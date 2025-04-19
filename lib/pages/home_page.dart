import 'package:bloc_test/model/user.dart';
import 'package:bloc_test/presentation_layer/bloc/auth_bloc.dart';
import 'package:bloc_test/presentation_layer/bloc/auth_state.dart';
import 'package:bloc_test/presentation_layer/widgets/course_slider.dart';
import 'package:bloc_test/presentation_layer/widgets/header_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Récupérer l'utilisateur depuis l'état authentifié
        AppUser? user;
        if (state is Authenticated) {
          user = state.user;
        }
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: appBar(user),
          body: ListView(
            children: [
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
                      child: Column(
                        children: [
                          searchBox(),
                          const SizedBox(
                            height: 10,
                          ),
                          HeaderTextField(title: "Mes Cours"),
                          const CourseSlider(),
                          HeaderTextField(title: "Les Plus Populaires"),
                          const CourseSlider()
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  TextField searchBox() {
    return TextField(
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
          filled: true,
          border: OutlineInputBorder(
              borderSide: const BorderSide(width: 0, style: BorderStyle.none),
              borderRadius: BorderRadius.circular(10)),
          fillColor: Colors.black,
          suffixIcon: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.grey, borderRadius: BorderRadius.circular(10)),
            child: const Icon(
              IconlyLight.search,
              color: Colors.white,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: "Recherche ",
          hintStyle:
              TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
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
                      "Apprenez quelque chose de nouveau",
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
