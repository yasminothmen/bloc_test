import '../model/cours.dart';
import 'package:flutter/foundation.dart';

class FavoriteManager with ChangeNotifier {
  static final FavoriteManager _instance = FavoriteManager._internal();
  
  factory FavoriteManager() => _instance;
  
  FavoriteManager._internal();

  final List<Cours> _favorites = [];

  List<Cours> get favorites => _favorites;

  void toggleFavorite(Cours course) {
    final existingIndex = _favorites.indexWhere((c) => c.id == course.id);
    
    if (existingIndex >= 0) {
      _favorites.removeAt(existingIndex);
      course.bookmarked = false;
    } else {
      _favorites.add(course);
      course.bookmarked = true;
    }
    notifyListeners();
    debugPrint('Favorites count: ${_favorites.length}'); 
  }

  bool isFavorite(Cours course) {
    return _favorites.any((c) => c.id == course.id);
  }
   
  bool isFavoriteById(String courseId) {
    return _favorites.any((c) => c.id == courseId);
  }
}