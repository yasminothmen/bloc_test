import 'package:bloc_test/presentation_layer/Screens/HomePage.dart';
import 'package:bloc_test/presentation_layer/Screens/LoginPage.dart';
import 'package:bloc_test/presentation_layer/Screens/WorkshopsScreen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/homepage':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/workshop':
        return MaterialPageRoute(builder: (_) => WorkshopsScreen());

       
    }
    return null;
  }
}
