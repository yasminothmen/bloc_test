import 'package:bloc_test/constants/BackendUrl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // *** Méthode de connexion
  Future<UserCredential> login({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential; 
    } catch (e) {
      throw Exception("Échec de la connexion : ${e.toString()}");
    }
  }

  // *** Méthode de déconnexion
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // *** Vérifier si un utilisateur est connecté
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // *** Récupérer le Token Firebase
  Future<String?> getFirebaseToken() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        return await user.getIdToken(); 
      }
      return null;
    } catch (e) {
      print("Erreur lors de la récupération du token : $e");
      return null;
    }
  }

  // *** Envoyer le Token Firebase au backend Spring Boot
  Future<void> sendTokenToBackend(String token) async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/auth/verify-token'),
        headers: {
          "Authorization": "Bearer $token", 
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        print("Token envoyé avec succès au backend !");
      } else {
        print("Échec de l'envoi du token. Réponse: ${response.body}");
      }
    } catch (e) {
      print("Erreur lors de l'envoi du token : $e");
    }
  }
}
