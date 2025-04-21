import 'package:bloc_test/pages/home_page.dart';
import 'package:bloc_test/presentation_layer/Screens/profile_page.dart';
import 'package:bloc_test/repositories/AuthRepository.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation_layer/bloc/auth_bloc.dart';
import 'presentation_layer/bloc/auth_state.dart';
import 'presentation_layer/Screens/LoginPage.dart';
import 'presentation_layer/Screens/WorkshopsScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
        
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                // Redirection basée sur le rôle
                if (state.user.role == 'teacher') {
                  return WorkshopsScreen();
                } else {
                  return const MainTabBarPage();
                }
              } else if (state is UnAuthenticated) {
                return LoginScreen();
              }
              return LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}

class MainTabBarPage extends StatefulWidget {
  const MainTabBarPage({super.key});

  @override
  State<MainTabBarPage> createState() => _MainTabBarPageState();
}

class _MainTabBarPageState extends State<MainTabBarPage> {
  int selectedIndex = 2;

  static List<Widget> tabBarPages = [
    const HomePage(),
    const HomePage(),
    const HomePage(),
    const HomePage(),
    ProfilePage(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabBarPages[selectedIndex],
      bottomNavigationBar: bottomNavigationBar(context),
    );
  }

  BottomNavigationBar bottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.black,
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.white,
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      items: [
        BottomNavigationBarItem(icon: Icon(IconlyBold.play), label: "Courses"),
        BottomNavigationBarItem(icon: Icon(IconlyBold.buy), label: "Cart"),
        BottomNavigationBarItem(icon: Icon(IconlyBold.home), label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(IconlyBold.bookmark), label: "My Courses"),
        BottomNavigationBarItem(
            icon: Icon(IconlyBold.profile), label: "Profile"),
      ],
    );
  }
}