import 'package:bloc/bloc.dart';
import 'package:bloc_test/services/api_service.dart';
import 'package:dio/dio.dart';
import '../../repositories/AuthRepository.dart';
import 'package:bloc_test/model/user.dart';
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
      print('🔥 Firebase User Token: $token'); // <-- Ajout de ce print

      // 2. Récupération UNIQUEMENT du prénom depuis l'API Spring
      final firstname = await _fetchFirstnameFromBackend(firebaseUser.email!);

      // 3. Création de l'utilisateur
      final user = AppUser(
        id: firebaseUser.uid,
        imagePath: '', // Valeur par défaut
        firstname: firstname, // Utilisation du prénom récupéré

        role: firebaseUser.email?.endsWith('@enseignant.com') ?? false
            ? 'teacher'
            : 'student',
        email: firebaseUser.email ?? '',
        about: '', // Valeur par défaut
        isDarkMode: false, // Valeur par défaut
      );

      // 4. Le token est déjà envoyé automatiquement par l'interceptor
      emit(Authenticated(user: user));
    } catch (e) {
      print("Authentication error: $e");
      emit(UnAuthenticated(error: 'Échec de connexion: ${e.toString()}'));
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

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    authRepository.logout();
    emit(AuthInitial());
  }
}
