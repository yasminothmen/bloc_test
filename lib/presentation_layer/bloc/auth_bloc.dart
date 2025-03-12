import 'package:bloc/bloc.dart';
import 'package:bloc_test/data/repositories/AuthRepository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(UnAuthenticated()) {
    // ✅ Gestion de la connexion
    on<LoginRequested>(
      (event, emit) async {
        emit(Loading());
        try {
          await authRepository.login(email: event.email, password: event.password);

          // ✅ Récupérer le token Firebase après connexion
          String? token = await authRepository.getFirebaseToken();

          if (token != null) {
            print("Firebase Token: $token"); // Debug

            // ✅ Envoyer le token à Spring Boot Backend
            await authRepository.sendTokenToBackend(token);

            emit(Authenticated()); // ✅ L'utilisateur est authentifié
          } else {
            print("Échec de la récupération du token.");
            emit(UnAuthenticated());
          }
        } catch (e) {
          print("Erreur lors de l'authentification: $e");
          emit(UnAuthenticated()); // ❌ En cas d'échec
        }
      },
    );

    // ✅ Gestion de la déconnexion
    on<LogoutRequested>(
      (event, emit) async {
        try {
          await authRepository.logout();
          emit(UnAuthenticated()); // ✅ L'utilisateur est déconnecté
        } catch (e) {
          print("Erreur lors de la déconnexion: $e");
        }
      },
    );
  }
}
