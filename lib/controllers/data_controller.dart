import 'package:bloc_test/data/models/user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

class Data_controller extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;

  User Current_User = User(name: 'name', email: 'email');
  List chats = [];
  List users = [];

  Data_controller() {
    get_user(auth.currentUser!.uid);
    get_all_users();
  }

  get_user(id) async {
    await Firebase_get().get_currnt_user(id).then((value) {
      Current_User = value;
      update();
    });
  }

  get_all_users() async {
    Firebase_get().get_all_users().then((value) {
      for (var i in value) {
        users.add(User.fromJson(i.data()));
        update();
      }
    });
    
  }
}
