import 'dart:io';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:bloc_test/data/models/user.dart';
import 'package:bloc_test/presentation_layer/widgets/appbar.dart';
import 'package:bloc_test/presentation_layer/widgets/profile_widget.dart';
import 'package:bloc_test/utils/user_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart'; // Ajouté pour récupérer le répertoire des documents

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User user;

  @override
  void initState() {
    super.initState();
    user = UserPreferences.getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          ProfileWidget(
            imagePath: user.imagePath,
            isEdit: true,
            onClicked: () async {
              final pickedFile =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
              if (pickedFile == null) return;

              final directory = await getApplicationDocumentsDirectory();
              final name = basename(pickedFile.path);
              final imageFile = File('${directory.path}/$name');
              final newImage = await File(pickedFile.path).copy(imageFile.path);

              setState(() {
                user = user.copy(imagePath: newImage.path);
              });
            },
          ),
          const SizedBox(height: 24),
          buildName(user),
        ],
      ),
    );
  }

  Widget buildName(User user) => Column(
        children: [
          Text(
            user.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
}
