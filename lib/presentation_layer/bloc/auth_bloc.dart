import 'package:bloc/bloc.dart';
import '../../repositories/AuthRepository.dart';
import 'package:bloc_test/model/user.dart'; // Importez votre modèle User
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthState> emit) async {
    emit(Loading());
    try {
      final userCredential = await authRepository.login(
          email: event.email, password: event.password);

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // Création de l'utilisateur avec le constructeur const
        final user = AppUser(
          id: firebaseUser.uid,
          imagePath: '', // Valeur par défaut
          name: firebaseUser.displayName ?? 'Utilisateur',
          role: firebaseUser.email?.endsWith('@enseignant.com') ?? false 
              ? 'teacher' 
              : 'student', // Détermination du rôle
          email: firebaseUser.email ?? '',
          about: '', // Valeur par défaut
          isDarkMode: false, // Valeur par défaut
        );

        // Récupérer le token Firebase
        String? token = await authRepository.getFirebaseToken();

        if (token != null) {
          print("Firebase Token: $token");
          await authRepository.sendTokenToBackend(token);
          emit(Authenticated(user: user));
        } else {
          print("Échec de la récupération du token.");
          emit(UnAuthenticated(error: 'the user does not exist'));
        }
      } else {
        emit(UnAuthenticated(error: 'User not found'));
      }
    } catch (e) {
      print("Erreur lors de l'authentification: $e");
      emit(UnAuthenticated(error: e.toString()));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    authRepository.logout();
    emit(AuthInitial());
  }
}