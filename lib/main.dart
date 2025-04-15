import 'package:bloc_test/presentation_layer/Screens/profile_page.dart';
import 'package:bloc_test/presentation_layer/Screens/schedulescreen.dart';

import 'app_router.dart';
import 'presentation_layer/Screens/Chat1.dart';
import 'presentation_layer/Screens/Home.dart';
import 'presentation_layer/Screens/LoginPage.dart';
import 'presentation_layer/Screens/WorkshopsScreen.dart';
import 'presentation_layer/Screens/student_home_page.dart';

import 'presentation_layer/bloc/auth_bloc.dart';
import 'presentation_layer/bloc/auth_state.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/repositories/AuthRepository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 
  WidgetsFlutterBinding
      .ensureInitialized();
  
  runApp(MyApp(
    appRouter: AppRouter(),
  ));
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter; 

  const MyApp({super.key, required this.appRouter}); 

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
          onGenerateRoute:
              appRouter.generateRoute, 
          home: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
            if (state is Authenticated) {
              // Redirection basée sur le rôle
              if (state.user.role == 'teacher') {
                return WorkshopsScreen();
              } else {
                return StudentHomePage();
              }
            } else if (state is UnAuthenticated) {
              return LoginScreen();
            }
            return LoginScreen();
          }
          ),
      //      home: BlocProvider(
      //   create: (context) => WebSocketBloc(),
      //   child: const WebSocketPage(),
      // ),
          // home: StudentHomePage(),
          // home:WorkshopsScreen(),
          // home:ScheduleScreen(),
          // home:ProfilePage(),
        ),
      ),
    );
  }
}
