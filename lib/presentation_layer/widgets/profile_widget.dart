import 'dart:io';
import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final String imagePath;
  final bool isEdit;
  final VoidCallback onClicked;

  const ProfileWidget({
    Key? key,
    required this.imagePath,
    this.isEdit = false, // ✅ Make isEdit optional
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          buildImage(),
          if (isEdit) buildEditIcon(),
        ],
      ),
    );
  }

  Widget buildImage() {
    final image = imagePath.startsWith('http')
        ? NetworkImage(imagePath) as ImageProvider
        : FileImage(File(imagePath));

    return CircleAvatar(
      radius: 50,
      backgroundImage: image,
    );
  }

  Widget buildEditIcon() => Positioned(
        bottom: 0,
        right: 4,
        child: GestureDetector(
          onTap: onClicked,
          child: CircleAvatar(
            backgroundColor: Colors.blue,
            radius: 16,
            child: Icon(Icons.edit, color: Colors.white, size: 16),
          ),
        ),
      );
}
