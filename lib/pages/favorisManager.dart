import 'package:bloc_test/services/api_service.dart';
import '../model/cours.dart';
import 'package:flutter/foundation.dart';

class FavoriteManager with ChangeNotifier {
  static final FavoriteManager _instance = FavoriteManager._internal();
  factory FavoriteManager() => _instance;
  FavoriteManager._internal();

  final List<Cours> _favorites = [];
  List<Cours> get favorites => _favorites;

  Future<void> syncFavorites(String email) async {
    try {
      final response = await ApiService.get('/api/favorites/$email');
      if (response.statusCode == 200) {
        _favorites.clear();
        final List<dynamic> data = response.data;
        _favorites.addAll(data.map((json) => Cours.fromJson(json)));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error syncing favorites: $e');
    }
  }

  Future<void> toggleFavorite(Cours course, String email) async {
    try {
      final response = await ApiService.post(
        '/api/favorites/toggle/$email/${course.id}',
        null,
      );

      if (response.statusCode == 200) {
        final existingIndex = _favorites.indexWhere((c) => c.id == course.id);
        
        if (existingIndex >= 0) {
          _favorites.removeAt(existingIndex);
          course.bookmarked = false;
        } else {
          _favorites.add(course);
          course.bookmarked = true;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      rethrow;
    }
  }

  bool isFavorite(Cours course) => _favorites.any((c) => c.id == course.id);
  bool isFavoriteById(String courseId) => _favorites.any((c) => c.id == courseId);
}