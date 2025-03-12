import 'package:bloc_test/presentation_layer/Screens/LoginPage.dart';
import 'package:bloc_test/presentation_layer/bloc/auth_bloc.dart';
import 'package:bloc_test/presentation_layer/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to the Home Screen!"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                BlocProvider.of<AuthBloc>(context).add(LogoutRequested());
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}

