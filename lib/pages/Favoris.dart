import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../model/cours.dart';

class FavoriteProvider extends ChangeNotifier {
  final List<Cours> _favorite = [];
  List<Cours> get favorites => _favorite;
  void toggleFavorite(Cours cours) {
    if (_favorite.contains(cours)) {
      _favorite.remove(cours);
    } else {
      _favorite.add(cours);
    }
    notifyListeners();
  }

  bool isExist(Cours cours) {
    final isExist = _favorite.contains(cours);
    return isExist;
  }

  // static FavoriteProvider of(BuildContext context, {bool listen = true}) {
  //   return Provider.of<FavoriteProvider>(context, listen: listen);
  // }
}
// this is the logic parts now we can implement this
