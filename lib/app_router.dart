import 'presentation_layer/Screens/LoginPage.dart';
import 'presentation_layer/Screens/WorkshopsScreen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => LoginScreen());
     
      case '/workshop':
        return MaterialPageRoute(builder: (_) => WorkshopsScreen());

       
    }
    return null;
  }
}
