import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:bloc_test/app_router.dart';
import 'package:bloc_test/presentation_layer/Screens/LoginPage.dart';
import 'package:bloc_test/presentation_layer/Screens/ProfileScreen.dart';
import 'package:bloc_test/presentation_layer/Screens/WorkshopsScreen.dart';
import 'package:bloc_test/presentation_layer/bloc/auth_bloc.dart';
import 'package:bloc_test/themes.dart';
import 'package:bloc_test/utils/user_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/repositories/AuthRepository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ✅ Initialize Firebase before app runs
 WidgetsFlutterBinding.ensureInitialized(); // Assure l'initialisation des plugins
  await UserPreferences.init(); // Initialise SharedPreferences
  runApp(MyApp(
    appRouter: AppRouter(),
  ));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter; // ✅ Initialisation correcte

  const MyApp({super.key, required this.appRouter}); // Ajout d'un constructeur

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AuthRepository(),
      child: BlocProvider(
        create: (context) => AuthBloc(
          authRepository: RepositoryProvider.of<AuthRepository>(context),
        ),
        child: MaterialApp(
          title: "Flutter Demo",
          debugShowCheckedModeBanner: false,
          // onGenerateRoute:
          //     appRouter.generateRoute, // ✅ Utilisation correcte d'une instance
          home: LoginScreen(),
        ),
      ),
    );
  }
}
