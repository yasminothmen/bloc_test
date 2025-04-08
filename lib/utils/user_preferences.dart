import 'dart:convert';

import 'package:bloc_test/data/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static late SharedPreferences _preferences;

  static const _keyUser = 'user';
  static const myUser = AppUser(
    imagePath:
        'https://images.unsplash.com/photo-1554151228-14d9def656e4?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=333&q=80',
    name: 'Yassmin Othmen',
    email: 'yasminothmen11@gmail.com',
    about:
        'Certified Personal Trainer and Nutritionist with years of experience in creating effective diets and training plans focused on achieving individual customers goals in a smooth way.',
    isDarkMode: false, id: '', role: '',
  );

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setUser(AppUser user) async {
    final json = jsonEncode(user.toJson());

    await _preferences.setString(_keyUser, json);
  }

  static AppUser getUser() {
    final json = _preferences.getString(_keyUser);

    return json == null ? myUser : AppUser.fromJson(jsonDecode(json));
  }
}