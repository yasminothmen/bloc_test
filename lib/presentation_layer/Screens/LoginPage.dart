import 'package:bloc_test/constants/my_colors.dart';
import 'package:bloc_test/presentation_layer/Screens/WorkshopsScreen.dart';
import 'package:bloc_test/presentation_layer/Screens/student_home_page.dart';
import 'package:bloc_test/presentation_layer/bloc/auth_bloc.dart';
import 'package:bloc_test/presentation_layer/bloc/auth_event.dart';
import 'package:bloc_test/presentation_layer/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;

  @override
  void dispose() {
    // Évite les fuites de mémoire
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: MyColors.mybackg,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(29.0),
                  child: Text(
                    "Salut!\nConnexion à votre compte",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF062091),
                    ),
                  ),
                ),
                const SizedBox(height: 75),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF246BFD),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputField(
                            label: "Email",
                            hint: "Entrer ton email",
                            controller: emailController,
                            icon: Icons.email,
                            isPasswordVisible: false,
                            togglePasswordVisibility: () {},
                          ),
                          const SizedBox(height: 30),
                          _buildInputField(
                            label: "Mot de passe",
                            hint: "Entrer ton mot de passe",
                            controller: passwordController,
                            isPassword: true,
                            icon: Icons.lock,
                            isPasswordVisible: isPasswordVisible,
                            togglePasswordVisibility: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                          const SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed:
                                  () {}, // TODO: Implémenter la récupération du mot de passe
                              child: const Text(
                                "Mot de passe oublié?",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 65),
                          BlocConsumer<AuthBloc, AuthState>(
                            listener: (context, state) {
                              if (state is Authenticated) {
                               
                                if (state.user.role == 'teacher') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WorkshopsScreen(),
                                    ),
                                  );
                                }else{
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StudentHomePage(),
                                    ),
                                  );
                                }
                              } else if (state is UnAuthenticated) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Échec de la connexion."),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            builder: (context, state) {
                              return Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF062091),
                                    minimumSize: const Size(300, 47),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: state is Loading
                                      ? null
                                      : () {
                                          if (emailController.text.isEmpty ||
                                              passwordController.text.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    "Veuillez remplir tous les champs."),
                                                backgroundColor: Colors.orange,
                                              ),
                                            );
                                            return;
                                          }

                                          context.read<AuthBloc>().add(
                                                LoginRequested(
                                                  email: emailController
                                                      .text, // Ajout du nom du paramètre
                                                  password: passwordController
                                                      .text, // Ajout du nom du paramètre
                                                ),
                                              );
                                        },
                                  child: state is Loading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          "Connexion",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildInputField({
  required String label,
  required String hint,
  required TextEditingController controller,
  required bool isPasswordVisible,
  bool isPassword = false,
  IconData? icon,
  required VoidCallback togglePasswordVisibility,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black),
          obscureText: isPassword && !isPasswordVisible,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: togglePasswordVisibility,
                  )
                : null,
          ),
        ),
      ),
    ],
  );
}
