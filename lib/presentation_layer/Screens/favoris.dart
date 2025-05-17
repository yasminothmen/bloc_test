import '../../model/cours.dart';
import 'favorisManager.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Favoris extends StatefulWidget {
  const Favoris({super.key});

  @override
  State<Favoris> createState() => _FavorisState();
}

class _FavorisState extends State<Favoris> {
  // Nouvelle classe d'état
  @override
  void initState() {
    super.initState();
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail != null) {
      FavoriteManager().syncFavorites(userEmail);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteManager = FavoriteManager();

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        centerTitle: true,
        title: const Text(
          "Mes favoris",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: favoriteManager,
        builder: (context, _) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteManager.favorites.length,
            itemBuilder: (context, index) {
              final course = favoriteManager.favorites[index];
              return FavoriteCourseItem(course: course);
            },
          );
        },
      ),
    );
  }
}


class FavoriteCourseItem extends StatelessWidget {
  final Cours course;

  const FavoriteCourseItem({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: AssetImage(course.imagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          course.titre,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              course.classe,
              style: TextStyle(
                // fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(course.instructor,
                style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            final userEmail = FirebaseAuth.instance.currentUser?.email;
            if (userEmail != null) {
              await FavoriteManager().toggleFavorite(course, userEmail);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Veuillez vous connecter')),
              );
            }
          },
        ),
      ),
    );
  }
}
