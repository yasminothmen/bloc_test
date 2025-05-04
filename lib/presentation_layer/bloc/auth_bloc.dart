import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import '../../model/user.dart';
import '../../repositories/AuthRepository.dart';
import '../../services/api_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final Dio dio = ApiService.instance; // Utilise votre interceptor Dio existant

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(Loading());
    try {
      // 1. Authentification Firebase
      final userCredential = await authRepository.login(
          email: event.email, password: event.password);

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        emit(UnAuthenticated(error: 'User not found'));
        return;
      }
      // Récupération et affichage du token Firebase
      final token = await firebaseUser.getIdToken();
      print('🔥 Firebase User Token: $token'); 

      // 2. Récupération UNIQUEMENT du prénom depuis l'API Spring
      final firstname = await _fetchFirstnameFromBackend(firebaseUser.email!);
      final lastname = await _fetchLastnameFromBackend(firebaseUser.email!);
      // Récupérer l'ID de l'image de profil
      final profileImageId = await _fetchProfileImageId(firebaseUser.email!);

      // 3. Création de l'utilisateur
      final user = AppUser(
        id: firebaseUser.uid,
        profileImageId: profileImageId, // Valeur par défaut
        firstname: firstname, // Utilisation du prénom récupéré

        role: firebaseUser.email?.endsWith('@enseignant.com') ?? false
            ? 'teacher'
            : 'student',
        email: firebaseUser.email ?? '',
        about: '', // Valeur par défaut
        isDarkMode: false,
        lastname: lastname,
      );

      // 4. Le token est déjà envoyé automatiquement par l'interceptor
      emit(Authenticated(user: user));
    } catch (e) {
      print("Authentication error: $e");
      emit(UnAuthenticated(error: 'Échec de connexion: ${e.toString()}'));
    }
  }

  Future<String?> _fetchProfileImageId(String email) async {
    try {
      // Utilisez ApiService.getProfileImage qui gère déjà le ResponseType.bytes
      final imageBytes = await ApiService.getProfileImage(email);

      // Si on a des bytes, cela signifie que l'image existe
      // On retourne simplement l'email comme identifiant ou un autre identifiant unique
      return imageBytes != null ? email : null;
    } catch (e) {
      print("Profile image fetch error: $e");
      return null;
    }
  }

  Future<String> _fetchFirstnameFromBackend(String email) async {
    try {
      final response = await dio.get(
        '/api/user/by-email/${Uri.encodeComponent(email)}',
      );

      // Suppose que votre API retourne directement le prénom en String
      return response.data as String;
    } catch (e) {
      print("Firstname fetch error: $e");
      return 'Utilisateur'; // Valeur par défaut si échec
    }
  }

  Future<String> _fetchLastnameFromBackend(String email) async {
    try {
      final response = await dio.get(
        '/api/user/findlastname/${Uri.encodeComponent(email)}',
      );

      // Suppose que votre API retourne directement le prénom en String
      return response.data as String;
    } catch (e) {
      print("Firstname fetch error: $e");
      return 'Utilisateur'; // Valeur par défaut si échec
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    authRepository.logout();
    emit(AuthInitial());
  }
}
